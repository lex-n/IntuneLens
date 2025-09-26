function Get-MdmAuthority {
    <#
    .SYNOPSIS
        Gets the tenant's MDM authority.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint
        /organization/{organizationId}?$select=mobileDeviceManagementAuthority
        and returns the current MDM authority.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .PARAMETER OrganizationId
        The organization (tenant) ID returned by Get-EntraIdOrganization (required).

    .EXAMPLE
        $org = Get-EntraIdOrganization -AccessToken <AccessToken>
        $mdmAuthority = Get-MdmAuthority -AccessToken <AccessToken> -OrganizationId $org.id
    
    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken,

        [Parameter(Mandatory)]
        [string] $OrganizationId
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/organization/$OrganizationId"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=mobileDeviceManagementAuthority"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    return $resp.mobileDeviceManagementAuthority
}