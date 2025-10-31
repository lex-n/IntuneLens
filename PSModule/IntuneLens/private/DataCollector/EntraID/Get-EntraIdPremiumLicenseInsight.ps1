function Get-EntraIdPremiumLicenseInsight {
    <#
    .SYNOPSIS
        Gets Microsoft Entra ID Premium License Insight.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /reports/azureADPremiumLicenseInsight
        to retrieve information about the tenant’s Microsoft Entra ID license 
        entitlements and feature utilization. 
    
    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdPremiumLicenseInsight -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/reports/azureADPremiumLicenseInsight"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        return [pscustomobject]@{
            success                                = $resp.success
            entitledP1LicenseCount                 = if ($resp.data -and $resp.data.entitledP1LicenseCount) {
                $resp.data.entitledP1LicenseCount
            }
            else { 0 }

            entitledP2LicenseCount                 = if ($resp.data -and $resp.data.entitledP2LicenseCount) {
                $resp.data.entitledP2LicenseCount
            }
            else { 0 }

            entitledTotalLicenseCount              = if ($resp.data -and $resp.data.entitledTotalLicenseCount) {
                $resp.data.entitledTotalLicenseCount
            }
            else { 0 }

            p1ConditionalAccessUsers               = if ($resp.data -and $resp.data.p1FeatureUtilizations.conditionalAccess.userCount) {
                $resp.data.p1FeatureUtilizations.conditionalAccess.userCount
            }
            else { 0 }

            p1ConditionalAccessGuestUsers          = if ($resp.data -and $resp.data.p1FeatureUtilizations.conditionalAccessGuestUsers.userCount) {
                $resp.data.p1FeatureUtilizations.conditionalAccessGuestUsers.userCount
            }
            else { 0 }

            p2RiskBasedConditionalAccessUsers      = if ($resp.data -and $resp.data.p2FeatureUtilizations.riskBasedConditionalAccess.userCount) {
                $resp.data.p2FeatureUtilizations.riskBasedConditionalAccess.userCount
            }
            else { 0 }

            p2RiskBasedConditionalAccessGuestUsers = if ($resp.data -and $resp.data.p2FeatureUtilizations.riskBasedConditionalAccessGuestUsers.userCount) {
                $resp.data.p2FeatureUtilizations.riskBasedConditionalAccessGuestUsers.userCount
            }
            else { 0 }
        }
    }
}