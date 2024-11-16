# azure-pwsh-snippets

This repo contains a collection of PowerShell scripts that can be used for some tasks in Microsoft Azure.

## Get-EntraAppsLoginCount.ps1

To clean up the Entra ID applications in your tenant, it would be good to know which ones are still in use. The script lists the number of logins for all service principals in the tenant over a defined period of time. If the workspace id is also specified, the logs are obtained from the Log Analytics Workspace and an evaluation of more than 30 days is possible.

> The script needs the Az.Accounts module.

### Examples

Get application login count for the last 30 days.

`PS C:\> \.Get-EntraAppsLoginCount.ps1 -TenantId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`

Get application login count for the last 20 days.

`PS C:\> \.Get-EntraAppsLoginCount.ps1 -TenantId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -Days 20`

Get application login count for the last 45 days (from Log Analytics Workspace).

`PS C:\> \.Get-EntraAppsLoginCount.ps1 -TenantId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -Days 60 -WorkspaceId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`