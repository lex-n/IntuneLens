function Get-IntuneDepTokensStatus {
    <#
    .SYNOPSIS
        Analyzes Apple DEP (Device Enrollment Program) tokens health status.

    .DESCRIPTION
        Determines Apple DEP (Device Enrollment Program) tokens health status.

        For each DEP token, evaluates:
        1) Expiration
        Unhealthy:
          - The token has expired
        Warning:
          - The token will expire within seven days
        Healthy:
          - The token won't expire within the next seven days

        2) Last sync
        Unhealthy:
          - The last synchronization was three or more days ago
            OR the sync status is not success (lastSyncErrorCode is not equal to 0)
        Warning:
          - The last synchronization was more than one day ago 
          AND the sync status is success (lastSyncErrorCode is 0)
        Healthy:
          - The last synchronization was less than one day ago 
          AND the sync status is success (lastSyncErrorCode is 0)

        When multiple tokens exist, the group's status is the least healthy status among them.

    .PARAMETER DepTokens
        The object returned by Get-DepTokens.

    .EXAMPLE
        $depTokens = Get-DepTokens -AccessToken <AccessToken>
        Get-IntuneDepTokensStatus -DepTokens $depTokens

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $DepTokens
    )

    if (-not $DepTokens.success) {
        return @(
            [pscustomobject][ordered]@{
                connectorName = 'appleDepExpirationDateTime'
                status        = Format-GraphResponseSummary -Response $DepTokens
            }
            [pscustomobject][ordered]@{
                connectorName = 'appleDepLastSyncDateTime'
                status        = Format-GraphResponseSummary -Response $DepTokens
            }
        )
    }

    if ($null -eq $DepTokens -or (@($DepTokens.tokens).Count -eq 0)) {
        return @(
            [pscustomobject][ordered]@{
                connectorName = 'appleDepExpirationDateTime'
                status        = 'Not Enabled'
            }
            [pscustomobject][ordered]@{
                connectorName = 'appleDepLastSyncDateTime'
                status        = 'Not Enabled'
            }
        )
    }

    $now = Get-Date
    $rank = @{ unknown = 0; healthy = 1; warning = 2; unhealthy = 3 }
    $expWorst = 'unknown'
    $syncWorst = 'unknown'

    foreach ($token in @($DepTokens.tokens)) {

        $expStatus = 'unknown'
        $tokenExpirationDateTime = $null
        if ($token.PSObject.Properties.Name -contains 'tokenExpirationDateTime' -and $token.tokenExpirationDateTime) {
            try { $tokenExpirationDateTime = [datetime]$token.tokenExpirationDateTime } catch { $tokenExpirationDateTime = $null }
        }
        
        if ($tokenExpirationDateTime) {
            $daysToExpire = ($tokenExpirationDateTime - $now).TotalDays
            if ($daysToExpire -lt 0) { $expStatus = 'unhealthy' }
            elseif ($daysToExpire -le 7) { $expStatus = 'warning' }
            else { $expStatus = 'healthy' }
        }
        
        if ($rank[$expStatus] -gt $rank[$expWorst]) {
            $expWorst = $expStatus
        }

    
        $syncStatus = 'unknown'
        $lastSuccessfulSyncDateTime = $null
        $lastSyncErrorCode = 0
        if ($token.PSObject.Properties.Name -contains 'lastSuccessfulSyncDateTime' -and $token.lastSuccessfulSyncDateTime) {
            try { $lastSuccessfulSyncDateTime = [datetime]$token.lastSuccessfulSyncDateTime } catch { $lastSuccessfulSyncDateTime = $null }
        }

        if ($token.PSObject.Properties.Name -contains 'lastSyncErrorCode') {
            try { $lastSyncErrorCode = [int]$token.lastSyncErrorCode } catch { $lastSyncErrorCode = 0 }
        }

        $isSyncSuccess = ($lastSyncErrorCode -eq 0)

        if ($lastSuccessfulSyncDateTime) {
            $syncAgeDays = ($now - $lastSuccessfulSyncDateTime).TotalDays
            
            if ($syncAgeDays -ge 3 -or -not $isSyncSuccess) { $syncStatus = 'unhealthy' }
            elseif ($syncAgeDays -gt 1 -and $isSyncSuccess) { $syncStatus = 'warning' }
            elseif ($syncAgeDays -lt 1 -and $isSyncSuccess) { $syncStatus = 'healthy' }
        
            if ($rank[$syncStatus] -gt $rank[$syncWorst]) {
                $syncWorst = $syncStatus
            }
        }

        if ($expWorst -eq 'unhealthy' -and $syncWorst -eq 'unhealthy') {
            break
        }
    }

    return @(
        [pscustomobject][ordered]@{
            connectorName = 'appleDepExpirationDateTime'
            status        = $expWorst
        }
        [pscustomobject][ordered]@{
            connectorName = 'appleDepLastSyncDateTime'
            status        = $syncWorst
        }
    )
}