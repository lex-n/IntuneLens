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
        [Parameter(Mandatory = $true)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/reports/azureADPremiumLicenseInsight"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers

    return [pscustomobject]@{
        entitledP1LicenseCount                 = $resp.entitledP1LicenseCount
        entitledP2LicenseCount                 = $resp.entitledP2LicenseCount
        entitledTotalLicenseCount              = $resp.entitledTotalLicenseCount
        p1ConditionalAccessUsers               = $resp.p1FeatureUtilizations.conditionalAccess.userCount
        p1ConditionalAccessGuestUsers          = $resp.p1FeatureUtilizations.conditionalAccessGuestUsers.userCount
        p2RiskBasedConditionalAccessUsers      = $resp.p2FeatureUtilizations.riskBasedConditionalAccess.userCount
        p2RiskBasedConditionalAccessGuestUsers = $resp.p2FeatureUtilizations.riskBasedConditionalAccessGuestUsers.userCount
    }
}