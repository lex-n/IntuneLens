function Get-IntuneLensHealthReport {
    <#
    .SYNOPSIS
        Builds the IntuneLens health report for the current tenant.

    .DESCRIPTION
        Get-IntuneLensHealthReport orchestrates collection and analysis to produce a typed
        [IntuneLensReport] object. The report contains one or more sections (IntuneLensSection),
        each holding analyzed, human-centric data (not raw Graph payloads).

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph.

    .PARAMETER All
        Fetch all pages from Graph endpoints used during the run (where supported).

    .PARAMETER Top
        Page size for the first request to Graph (where supported). Defaults to 200.

    .EXAMPLE
        $report = Get-IntuneLensHealthReport
    
    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    [OutputType('IntuneLensReport')]
    param(
        [string] $AccessToken,
        [switch] $All,   # fetch all pages by default
        [int]    $Top = 200
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # AccessToken
    if (-not $AccessToken) {
        if ($script:IntuneLensContext -and $script:IntuneLensContext.AccessToken) {
            # Check if the stored token is still valid (5 min skew buffer)
            $now = Get-Date
            $limit = $now.AddMinutes(5)

            if ($script:IntuneLensContext.ExpiresOn -le $limit) {
                throw "The stored access token has expired or is about to expire. Run Connect-IntuneLens again."
            }

            $AccessToken = $script:IntuneLensContext.AccessToken
        }
        else {
            throw "No AccessToken available. Run Connect-IntuneLens first."
        }
    }

    $devices = Get-IntuneDevices -AccessToken $AccessToken -Top $Top -All:$All
    $deviceOverview = Get-IntuneDeviceOverview -Devices $devices
    $deviceOverviewSection = Build-IntuneDeviceOverviewSection -Overview $deviceOverview

    $intuneActiveIncidents = Get-IntuneActiveIncidents -AccessToken $AccessToken
    $intuneActiveAdvisories = Get-IntuneActiveAdvisories -AccessToken $AccessToken
    $intuneActionRequiredMessages = Get-IntuneActionRequiredMessages -AccessToken $AccessToken
    $intuneServiceStatus = Get-IntuneServiceStatus -Incidents $intuneActiveIncidents -Advisories $intuneActiveAdvisories -Messages $intuneActionRequiredMessages
    $intuneServiceStatusSection = Build-IntuneServiceStatusSection -Overview $intuneServiceStatus

    $apns = Get-ApplePushNotificationCertificate -AccessToken $AccessToken
    $vpp = Get-VppTokens -AccessToken $AccessToken
    $intuneConnectorStatus = Get-IntuneConnectorStatus -ApplePushNotificationCertificate $apns -VppTokens $vpp
    $intuneConnectorStatusSection = Build-IntuneConnectorStatusSection -Overview $intuneConnectorStatus


    $report = [IntuneLensReport]::new()
    $report.CollectedAt = Get-Date
    $report.Sections = @(
        $deviceOverviewSection,
        $intuneServiceStatusSection,
        $intuneConnectorStatusSection
    )

    return $report
}