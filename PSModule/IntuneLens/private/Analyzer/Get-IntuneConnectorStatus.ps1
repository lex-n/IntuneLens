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
        $vpp = Get-VppTokens -AccessToken <AccessToken>
        $overview = Get-IntuneConnectorStatus -ApplePushNotificationCertificate $apns -VppTokens $vpp
        $overview.APNSExpiryDate
    
    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()][pscustomobject] $ApplePushNotificationCertificate,
        [Parameter()][pscustomobject[]] $VppTokens
    )

    $overview = [ordered]@{
        APNSExpiryDate   = $null
        VPPExpiryDates   = $null
        VPPLastSyncDates = $null
    }

    if ($ApplePushNotificationCertificate.ExpirationDateTime) {
        $overview.APNSExpiryDate = $ApplePushNotificationCertificate.ExpirationDateTime
    }
    else {
        $overview.APNSExpiryDate = "N/A"
    }

    # VPP: join all tokens' dates as comma-separated strings. If empty -> "N/A"
    $vppExpiryList = @()
    $vppLastSyncList = @()

    if ($VppTokens -and $VppTokens.Count -gt 0) {
        foreach ($t in $VppTokens) {
            $vppExpiryList += (
                if ($t.ExpirationDateTime) { ([datetime]$t.ExpirationDateTime).ToString('o') }
            )
            $vppLastSyncList += (
                if ($t.LastSyncDateTime) { ([datetime]$t.LastSyncDateTime).ToString('o') }
            )
        }
    }

    $vppExpiryJoined = if ($vppExpiryList.Count -gt 0) { ($vppExpiryList -join ', ') } else { 'N/A' }
    $vppLastSyncJoined = if ($vppLastSyncList.Count -gt 0) { ($vppLastSyncList -join ', ') } else { 'N/A' }
    $overview.VPPExpiryDates = $vppExpiryJoined
    $overview.VPPLastSyncDates = $vppLastSyncJoined

    return [pscustomobject]$overview
}