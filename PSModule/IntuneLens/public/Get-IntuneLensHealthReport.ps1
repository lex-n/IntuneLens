function Get-IntuneLensHealthReport {
    <#
    .SYNOPSIS
        Builds the IntuneLens health report for the current tenant.

    .DESCRIPTION
        Get-IntuneLensHealthReport orchestrates collection and analysis to produce a typed
        [IntuneLensReport] object. It can authenticate on your behalf using -ClientId (device-code flow)
        or reuse an existing -AccessToken. The report contains one or more sections (IntuneLensSection),
        each holding analyzed, human-centric data (not raw Graph payloads).

    .PARAMETER AccessToken
        A bearer token to Microsoft Graph. If provided, -ClientId is not required.

    .PARAMETER ClientId
        Application (client) ID for interactive device-code auth. Required if -AccessToken is not supplied.

    .PARAMETER All
        Fetch all pages from Graph endpoints used during the run (where supported).

    .PARAMETER Top
        Page size for the first request to Graph (where supported). Defaults to 200.

    .EXAMPLE
        $report = Get-IntuneLensHealthReport
        Runs interactive device-code sign-in and returns an [IntuneLensReport].

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


    # Collect
    $devices = Get-IntuneDevices -AccessToken $AccessToken -Top $Top -All:$All

    # Analyze
    $deviceOverview = Get-IntuneDeviceOverview -Devices $devices

    # Wrap analyzed outputs into typed sections
    $secOverview = New-IntuneLensSection -Title 'Device Overview' -Data $deviceOverview

    # Build the typed report
    $report = [IntuneLensReport]::new()
    $report.CollectedAt = Get-Date
    $report.Sections = @(
        $secOverview
    )

    return $report
}