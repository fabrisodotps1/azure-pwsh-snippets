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