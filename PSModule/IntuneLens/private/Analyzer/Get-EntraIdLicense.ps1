function Get-EntraIdLicense {
    <#
    .SYNOPSIS
        Gets the Entra ID license level from license insight.

    .DESCRIPTION
        Evaluates the entitlement counts returned by Get-EntraIdPremiumLicenseInsight
        and determines the Entra ID license level for the tenant.
            
    .PARAMETER Insight
        The object returned by Get-EntraIdPremiumLicenseInsight.

    .EXAMPLE
        $insight = Get-EntraIdPremiumLicenseInsight -AccessToken <AccessToken>
        $license = Get-EntraIdLicense -Insight $insight
        $license
        Returns 'Microsoft Entra ID P2' or 'Microsoft Entra ID P1' or 'Microsoft Entra ID Free'

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject] $Insight
    )

    $p2 = 0
    if ($null -ne $Insight.entitledP2LicenseCount) {
        $p2 = [int]$Insight.entitledP2LicenseCount
    }

    $p1 = 0
    if ($null -ne $Insight.entitledP1LicenseCount) {
        $p1 = [int]$Insight.entitledP1LicenseCount
    }

    if ($p2 -gt 0) { return "Microsoft Entra ID P2" }
    if ($p1 -gt 0) { return "Microsoft Entra ID P1" }
    return "Microsoft Entra ID Free"
}