function Get-JamfConnector {
    <#
    .SYNOPSIS
        Gets Jamf connector info.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/deviceManagementPartners
        to get Jamf connector information.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-JamfConnector -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/deviceManagementPartners"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,displayName,isConfigured,lastHeartbeatDateTime,partnerState"

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $partners = @()
        if ($resp.data -and $resp.data.PSObject.Properties.Name -contains 'value') {
            $partners = $resp.data.value
        }

        $jamf = $partners | Where-Object { $_.displayName -match '(?i)Jamf' } | Select-Object -First 1

        if (-not $jamf) {
            return [pscustomobject]@{
                success      = $resp.success
                isConfigured = $false
            }
        }

        return [pscustomobject]@{
            success               = $resp.success
            id                    = if ($jamf.id) { $jamf.id } else { 'N/A' }
            lastHeartbeatDateTime = if ($jamf.lastHeartbeatDateTime) { $jamf.lastHeartbeatDateTime } else { 'N/A' }
            partnerState          = if ($jamf.partnerState) { [string]$jamf.partnerState } else { 'N/A' }
            isConfigured          = if ($jamf.isConfigured) { $jamf.isConfigured } else { $false }
        }
    }
}