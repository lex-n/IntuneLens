function Build-IntuneConnectorStatusSection {
    <#
    .SYNOPSIS
        Accepts the connectors overview object from Get-IntuneConnectorStatus
        and builds a report section.

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Overview
    )

    $Data = [pscustomobject]@{
        APNSExpiryDate = $Overview.APNSExpiryDate
    }

    New-IntuneLensSection -Title 'Intune Connector Status' -Data $Data
}