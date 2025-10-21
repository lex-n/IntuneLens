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
    [OutputType([pscustomobject])]
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

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        return [pscustomobject]@{
            success                         = $resp.success
            mobileDeviceManagementAuthority = if ($resp.data -and $resp.data.mobileDeviceManagementAuthority) {
                $resp.data.mobileDeviceManagementAuthority
            }
            else { 'N/A' }
        }
    }
}