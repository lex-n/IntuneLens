function Get-IntuneApnsStatus {
    <#
    .SYNOPSIS
        Analyzes Apple Push Notification Service (APNS) certificate health status.

    .DESCRIPTION
        Determines Apple Push Notification Service (APNS) certificate health status.
        Unhealthy:
          - The certificate has expired
        Warning:
          - The certificate will expire within seven days
        Healthy:
          - The certificate won't expire within the next seven days

    .PARAMETER ApplePushNotificationCertificate
        The object returned by Get-ApplePushNotificationCertificate.

    .EXAMPLE
        $apns = Get-ApplePushNotificationCertificate -AccessToken <AccessToken>
        Get-IntuneApnsStatus -ApplePushNotificationCertificate $apns

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $ApplePushNotificationCertificate
    )

    if ($null -eq $ApplePushNotificationCertificate -or (@($ApplePushNotificationCertificate).Count -eq 0)) {
        return [pscustomobject][ordered]@{
            connectorName       = 'APNS certificate'
            connectorInstanceId = $null
            status              = 'Not Enabled'
            eventDateTime       = $null
        }
    }

    $now = Get-Date
    $status = 'unknown'

    $expirationDateTime = $null
    if ($ApplePushNotificationCertificate.expirationDateTime) {
        try { 
            $expirationDateTime = [datetime]$ApplePushNotificationCertificate.expirationDateTime 
        }
        catch { 
            $expirationDateTime = $null 
        }
    }

    if ($expirationDateTime) {
        $daysToExpire = ($expirationDateTime - $now).TotalDays
        if ($daysToExpire -lt 0) { $status = 'unhealthy' }
        elseif ($daysToExpire -le 7) { $status = 'warning' }
        else { $status = 'healthy' }
    }

    return [pscustomobject][ordered]@{
        connectorName       = 'applePushNotificationServiceExpirationDateTime'
        connectorInstanceId = $ApplePushNotificationCertificate.id
        status              = $status
        eventDateTime       = $ApplePushNotificationCertificate.expirationDateTime
    }
}