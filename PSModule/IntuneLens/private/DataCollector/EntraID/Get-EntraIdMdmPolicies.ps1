function Get-EntraIdMdmPolicies {
    <#
    .SYNOPSIS
        Gets Mobile Device Management (MDM) policies.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /policies/mobileDeviceManagementPolicies and
        returns Mobile Device Management (MDM) policies.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-EntraIdMdmPolicies -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev        
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)]
        [string] $AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/policies/mobileDeviceManagementPolicies"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$filter=displayName eq 'Microsoft Intune'&`$select=displayName,appliesTo,isValid"

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    if ($resp.value.Count -gt 0) {
        return [pscustomobject]@{
            displayName = $resp.value[0].displayName
            appliesTo   = $resp.value[0].appliesTo
            isValid     = $resp.value[0].isValid
        }
    }
    else {
        return $null
    }
}