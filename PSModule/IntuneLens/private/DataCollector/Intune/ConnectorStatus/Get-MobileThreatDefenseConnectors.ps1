function Get-MobileThreatDefenseConnectors {
    <#
    .SYNOPSIS
        Gets third-party Mobile Threat Defense (MTD) connectors (non-Microsoft).

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/mobileThreatDefenseConnectors
        to get third-party Mobile Threat Defense connectors.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-MobileThreatDefenseConnectors -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/deviceManagement/mobileThreatDefenseConnectors"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,lastHeartbeatDateTime,partnerState,microsoftDefenderForEndpointAttachEnabled"

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $items = if ($resp.data.value) { $resp.data.value } else { @() }

        $thirdParty = $items | Where-Object { -not $_.microsoftDefenderForEndpointAttachEnabled }

        $connectors = foreach ($c in $thirdParty) {
            [pscustomobject]@{
                id                    = if ($c.id) { $c.id } else { 'N/A' }
                lastHeartbeatDateTime = if ($c.lastHeartbeatDateTime) { [datetime]$c.lastHeartbeatDateTime } else { $null }
                partnerState          = if ($c.partnerState) { [string]$c.partnerState } else { 'N/A' }
            }
        }

        $results = [pscustomobject]@{
            success    = $resp.success
            connectors = $connectors
        }

        return $results
    }
}