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

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
        $items = if ($resp.value) { $resp.value } else { @() }

        $thirdParty = $items | Where-Object { -not $_.microsoftDefenderForEndpointAttachEnabled }

        if ($thirdParty.Count -eq 0) {
            return @()
        }

        $results = foreach ($c in $thirdParty) {
            [pscustomobject]@{
                id                    = $c.id
                lastHeartbeatDateTime = if ($c.lastHeartbeatDateTime) { [datetime]$c.lastHeartbeatDateTime } else { $null }
                partnerState          = if ($c.partnerState) { [string]$c.partnerState } else { $null }
            }
        }

        return $results
    }
    catch {
        throw
    }
}