function Get-IntuneTotalLicensedUsers {
    <#
    .SYNOPSIS
        Calculates the total number of Intune licensed users.

    .DESCRIPTION
        Calculates the total number of Intune licensed users using 
        information about service SKUs that a company is subscribed to.

    .PARAMETER SubscribedSkus
        The collection returned by Get-SubscribedSkus.

    .EXAMPLE
        $skus = Get-SubscribedSkus -AccessToken <AccessToken>
        $totalLicensedUsers = Get-IntuneTotalLicensedUsers -SubscribedSkus $skus

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [object[]] $SubscribedSkus
    )

    $isEligible = {
        param($spName)
        if (-not $spName) { return $false }
        return ($spName -match '^INTUNE_' -and
            -not ($spName -match '^INTUNE_O365') -and
            -not ($spName -match '^INTUNE_DEFENDER'))
    }

    $total = 0
    foreach ($sku in $SubscribedSkus) {
        $plans = @($sku.servicePlans)
        if ($plans | Where-Object { & $isEligible $_.servicePlanName }) {
            $total += [int]$sku.consumedUnits
        }
    }

    return [int]$total
}