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

    $Data = [pscustomobject]@{
        ActiveIncidents        = $Overview.IntuneActiveIncidents.Total
        ActiveAdvisories       = $Overview.IntuneActiveAdvisories.Total
        ActionRequiredMessages = $Overview.IntuneActionRequiredMessages.Total
    }

    New-IntuneLensSection -Title 'Intune Service Status' -Data $Data
}