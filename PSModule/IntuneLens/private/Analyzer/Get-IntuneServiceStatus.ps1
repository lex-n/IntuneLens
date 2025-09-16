function Get-IntuneServiceStatus {
    <#
    .SYNOPSIS
        

    .DESCRIPTION
        

    .PARAMETER Incidents
        Array of incident objects as returned by Get-IntuneActiveIncidents.

    .EXAMPLE
        $incidents = Get-IntuneActiveIncidents -AccessToken <AccessToken>
        Get-IntuneServiceStatus -Incidents $incidents

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$Incidents = @()
    )

    if ($null -eq $Incidents) { $Incidents = @() }
    if ($Incidents -isnot [System.Collections.IEnumerable]) { $Incidents = , $Incidents }

    $IntuneActiveIncidents = Measure-IntuneActiveIncidents -Incidents $Incidents

    [pscustomobject]@{
        IntuneActiveIncidents = [pscustomobject]$IntuneActiveIncidents
    }
}

function Measure-IntuneActiveIncidents {
    <#
    .SYNOPSIS
        Counts active Microsoft Intune incidents for the tenant.
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$Incidents = @()
    )

    if ($null -eq $Incidents) { $Incidents = @() }

    return [pscustomobject]@{
        ActiveIncidents = $Incidents.Count
    }
}