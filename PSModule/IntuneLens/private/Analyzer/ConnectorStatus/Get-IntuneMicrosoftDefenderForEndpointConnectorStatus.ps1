function Get-IntuneMicrosoftDefenderForEndpointConnectorStatus {
    <#
    .SYNOPSIS
        Analyzes Microsoft Defender for Endpoint connector health status.

    .DESCRIPTION
        Determines Microsoft Defender for Endpoint connector health status.
        Unhealthy:
          - The last heartbeat was three or more days ago OR the partnerState is not “enabled”
        Warning:
          - The last heartbeat was more than one day ago AND the partnerState is “enabled”
        Healthy:
          - The last heartbeat was less than one day ago AND the partnerState is “enabled”

    .PARAMETER MicrosoftDefenderForEndpointConnector
        The object returned by Get-MicrosoftDefenderForEndpointConnector

    .EXAMPLE
        $mdeConnector = Get-MicrosoftDefenderForEndpointConnector -AccessToken <AccessToken>
        Get-IntuneMicrosoftDefenderForEndpointConnectorStatus -MicrosoftDefenderForEndpointConnector $mdeConnector

    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $MicrosoftDefenderForEndpointConnector
    )

    if ($null -eq $MicrosoftDefenderForEndpointConnector -or (@($MicrosoftDefenderForEndpointConnector).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName       = 'Microsoft Defender for Endpoint Connector'
            connectorInstanceId = $null
            status              = 'Not Enabled'
            eventDateTime       = $null
        }
    }

    $now = Get-Date
    $status = 'unknown'

    $lastHeartbeatDateTime = $null
    if ($MicrosoftDefenderForEndpointConnector.lastHeartbeatDateTime) {
        try { 
            $lastHeartbeatDateTime = [datetime]$MicrosoftDefenderForEndpointConnector.lastHeartbeatDateTime 
        } 
        catch { 
            $lastHeartbeatDateTime = $null 
        }
    }

    $partnerStateRaw = $MicrosoftDefenderForEndpointConnector.partnerState
    $statusNorm = if ($partnerStateRaw) { $partnerStateRaw.ToString().ToLowerInvariant() } else { $null }
    $isEnabled = ($statusNorm -eq 'enabled')

    if (-not $isEnabled -and $partnerStateRaw) {
        $status = 'unhealthy'
    }
    elseif ($isEnabled -and $lastHeartbeatDateTime) {
        $ageDays = ($now - $lastHeartbeatDateTime).TotalDays
        if ($ageDays -ge 3) { $status = 'unhealthy' }
        elseif ($ageDays -gt 1) { $status = 'warning' }
        else { $status = 'healthy' }
    }

    return [pscustomobject][ordered]@{
        connectorName       = 'microsoftDefenderForEndpointLastHeartbeatDateTime'
        connectorInstanceId = $MicrosoftDefenderForEndpointConnector.id
        status              = $status
        eventDateTime       = $lastHeartbeatDateTime
    }
}