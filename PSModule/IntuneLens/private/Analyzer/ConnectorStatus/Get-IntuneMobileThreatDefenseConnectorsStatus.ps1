function Get-IntuneMobileThreatDefenseConnectorsStatus {
    <#
    .SYNOPSIS
        Analyzes Mobile Threat Defense connectors health status.

    .DESCRIPTION
        Determines Mobile Threat Defense connectors health status.
        Unhealthy:
          - The last heartbeat was three or more days ago OR the partnerState is not “enabled”
        Warning:
          - The last heartbeat was more than one day ago AND the partnerState is “enabled”
        Healthy:
          - The last heartbeat was less than one day ago AND the partnerState is “enabled”

        When multiple connectors exist, the group's status is the least healthy status among them.

    .PARAMETER MobileThreatDefenseConnectors
        The object returned by Get-MobileThreatDefenseConnectors

    .EXAMPLE
        $mobileThreatDefenseConnectors = Get-MobileThreatDefenseConnectors -AccessToken <AccessToken>
        Get-IntuneMobileThreatDefenseConnectorsStatus -MobileThreatDefenseConnectors $mobileThreatDefenseConnectors

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [psobject] $MobileThreatDefenseConnectors
    )

    if ($null -eq $MobileThreatDefenseConnectors -or (@($MobileThreatDefenseConnectors).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName = 'Mobile Threat Defense Connectors (non-Microsoft)'
            status        = 'Not Enabled'
        }
    }

    $items = @($MobileThreatDefenseConnectors)

    $now = Get-Date
    $rank = @{ unknown = 0; healthy = 1; warning = 2; unhealthy = 3 }
    $worst = 'unknown'

    foreach ($c in $items) {
        $state = $null
        if ($c.PSObject.Properties.Name -contains 'partnerState' -and $c.partnerState) {
            try { 
                $state = $c.partnerState.ToString().ToLowerInvariant() 
            } 
            catch { 
                $state = $null 
            }
        }

        $lastHeartbeatDateTime = $null
        if ($c.PSObject.Properties.Name -contains 'lastHeartbeatDateTime' -and $c.lastHeartbeatDateTime) {
            try { 
                $lastHeartbeatDateTime = [datetime]$c.lastHeartbeatDateTime 
            } 
            catch { 
                $lastHeartbeatDateTime = $null 
            }
        }

        $status = 'unknown'
        $isEnabled = ($state -eq 'enabled')

        if ($state -and -not $isEnabled) {
            $status = 'unhealthy'
        }
        elseif ($isEnabled -and $lastHeartbeatDateTime) {
            $ageDays = ($now - $lastHeartbeatDateTime).TotalDays
            if ($ageDays -ge 3) { $status = 'unhealthy' }
            elseif ($ageDays -gt 1) { $status = 'warning' }
            else { $status = 'healthy' }
        }

        if ($rank[$status] -gt $rank[$worst]) { $worst = $status }
        if ($worst -eq 'unhealthy') { break }
    }

    return [pscustomobject][ordered]@{
        connectorName = 'mobileThreatDefenceConnectorLastHeartbeatDateTime'
        status        = $worst
    }
}