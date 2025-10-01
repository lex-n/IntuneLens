function Get-EntraIdSecurityDefaultsPolicy {
    <#
    .SYNOPSIS
        Gets the Security Defaults policy.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /policies/identitySecurityDefaultsEnforcementPolicy
        and returns Security Defaults policy information.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdSecurityDefaultsPolicy -AccessToken <AccessToken>
    
    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/policies/identitySecurityDefaultsEnforcementPolicy"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    return $resp
}