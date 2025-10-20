function Get-IntuneWindowsAutopilotStatus {
    <#
    .SYNOPSIS
        Analyzes Windows Autopilot health status.

    .DESCRIPTION
        Determines Windows Autopilot health status.
        Unhealthy:
          - The last synchronization was three or more days ago OR the syncStatus is not “completed”
        Warning:
          - The last synchronization was more than one day ago AND the syncStatus is “completed”
        Healthy:
          - The last synchronization was less than one day ago AND the syncStatus is “completed” or "inProgress"

    .PARAMETER WindowsAutopilotSettings
        The object returned by Get-WindowsAutopilotSettings

    .EXAMPLE
        $windowsAutopilotSettings = Get-WindowsAutopilotSettings -AccessToken <AccessToken>
        Get-IntuneWindowsAutopilotStatus -WindowsAutopilotSettings $windowsAutopilotSettings

    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $WindowsAutopilotSettings
    )

    if ($null -eq $WindowsAutopilotSettings -or (@($WindowsAutopilotSettings).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName       = 'Windows Autopilot'
            connectorInstanceId = $null
            status              = 'Not Enabled'
            eventDateTime       = $null
        }
    }

    $now = Get-Date
    $status = 'unknown'

    $lastSyncDateTime = $null
    if ($WindowsAutopilotSettings.lastSyncDateTime) {
        try { 
            $lastSyncDateTime = [datetime]$WindowsAutopilotSettings.lastSyncDateTime 
        } 
        catch { 
            $lastSyncDateTime = $null 
        }
    }

    $syncStatusRaw = $WindowsAutopilotSettings.syncStatus
    $statusNorm = if ($syncStatusRaw) { $syncStatusRaw.ToString().ToLowerInvariant() } else { $null }
    $isCompleted = ($statusNorm -eq 'completed')
    $isInProgress = ($statusNorm -eq 'inprogress')

    if ($lastSyncDateTime) {
        $ageDays = ($now - $lastSyncDateTime).TotalDays
        if ($ageDays -lt 1 -and ($isCompleted -or $isInProgress)) { $status = 'healthy' }
        elseif ($ageDays -gt 1 -and $isCompleted) { $status = 'warning' } 
        elseif ($ageDays -ge 3 -or -not $isCompleted) { $status = 'unhealthy' }
    }

    return [pscustomobject][ordered]@{
        connectorName       = 'windowsAutopilotLastSyncDateTime'
        connectorInstanceId = $WindowsAutopilotSettings.id
        status              = $status
        eventDateTime       = $lastSyncDateTime
    }
}