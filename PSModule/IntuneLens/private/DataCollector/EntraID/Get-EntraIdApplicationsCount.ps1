function Get-EntraIdApplicationsCount {
    <#
    .SYNOPSIS
        Gets total number of Entra ID applications.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /applications/$count
        and returns the total number of Entra ID applications.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdApplicationsCount -AccessToken <AccessToken>

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
    $endpoint = "$base/applications/"
    $headers = @{
        Authorization    = "Bearer $AccessToken"
        ConsistencyLevel = "eventual"
        Accept           = "text/plain"
    }

    $url = "$endpoint`$count"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers
    return [int]$resp
}