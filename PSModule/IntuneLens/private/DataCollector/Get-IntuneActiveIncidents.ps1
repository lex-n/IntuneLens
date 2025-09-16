function Get-IntuneActiveIncidents {
    <#
    .SYNOPSIS
        Collect active Microsoft Intune incidents for the tenant.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /admin/serviceAnnouncement/issues with filter:
        "service eq 'Microsoft Intune' and classification eq 'incident' and isResolved eq false".
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        $incidents = Get-IntuneActiveIncidents -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/admin/serviceAnnouncement/issues"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $filter = "service eq 'Microsoft Intune' and classification eq 'incident' and isResolved eq false"
    $url = "$endpoint`?`$filter=$([uri]::EscapeDataString($filter))&`$select=id"

    $items = @()
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($resp.value) {
            $items += $resp.value
        }

        if ($resp.PSObject.Properties.Name -contains '@odata.nextLink') {
            $url = $resp.'@odata.nextLink'
        }
        else {
            $url = $null
        }
    } while ($url)

    $items | ForEach-Object {
        [pscustomobject]@{
            id = $_.id
        }
    }
}