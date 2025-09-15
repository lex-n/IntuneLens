function Get-IntuneDevices {
    <#
    .SYNOPSIS
        Collects managed devices from Microsoft Graph.

    .DESCRIPTION
        Queries the Graph endpoint /deviceManagement/managedDevices and returns the
        raw objects. Supports paging (-All) and top-N limiting (-Top).
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .PARAMETER Top
        Number of items to fetch on the first page (default 200, maximum 999).

    .PARAMETER All
        Switch. If specified, follows @odata.nextLink to fetch all pages.

    .EXAMPLE
        $devices = Get-IntuneDevices -AccessToken $token -All
        Returns all managed devices in the tenant.

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken,
        [int]    $Top = 200,    # first page size (Graph allows up to 999)
        [switch] $All           # follow @odata.nextLink to fetch all pages
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/deviceManagement/managedDevices"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,deviceName,operatingSystem,complianceState,azureADDeviceId,userPrincipalName,lastSyncDateTime&`$top=$Top"

    $acc = @()
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
        if ($resp.value) { $acc += $resp.value }
        $url = if ($All -and $resp.'@odata.nextLink') { $resp.'@odata.nextLink' } else { $null }
    } while ($url)

    $acc | ForEach-Object {
        [pscustomobject]@{
            id                = $_.id
            deviceName        = $_.deviceName
            operatingSystem   = $_.operatingSystem
            complianceState   = $_.complianceState
            userPrincipalName = $_.userPrincipalName
            lastSyncDateTime  = $_.lastSyncDateTime
        }
    }
}