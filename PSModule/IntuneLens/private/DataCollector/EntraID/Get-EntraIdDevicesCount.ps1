function Get-EntraIdDevicesCount {
    <#
    .SYNOPSIS
        Gets total number of Entra ID devices.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /devices/$count
        and returns the total number of Entra ID devices.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdDevicesCount -AccessToken <AccessToken>

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
    $endpoint = "$base/devices/"
    $headers = @{
        Authorization    = "Bearer $AccessToken"
        ConsistencyLevel = "eventual"
        Accept           = "text/plain"
    }

    $url = "$endpoint`$count"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers
    return [int]$resp
}