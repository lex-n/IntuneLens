function Get-IntuneManagedGooglePlayAppStatus {
    <#
    .SYNOPSIS
        Analyzes Managed Google Play App Sync health status.

    .DESCRIPTION
        Determines Managed Google Play App Sync health status.
        Unhealthy:
          - The last synchronization was three or more days ago OR the sync status is not “success”
        Warning:
          - The last synchronization was more than one day ago AND the sync status is “success”
        Healthy:
          - The last synchronization was less than one day ago AND the sync status is “success”

    .PARAMETER ManagedGooglePlaySettings
        The object returned by Get-ManagedGooglePlaySettings.

    .EXAMPLE
        $managedGooglePlaySettings = Get-ManagedGooglePlaySettings -AccessToken <AccessToken>
        Get-IntuneManagedGooglePlayAppStatus -ManagedGooglePlaySettings $managedGooglePlaySettings

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $ManagedGooglePlaySettings
    )

    if ($null -eq $ManagedGooglePlaySettings -or (@($ManagedGooglePlaySettings).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName       = 'Managed Google Play App'
            connectorInstanceId = $null
            status              = 'Not Enabled'
            eventDateTime       = $null
        }
    }

    $now = Get-Date
    $status = 'unknown'

    $lastAppSyncDateTime = $null
    if ($ManagedGooglePlaySettings.lastAppSyncDateTime) {
        try { 
            $lastAppSyncDateTime = [datetime]$ManagedGooglePlaySettings.lastAppSyncDateTime 
        } 
        catch { 
            $lastAppSyncDateTime = $null 
        }
    }

    $rawStatus = $ManagedGooglePlaySettings.lastAppSyncStatus
    $statusNorm = if ($rawStatus) { $rawStatus.ToString().ToLowerInvariant() } else { $null }
    $isSuccess = ($statusNorm -eq 'success')

    if ($lastAppSyncDateTime -and $statusNorm) {
        $ageDays = ($now - $lastAppSyncDateTime).TotalDays

        if (-not $isSuccess) {
            $status = 'unhealthy'
        }
        elseif ($ageDays -ge 3) {
            $status = 'unhealthy'
        }
        elseif ($ageDays -gt 1) {
            $status = 'warning'
        }
        else {
            $status = 'healthy'
        }
    }
    else {
        $status = 'unknown'
    }

    return [pscustomobject][ordered]@{
        connectorName       = 'googlePlayAppLastSyncDateTime'
        connectorInstanceId = $ManagedGooglePlaySettings.id
        status              = $status
        eventDateTime       = $ManagedGooglePlaySettings.lastAppSyncDateTime
    }
}