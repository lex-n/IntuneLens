function Get-EntraIdLicenseLevel {
    <#
    .SYNOPSIS
        Gets the Entra ID license level from license insight.

    .DESCRIPTION
        Evaluates the entitlement counts returned by Get-EntraIdPremiumLicenseInsight
        and determines the Entra ID license level (Free, P1, or P2) for the tenant.
            
    .PARAMETER Insight
        The object returned by Get-EntraIdPremiumLicenseInsight.

    .EXAMPLE
        $insight = Get-EntraIdPremiumLicenseInsight -AccessToken <AccessToken>
        $licenseLevel = Get-EntraIdLicenseLevel -Insight $insight

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
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