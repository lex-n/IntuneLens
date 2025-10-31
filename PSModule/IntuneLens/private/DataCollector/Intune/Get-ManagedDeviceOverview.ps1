function Get-ManagedDeviceOverview {
    <#
    .SYNOPSIS
        Gets the managed device overview.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/managedDeviceOverview
        and returns managed device overview for the current tenant.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-ManagedDeviceOverview -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/managedDeviceOverview"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        return [pscustomobject]@{
            success                      = $resp.success
            enrolledDeviceCount          = if ($resp.data -and $resp.data.enrolledDeviceCount) {
                $resp.data.enrolledDeviceCount
            }
            else { 0 }

            mdmEnrolledCount             = if ($resp.data -and $resp.data.mdmEnrolledCount) {
                $resp.data.mdmEnrolledCount
            }
            else { 0 }

            dualEnrolledDeviceCount      = if ($resp.data -and $resp.data.dualEnrolledDeviceCount) {
                $resp.data.dualEnrolledDeviceCount
            }
            else { 0 }

            deviceOperatingSystemSummary = if ($resp.data -and $resp.data.deviceOperatingSystemSummary) {
                $resp.data.deviceOperatingSystemSummary
            }
            else { 'N/A' }

            windowsCount                 = if ($resp.data.deviceOperatingSystemSummary -and $resp.data.deviceOperatingSystemSummary.windowsCount) {
                $resp.data.deviceOperatingSystemSummary.windowsCount
            }
            else { 0 }

            windowsMobileCount           = if ($resp.data.deviceOperatingSystemSummary -and $resp.data.deviceOperatingSystemSummary.windowsMobileCount) {
                $resp.data.deviceOperatingSystemSummary.windowsMobileCount
            }
            else { 0 }

            iOSCount                     = if ($resp.data.deviceOperatingSystemSummary -and $resp.data.deviceOperatingSystemSummary.iosCount) {
                $resp.data.deviceOperatingSystemSummary.iosCount
            }
            else { 0 }

            macOSCount                   = if ($resp.data.deviceOperatingSystemSummary -and $resp.data.deviceOperatingSystemSummary.macOSCount) {
                $resp.data.deviceOperatingSystemSummary.macOSCount
            }
            else { 0 }

            androidCount                 = if ($resp.data.deviceOperatingSystemSummary -and $resp.data.deviceOperatingSystemSummary.androidCount) {
                $resp.data.deviceOperatingSystemSummary.androidCount
            }
            else { 0 }

            linuxCount                   = if ($resp.data.deviceOperatingSystemSummary -and $resp.data.deviceOperatingSystemSummary.linuxCount) {
                $resp.data.deviceOperatingSystemSummary.linuxCount
            }
            else { 0 }
        }
    }
}