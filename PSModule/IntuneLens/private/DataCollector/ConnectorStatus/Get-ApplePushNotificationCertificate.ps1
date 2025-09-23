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

    $url = "$endpoint`?`$select=expirationDateTime"

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        $expirationDateTime = $null
        if ($resp.PSObject.Properties.Name -contains 'expirationDateTime' -and $resp.expirationDateTime) {
            $expirationDateTime = [datetime]$resp.expirationDateTime
        }

        return [pscustomobject]@{
            expirationDateTime = $expirationDateTime
        }
    }
    catch {
        $statusCode = $null
        try {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                $statusCode = $_.Exception.Response.StatusCode.value__
            }
        }
        catch { }

        if ($statusCode -eq 404) {
            return [pscustomobject]@{
                expirationDateTime = $null
            }
        }

        throw
    }
}