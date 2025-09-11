function New-IntuneLensSection {
    <#
    .SYNOPSIS
        Creates a new IntuneLensSection object.

    .DESCRIPTION
        Helper that wraps data into an [IntuneLensSection] with Title, Data, and optional SubSections.
        Used by orchestrators and analyzers when building IntuneLensReport.

    .PARAMETER Title
        Section title.

    .PARAMETER Data
        Section data (any object).

    .PARAMETER SubSections
        Optional nested IntuneLensSection[].

    .EXAMPLE
        $ctx = Connect-IntuneLens -ClientId '00000000-0000-0000-0000-000000000000'
        $devices = Get-IntuneDevices -AccessToken $ctx.AccessToken -All
        $overview = Get-IntuneDeviceOverview -Devices $devices
        $section  = New-IntuneLensSection -Title 'Device Overview' -Data $overview

        This example connects to Intune, collects managed devices, computes the device overview,
        and wraps it in an IntuneLensSection ready to add to the report.
        
    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([IntuneLensSection])]
    param(
        [Parameter(Mandatory)][string] $Title,
        [Parameter(Mandatory)][object] $Data,
        [IntuneLensSection[]] $SubSections
    )
    
    $s = [IntuneLensSection]::new()
    $s.Title = $Title
    $s.Data = $Data
    $s.SubSections = $SubSections
    return $s
}