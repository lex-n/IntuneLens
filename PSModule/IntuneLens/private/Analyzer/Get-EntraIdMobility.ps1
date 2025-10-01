function Get-EntraIdMobility {
    <#
    .SYNOPSIS
        Analyzes the Entra Mobility (MDM & WIP) providers.

    .DESCRIPTION
        Checks if Microsoft Intune is configured as a provider in Entra Mobility (MDM and WIP).
        If it is, returns the configured user scope for MDM and WIP.

    .PARAMETER MdmPolicy
        The object returned by Get-EntraIdMdmPolicies.

    .PARAMETER MamPolicy
        The object returned by EntraIdMamPolicies.

    .EXAMPLE
        $mdm = Get-EntraIdMdmPolicies -AccessToken <AccessToken>
        $mam = Get-EntraIdMamPolicies -AccessToken <AccessToken>
        $mobility = Get-EntraIdMobility -MdmPolicy $mdm -MamPolicy $mam

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $MdmPolicy,

        [Parameter()]
        [pscustomobject] $MamPolicy
    )

    $mdmScope = if ($null -ne $MdmPolicy -and $MdmPolicy.displayName -eq 'Microsoft Intune' -and $MdmPolicy.appliesTo) {
        $MdmPolicy.appliesTo
    }
    else { 'N/A' }

    $mamScope = if ($null -ne $MamPolicy -and $MamPolicy.displayName -eq 'Microsoft Intune' -and $MamPolicy.appliesTo) {
        $MamPolicy.appliesTo
    }
    else { 'N/A' }

    $hasIntune = ($mdmScope -ne 'N/A') -or ($mamScope -ne 'N/A')

    return [pscustomobject][ordered]@{
        hasMicrosoftIntune = [bool]$hasIntune
        mdmAppliesTo       = $mdmScope
        mamAppliesTo       = $mamScope
    }
}