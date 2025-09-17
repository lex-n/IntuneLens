function Get-IntuneConnectorStatus {
    <#
    .SYNOPSIS
        Builds an overview of Intune connector status.

    .DESCRIPTION
        Accepts connector-specific data objects and produces a simplified overview
        ready for reporting.

    .PARAMETER ApplePushNotificationCertificate
        The object returned by Get-ApplePushNotificationCertificate.

    .EXAMPLE
        $apns = Get-ApplePushNotificationCertificate -AccessToken <AccessToken>
        $overview = Get-IntuneConnectorStatus -ApplePushNotificationCertificate $apns
        $overview.APNSExpiryDate
    
    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [pscustomobject] $ApplePushNotificationCertificate
    )

    $overview = [ordered]@{
        APNSExpiryDate = $null
    }

    if ($ApplePushNotificationCertificate.IsConfigured -and $ApplePushNotificationCertificate.ExpirationDateTime) {
        $overview.APNSExpiryDate = $ApplePushNotificationCertificate.ExpirationDateTime
    }
    else {
        $overview.APNSExpiryDate = "N/A"
    }

    return [pscustomobject]$overview
}