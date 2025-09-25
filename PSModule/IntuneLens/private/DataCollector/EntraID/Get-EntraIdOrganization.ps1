function Get-EntraIdOrganization {
    <#
    .SYNOPSIS
        Gets Entra ID organization details.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /organization and returns 
        organization details for the current tenant.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdOrganization -AccessToken <AccessToken>

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
    $endpoint = "$base/organization"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,displayName,tenantType,onPremisesSyncEnabled"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers

    $org = $resp.value | Select-Object -First 1

    if (-not $org) {
        return $null
    }

    $result = [pscustomobject]@{
        id                    = $org.id
        displayName           = $org.displayName
        tenantType            = $org.tenantType
        onPremisesSyncEnabled = $org.onPremisesSyncEnabled
    }

    return $result
}