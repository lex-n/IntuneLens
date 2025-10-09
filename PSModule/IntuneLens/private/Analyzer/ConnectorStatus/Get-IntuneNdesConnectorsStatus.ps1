function Get-IntuneNdesConnectorsStatus {
    <#
    .SYNOPSIS
        Analyzes NDES connectors health status.

    .DESCRIPTION
        Determines NDES connectors health status.
        Unhealthy:
          - The last connection was three or more days ago OR the state is not “active”
        Warning:
          - The last connection was more than one day ago AND the state is “active”
        Healthy:
          - The last connection was less than one day ago AND the state is “active”

        When multiple connectors exist, the group's status is the least healthy status among them.

    .PARAMETER NdesConnectors
        The object returned by Get-NdesConnectors

    .EXAMPLE
        $ndesConnectors = Get-NdesConnectors -AccessToken <AccessToken>
        Get-IntuneNdesConnectorsStatus -NdesConnectors $ndesConnectors

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [psobject] $NdesConnectors
    )

    if ($null -eq $NdesConnectors -or (@($NdesConnectors).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName = 'NDES Connectors'
            status        = 'Not Enabled'
        }
    }

    $items = @($NdesConnectors)

    $now = Get-Date
    $rank = @{ unknown = 0; healthy = 1; warning = 2; unhealthy = 3 }
    $worst = 'unknown'

    foreach ($c in $items) {
        $state = $null
        if ($c.PSObject.Properties.Name -contains 'state' -and $c.state) {
            try { 
                $state = $c.state.ToString().ToLowerInvariant() 
            } 
            catch { 
                $state = $null 
            }
        }

        $lastConnectionDateTime = $null
        if ($c.PSObject.Properties.Name -contains 'lastConnectionDateTime' -and $c.lastConnectionDateTime) {
            try { 
                $lastConnectionDateTime = [datetime]$c.lastConnectionDateTime 
            } 
            catch { 
                $lastConnectionDateTime = $null 
            }
        }

        $status = 'unknown'
        $isActive = ($state -eq 'active')

        if (-not $isActive -and $state) {
            $status = 'unhealthy'
        }
        elseif ($isActive -and $lastConnectionDateTime) {
            $ageDays = ($now - $lastConnectionDateTime).TotalDays
            if ($ageDays -ge 3) { $status = 'unhealthy' }
            elseif ($ageDays -gt 1) { $status = 'warning' }
            else { $status = 'healthy' }
        }

        if ($rank[$status] -gt $rank[$worst]) { $worst = $status }
        if ($worst -eq 'unhealthy') { break }
    }

    return [pscustomobject][ordered]@{
        connectorName = 'ndesConnectorLastConnectionDateTime'
        status        = $worst
    }
}