function Get-SubscribedSkus {
    <#
    .SYNOPSIS
        Gets the tenant’s subscribed SKUs (licenses) from Microsoft Graph.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /subscribedSkus 
        and returns the tenant’s subscribed SKUs (licenses).

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-SubscribedSkus -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/subscribedSkus"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    if ($null -eq $resp.value -or $resp.value.Count -eq 0) {
        return @()
    }

    $items = @()
    foreach ($r in @($resp.value)) {
        $items += [pscustomobject]@{
            accountName      = $r.accountName
            accountId        = if ($r.accountId) { [Guid]$r.accountId } else { $null }
            appliesTo        = $r.appliesTo
            capabilityStatus = $r.capabilityStatus
            consumedUnits    = [int]$r.consumedUnits
            id               = $r.id
            skuId            = if ($r.skuId) { [Guid]$r.skuId } else { $null }
            skuPartNumber    = $r.skuPartNumber
            subscriptionIds  = @($r.subscriptionIds)
            prepaidUnits     = [pscustomobject]@{
                enabled   = [int]$r.prepaidUnits.enabled
                suspended = [int]$r.prepaidUnits.suspended
                warning   = [int]$r.prepaidUnits.warning
                lockedOut = [int]$r.prepaidUnits.lockedOut
            }
            servicePlans     = @(
                foreach ($sp in @($r.servicePlans)) {
                    [pscustomobject]@{
                        servicePlanId      = if ($sp.servicePlanId) { [Guid]$sp.servicePlanId } else { $null }
                        servicePlanName    = $sp.servicePlanName
                        servicePlanType    = $sp.servicePlanType
                        provisioningStatus = $sp.provisioningStatus
                        appliesTo          = $sp.appliesTo
                    }
                }
            )
        }
    }

    return $items   
}