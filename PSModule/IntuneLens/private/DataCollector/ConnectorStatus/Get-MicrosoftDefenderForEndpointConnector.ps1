function Get-MicrosoftDefenderForEndpointConnector {
    <#
    .SYNOPSIS
        Gets Microsoft Defender for Endpoint connector.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/mobileThreatDefenseConnectors
        to get Microsoft Defender for Endpoint connector.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-MicrosoftDefenderForEndpointConnector -AccessToken <AccessToken>

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

        $mde = $items | Where-Object { $_.microsoftDefenderForEndpointAttachEnabled -eq $true } | Select-Object -First 1

        if (-not $mde) {
            return [pscustomobject]@{
                id                    = $null
                lastHeartbeatDateTime = $null
                partnerState          = $null
            }
        }

        return [pscustomobject]@{
            id                    = $mde.id
            lastHeartbeatDateTime = if ($mde.lastHeartbeatDateTime) { [datetime]$mde.lastHeartbeatDateTime } else { $null }
            partnerState          = if ($mde.partnerState) { [string]$mde.partnerState } else { $null }
        }
    }
    catch {
        throw
    }
}