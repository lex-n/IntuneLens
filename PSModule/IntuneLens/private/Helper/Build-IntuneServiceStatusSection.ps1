function Build-IntuneServiceStatusSection {
    <#
    .SYNOPSIS
        Transforms a PSCustomObject from Get-IntuneServiceStatus into an IntuneLensSection.

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Overview
    )

    New-IntuneLensSection -Title 'Intune Service Status' -Data $Overview.IntuneActiveIncidents
}