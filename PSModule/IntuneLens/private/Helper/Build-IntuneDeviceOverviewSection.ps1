function Build-IntuneDeviceOverviewSection {
    <#
    .SYNOPSIS
        Transforms a PSCustomObject from Get-IntuneDeviceOverview into an IntuneLensSection.

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Overview
    )

    $topNode = [pscustomobject]@{
        TotalDevices = $Overview.OperatingSystem.Total
    }

    New-IntuneLensSection -Title 'Device Overview' -Data $topNode -SubSections @(
        (New-IntuneLensSection -Title 'Operating System Overview'  -Data ($Overview.OperatingSystem)),
        (New-IntuneLensSection -Title 'Compliance Status Overview' -Data ($Overview.Compliance))
    )
}