function Get-IntuneServiceStatus {
    <#
    .SYNOPSIS
        Generates an overview of Microsoft Intune service status (incidents, advisories, and action-required messages).

    .DESCRIPTION
        Get-IntuneServiceStatus analyzes Intune service health signals collected from Microsoft Graph and produces
        a structured overview object. It accepts collections of incidents, advisories, and Message center items
        and calculates summary counts.

    .PARAMETER Incidents
        A collection of Intune active incidents, obtained with Get-IntuneActiveIncidents.

    .PARAMETER Advisories
        A collection of Intune active advisories, obtained with Get-IntuneActiveAdvisories.

    .PARAMETER Messages
        A collection of Message center items for Intune service that require action, 
        obtained with Get-IntuneActionRequiredMessages.

    .EXAMPLE
        $inc = Get-IntuneActiveIncidents -AccessToken <AccessToken>
        $adv = Get-IntuneActiveAdvisories -AccessToken <AccessToken>
        $msg = Get-IntuneActionRequiredMessages -AccessToken <AccessToken>

        $status = Get-IntuneServiceStatus -Incidents $inc -Advisories $adv -Messages $msg
        $status.IntuneActiveIncidents.Total
        $status.IntuneActiveAdvisories.Total
        $status.IntuneActionRequiredMessages.Total

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()][AllowNull()][AllowEmptyCollection()][object[]]$Incidents = @(),
        [Parameter()][AllowNull()][AllowEmptyCollection()][object[]]$Advisories = @(),
        [Parameter()][AllowNull()][AllowEmptyCollection()][object[]]$Messages = @()
    )

    if ($null -eq $Incidents) { $Incidents = @() }
    if ($null -eq $Advisories) { $Advisories = @() }
    if ($null -eq $Messages) { $Messages = @() }

    $overview = [pscustomobject]@{
        IntuneActiveIncidents        = [pscustomobject]@{
            Total = $Incidents.Count
        }
        IntuneActiveAdvisories       = [pscustomobject]@{
            Total = $Advisories.Count
        }
        IntuneActionRequiredMessages = [pscustomobject]@{
            Total = $Messages.Count
        }
    }

    return $overview
}