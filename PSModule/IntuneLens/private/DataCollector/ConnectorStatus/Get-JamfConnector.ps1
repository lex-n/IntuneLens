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

    $url = "$endpoint`?`$select=displayName,isConfigured,lastHeartbeatDateTime,partnerState"

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        $partners = @()
        if ($resp -and $resp.PSObject.Properties.Name -contains 'value') {
            $partners = $resp.value
        }

        $jamf = $partners | Where-Object { $_.displayName -match '(?i)Jamf' } | Select-Object -First 1

        if (-not $jamf -or -not $jamf.isConfigured) {
            return @()
        }

        $lastHeartbeat = $null
        if ($jamf.lastHeartbeatDateTime -and $jamf.lastHeartbeatDateTime -ne '0001-01-01T00:00:00Z') {
            $lastHeartbeat = [datetime]$jamf.lastHeartbeatDateTime
        }

        return [pscustomobject]@{
            lastHeartbeatDateTime = $lastHeartbeat
            partnerState          = [string]$jamf.partnerState
        }
    }
    catch {
        throw
    }
}