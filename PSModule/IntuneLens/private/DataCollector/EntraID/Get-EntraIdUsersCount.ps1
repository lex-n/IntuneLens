function Get-EntraIdUsersCount {
    <#
    .SYNOPSIS
        Gets total number of Entra ID users.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /users/$count
        and returns the total number of Entra ID users.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdUsersCount -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/users/"
    $headers = @{
        Authorization    = "Bearer $AccessToken"
        ConsistencyLevel = "eventual"
        Accept           = "text/plain"
    }

    $url = "$endpoint`$count"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers
    return [int]$resp
}