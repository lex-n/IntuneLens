function Get-EntraIdBrandingConfigStatus {
    <#
    .SYNOPSIS
        Checks if Microsoft Entra ID company branding is configured.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /organization/{organizationId}/branding
        and returns the company branding configuration status "Configured"/"Not configured".

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .PARAMETER OrganizationId
        The organization (tenant) ID returned by Get-EntraIdOrganization (required).

    .EXAMPLE
        $org = Get-EntraIdOrganization -AccessToken <AccessToken>
        $status = Get-EntraIdBrandingConfigStatus -AccessToken <AccessToken> -OrganizationId $org.id
    
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
    $endpoint = "$base/organization/$OrganizationId/branding"
    $headers = @{
        Authorization     = "Bearer $AccessToken"
        "Accept-Language" = "0"
    }

    $url = $endpoint

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
        return "Configured"
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            return "Not configured"
        }
        else {
            Write-Verbose "Unexpected error: $_"
            return "Unknown"
        }
    }
}