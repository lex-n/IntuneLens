function Get-EntraIdDefaultDomain {
    <#
    .SYNOPSIS
        Gets the default Entra ID domain.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /domains
        and returns the default domain.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdDefaultDomain -AccessToken <AccessToken>
        
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
    $endpoint = "$base/domains"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,isDefault"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    $default = $resp.value | Where-Object { $_.isDefault -eq $true } | Select-Object -First 1

    if (-not $default) {
        return $null
    }

    $result = [pscustomobject]@{
        id        = $default.id
        isDefault = [bool]$default.isDefault
    }

    return $result
}