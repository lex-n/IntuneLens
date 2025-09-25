function Get-EntraIdGroupsCount {
    <#
    .SYNOPSIS
        Gets total number of Entra ID groups.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /groups/$count
        and returns the total number of Entra ID groups.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdGroupsCount -AccessToken <AccessToken>

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
    $endpoint = "$base/groups/"
    $headers = @{
        Authorization    = "Bearer $AccessToken"
        ConsistencyLevel = "eventual"
        Accept           = "text/plain"
    }

    $url = "$endpoint`$count"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers
    return [int]$resp
}