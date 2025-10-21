function Get-IntuneSubscriptionState {
    <#
    .SYNOPSIS
        Gets the Intune subscription state.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/subscriptionState
        and returns the Intune subscription state (e.g., active, pending, etc.).

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-IntuneSubscriptionState -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/subscriptionState"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        return [pscustomobject]@{
            success           = $resp.success
            subscriptionState = if ($resp.data -and $resp.data.value) {
                $resp.data.value
            }
            else { 'N/A' }
        }
    }
}