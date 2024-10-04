<#
.SYNOPSIS
    Get-EntraAppsLoginCount.ps1

.DESCRIPTION
    Get login count for every application (service pricipal) in Entra ID.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ParameterSetName='SignInLogsGraph')]
    [Parameter(Mandatory=$true, ParameterSetName='SignInLogsLAW')]
    [string]$TenantId,

    [Parameter(Mandatory=$false, ParameterSetName='SignInLogsGraph')]
    [Parameter(Mandatory=$false, ParameterSetName='SignInLogsLAW')]
    [int]$Days = 30, # How many days back to look

    [Parameter(Mandatory=$true, ParameterSetName='SignInLogsLAW')]
    [string]$WorkspaceId
)

########################################################
### Variables                                        ###
########################################################



########################################################
### Functions                                        ###
########################################################

function Get-LawSignInLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$LaAccessToken,
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$LaWorkspaceId,
        [Parameter(Mandatory = $true)]
        [int]$DaysAgo
    )

    $header = @{
        "Authorization" = "Bearer $($LaAccessToken.Token)"
        "Content-Type"  = "application/json"
    }

    $logs = Invoke-RestMethod -Uri "https://api.loganalytics.io/v1/workspaces/$($LaWorkspaceId)/query?query=SigninLogs | where TimeGenerated > ago($($DaysAgo)h)" -Headers $header

    [System.Collections.ArrayList]$logsArr = @()
    foreach ($row in $logs.tables.rows) {
        $logObj = New-Object -TypeName psobject
        $i = 0
        foreach ($entry in $row) {
            $logObj | Add-Member -MemberType NoteProperty -Name $logs.tables.columns[$i].name -Value $entry
            $i++
        }
        $logsArr.Add($logObj) | Out-Null
    }

    return $logsArr
}

function Get-GraphObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$MSGraphAccessToken,
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            "v1.0",
            "beta"
        )]
        [string]$ApiVersion = "beta",
        [Parameter(Mandatory = $true)]
        [string]$ResourceUri
    )

    $uri = "https://graph.microsoft.com/$($ApiVersion)/$($ResourceUri)"
    $elements = @()

    $header = @{
        'Content-Type'  = "application/json"
        'Authorization' = "Bearer $($MSGraphAccessToken.Token)"
    }

    while ($uri) {
        $response = Invoke-RestMethod -Method "GET" -Uri $uri -Headers $header

        if ($response.PSObject.Properties.Name -contains "value") {
            $elements += $response.Value
        } else {
            $elements += $response
        }
        
        $uri = $response."@odata.nextLink"
    }
    return $elements
}

########################################################
### Main                                             ###
########################################################

# Graph API list signin logs: GET /auditLogs/signIns

# KQL for Signin Logs
# SigninLogs
# | where TimeGenerated >= ago(180d)

Connect-AzAccount | Out-Null

$graphApiAccessToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"

$applications = Get-GraphObject -MSGraphAccessToken $graphApiAccessToken -ResourceUri "servicePrincipals"

if([string]::IsNullOrEmpty($WorkspaceId)) {
    Write-Verbose "Reading Entra ID sign in logs via Graph"


} else {
    Write-Verbose "Reading Entra ID sign in logs in Log Analytics Workspace via Log Analytics API"
    $laApiAccessToken = Get-AzAccessToken -ResourceUrl "https://api.loganalytics.io"
    $lawSignInLogs = Get-LawSignInLogs -LaAccessToken $laApiAccessToken -DaysAgo $Days -LaWorkspaceId $WorkspaceId

    [System.Collections.ArrayList]$loginCountArr = @()
    foreach ($app in $applications) {
        $loginCount = ($lawSignInLogs | Where-Object { $_.AppId -like $app.appId }).count
        $loginCountObj = New-Object -TypeName psobject -Property @{ DisplayName = $app.displayName; AppId = $app.appId ; LoginCount = $loginCount }
        $loginCountArr.Add($loginCountObj) | Out-Null
    }

    $loginCountArr
}

