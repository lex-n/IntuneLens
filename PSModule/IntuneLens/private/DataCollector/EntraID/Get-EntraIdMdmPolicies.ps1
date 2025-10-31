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

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        if ($resp.data.value.Count -gt 0) {
            return [pscustomobject]@{
                success     = $resp.success
                displayName = $resp.data.value[0].displayName
                appliesTo   = $resp.data.value[0].appliesTo
                isValid     = $resp.data.value[0].isValid
            }
        }
        else {
            return [pscustomobject]@{
                success     = $resp.success
                displayName = 'N/A'
                appliesTo   = 'N/A'
                isValid     = 'N/A'
            }
        }
    }
}