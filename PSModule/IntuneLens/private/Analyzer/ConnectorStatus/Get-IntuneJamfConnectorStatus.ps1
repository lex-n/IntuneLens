function Get-IntuneJamfConnectorStatus {
    <#
    .SYNOPSIS
        Analyzes JAMF connector health status.

    .DESCRIPTION
        Determines JAMF connector health status.
        Unhealthy:
          - The last heartbeat was three or more days ago OR the partnerState is not “enabled”
        Warning:
          - The last heartbeat was more than one day ago AND the partnerState is “enabled”
        Healthy:
          - The last heartbeat was less than one day ago AND the partnerState is “enabled”

    .PARAMETER JamfConnector
        The object returned by Get-JamfConnector

    .EXAMPLE
        $jamfConnector = Get-JamfConnector -AccessToken <AccessToken>
        Get-IntuneJamfConnectorStatus -JamfConnector $jamfConnector

    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $JamfConnector
    )

    if ($null -eq $JamfConnector -or (@($JamfConnector).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName       = 'JAMF'
            connectorInstanceId = $null
            status              = 'Not Enabled'
            eventDateTime       = $null
        }
    }

    $now = Get-Date
    $status = 'unknown'

    $lastHeartbeatDateTime = $null
    if ($JamfConnector.lastHeartbeatDateTime) {
        try { 
            $lastHeartbeatDateTime = [datetime]$JamfConnector.lastHeartbeatDateTime 
        } 
        catch { 
            $lastHeartbeatDateTime = $null 
        }
    }

    $partnerStateRaw = $JamfConnector.partnerState
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
        connectorName       = 'jamfLastSyncDateTime'
        connectorInstanceId = $JamfConnector.id
        status              = $status
        eventDateTime       = $lastHeartbeatDateTime
    }
}