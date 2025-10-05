function Get-IntuneAddOnsStatus {
    <#
    .SYNOPSIS
        Calculates purchased and consumed quantities for Intune add-ons.

    .DESCRIPTION
        Analyzes the subscribed SKUs and calculates purchased and 
        consumed quantities for Intune add-ons.
    
    .PARAMETER SubscribedSkus
        The collection returned by Get-SubscribedSkus.

    .EXAMPLE
        $skus = Get-SubscribedSkus -AccessToken <AccessToken>
        $intuneAddOns = Get-IntuneAddOnsStatus -SubscribedSkus $skus

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [object[]] $SubscribedSkus
    )

    $addOnPatterns = @(
        @{ Name = 'Intune Suite'; Pattern = '^Microsoft_Intune_Suite$' },
        @{ Name = 'Intune Plan 2'; Pattern = '^Microsoft_Intune_Plan_2$' },
        @{ Name = 'Endpoint Privilege Management'; Pattern = '^Microsoft_Intune_Endpoint_Privilege_Management$' },
        @{ Name = 'Enterprise App Management'; Pattern = '^Intune_Enterprise_Application_Management$' },
        @{ Name = 'Advanced Analytics'; Pattern = '^Microsoft_Intune_Advanced_Analytics$' },
        @{ Name = 'Cloud PKI'; Pattern = '^Microsoft_Cloud_PKI$' },
        @{ Name = 'Remote Help'; Pattern = '^Remote_Help' }
    )

    $result = [ordered]@{}
    foreach ($a in $addOnPatterns) {
        $result[$a.Name] = [pscustomobject]@{
            purchased = 0
            consumed  = 0
        }
    }

    foreach ($sku in $SubscribedSkus) {
        $skuPartNumber = [string]$sku.skuPartNumber
        foreach ($a in $addOnPatterns) {
            if ($skuPartNumber -match $a.Pattern) {
                $result[$a.Name].purchased += [int]$sku.prepaidUnits.enabled
                $result[$a.Name].consumed += [int]$sku.consumedUnits
                break
            }
        }
    }

    return [pscustomobject]$result
}