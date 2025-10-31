function Get-ApplePushNotificationCertificate {
    <#
    .SYNOPSIS
        Gets the Apple Push Notification (APNs) certificate.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/applePushNotificationCertificate
        to get an Apple MDM push certificate required to manage iOS/iPadOS and macOS devices in Microsoft Intune.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-ApplePushNotificationCertificate -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/applePushNotificationCertificate"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $data = $resp.data

        return [pscustomobject]@{
            success            = $resp.success
            id                 = if ($data -and $data.id) { $data.id } else { 'N/A' }
            expirationDateTime = if ($data -and $data.expirationDateTime) {
                [datetime]$data.expirationDateTime
            }
            else { $null }
        }
    }
}