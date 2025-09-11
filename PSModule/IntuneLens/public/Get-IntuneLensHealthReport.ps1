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
        $report = Get-IntuneLensHealthReport -ClientId '00000000-0000-0000-0000-000000000000'
        Runs interactive device-code sign-in and returns an [IntuneLensReport].

    .EXAMPLE
        $ctx = Connect-IntuneLens -ClientId '00000000-0000-0000-0000-000000000000'
        $report = Get-IntuneLensHealthReport -AccessToken $ctx.AccessToken -All
        Reuses an existing token and collects all pages.

    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    [OutputType('IntuneLensReport')]
    param(
        [string] $AccessToken,
        [string] $ClientId,
        [switch] $All,   # fetch all pages by default
        [int]    $Top = 200
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # 1) Token
    if (-not $AccessToken) {
        if (-not $ClientId) { throw "Provide -AccessToken or -ClientId." }
        $ctx = Connect-IntuneLens -ClientId $ClientId
        $AccessToken = $ctx.AccessToken
    }

    # 2) Collect
    $devices = Get-IntuneDevices -AccessToken $AccessToken -Top $Top -All:$All

    # 3) Analyze
    $deviceOverview = Get-IntuneDeviceOverview -Devices $devices

    # 4) Wrap analyzed outputs into typed sections
    $secOverview = New-IntuneLensSection -Title 'Device Overview' -Data $deviceOverview

    # 5) Build the typed report
    $report = [IntuneLensReport]::new()
    $report.CollectedAt = Get-Date
    $report.Sections = @(
        $secOverview
    )

    return $report
}