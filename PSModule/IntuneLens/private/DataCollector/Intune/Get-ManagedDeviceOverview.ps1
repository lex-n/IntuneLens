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

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    return [pscustomobject]@{
        enrolledDeviceCount          = $resp.enrolledDeviceCount
        mdmEnrolledCount             = $resp.mdmEnrolledCount
        dualEnrolledDeviceCount      = $resp.dualEnrolledDeviceCount
        deviceOperatingSystemSummary = $resp.deviceOperatingSystemSummary
        windowsCount                 = $resp.deviceOperatingSystemSummary.windowsCount
        windowsMobileCount           = $resp.deviceOperatingSystemSummary.windowsMobileCount
        iOSCount                     = $resp.deviceOperatingSystemSummary.iosCount
        macOSCount                   = $resp.deviceOperatingSystemSummary.macOSCount
        androidCount                 = $resp.deviceOperatingSystemSummary.androidCount
        linuxCount                   = $resp.deviceOperatingSystemSummary.linuxCount
    }
}