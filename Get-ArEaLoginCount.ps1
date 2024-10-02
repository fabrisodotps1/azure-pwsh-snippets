<#
.SYNOPSIS
    Get-ArEaLoginCount.ps1

.DESCRIPTION
    Get login count for application registrations and enterproise applications.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TenantId,
    [Parameter(Mandatory=$false)]
    [int]$Days = 30 # How many days back to look
)

########################################################
### Variables                                        ###
########################################################



########################################################
### Functions                                        ###
########################################################



########################################################
### Main                                             ###
########################################################

# Graph API list signin logs: GET /auditLogs/signIns

# KQL for Signin Logs
# SigninLogs
# | where TimeGenerated >= ago(180d)

Connect-AzAccount
$at = Get-AzAccessToken -ResourceUrl "https://management.azure.com"

$header = @{                
    "Authorization" = "Bearer $($at.Token)"
    "Content-Type"  = "application/json"
}

$workspace = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}/tables/{tableName}?api-version=2022-10-01" -Headers $header