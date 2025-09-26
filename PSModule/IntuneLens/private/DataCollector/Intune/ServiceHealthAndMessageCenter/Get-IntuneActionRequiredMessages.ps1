function Get-IntuneActionRequiredMessages {
    <#
    .SYNOPSIS
        Collect "Action Required" Microsoft Intune messages for the tenant.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /admin/serviceAnnouncement/messages
        to retrieve "Action Required" messages for Microsoft Intune.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        $messages = Get-IntuneActionRequiredMessages -AccessToken <AccessToken>
    
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
    $endpoint = "$base/admin/serviceAnnouncement/messages"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $filter = "services/any(s:s eq 'Microsoft Intune') and contains(title,'Action Required')"
    $url = "$endpoint`?`$filter=$([uri]::EscapeDataString($filter))&`$select=id"

    $items = @()
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($resp.value) {
            $items += ($resp.value | ForEach-Object { $_.id }) | Where-Object { $_ }
        }

        if ($resp.PSObject.Properties.Name -contains '@odata.nextLink') {
            $url = $resp.'@odata.nextLink'
        }
        else {
            $url = $null
        }
    } while ($url)

    return $items
}