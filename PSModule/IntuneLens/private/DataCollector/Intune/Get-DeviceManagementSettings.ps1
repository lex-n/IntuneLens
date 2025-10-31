function Get-DeviceManagementSettings {
    <#
    .SYNOPSIS
        Gets Intune device management settings.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/settings
        and returns Intune device management settings.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-DeviceManagementSettings -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/deviceManagement/settings"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        return [pscustomobject]@{
            success         = $resp.success
            secureByDefault = if ($resp.data -and $null -ne $resp.data.secureByDefault) {
                $resp.data.secureByDefault
            }
            else { 'N/A' }
        }
    }
}