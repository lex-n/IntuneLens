function Get-IntuneVppTokensStatus {
    <#
    .SYNOPSIS
        Analyzes Apple VPP (Volume Purchase Program) tokens health status.

    .DESCRIPTION
        Determines Apple VPP (Volume Purchase Program) tokens health status.

        For each VPP token, evaluates:
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
            OR the sync status is failed
        Warning:
          - The last synchronization was more than one day ago 
          AND the sync status is not failed
        Healthy:
          - The last synchronization was less than one day ago 
          AND the sync status is not failed

        When multiple tokens exist, the group's status is the least healthy status among them.

    .PARAMETER VppTokens
        The object returned by Get-VppTokens.

    .EXAMPLE
        $vppTokens = Get-VppTokens -AccessToken <AccessToken>
        Get-IntuneVppTokensStatus -VppTokens $vppTokens

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [pscustomobject] $VppTokens
    )

    if (-not $VppTokens.success) {
        return @(
            [pscustomobject][ordered]@{
                connectorName = 'vppTokenExpirationDateTime'
                status        = Format-GraphResponseSummary -Response $VppTokens
            }
            [pscustomobject][ordered]@{
                connectorName = 'vppTokenLastSyncDateTime'
                status        = Format-GraphResponseSummary -Response $VppTokens
            }
        )
    }

    if ($null -eq $VppTokens -or (@($VppTokens.tokens).Count -eq 0)) {
        return @(
            [pscustomobject][ordered]@{
                connectorName = 'vppTokenExpirationDateTime'
                status        = 'Not Enabled'
            }
            [pscustomobject][ordered]@{
                connectorName = 'vppTokenLastSyncDateTime'
                status        = 'Not Enabled'
            }
        )
    }

    $now = Get-Date
    $rank = @{ unknown = 0; healthy = 1; warning = 2; unhealthy = 3 }
    $expWorst = 'unknown'
    $syncWorst = 'unknown'

    foreach ($token in @($VppTokens.tokens)) {

        $expStatus = 'unknown'
        $expirationDateTime = $null
        if ($token.PSObject.Properties.Name -contains 'expirationDateTime' -and $token.expirationDateTime) {
            try { $expirationDateTime = [datetime]$token.expirationDateTime } catch { $expirationDateTime = $null }
        }
        
        if ($expirationDateTime) {
            $daysToExpire = ($expirationDateTime - $now).TotalDays
            if ($daysToExpire -lt 0) { $expStatus = 'unhealthy' }
            elseif ($daysToExpire -le 7) { $expStatus = 'warning' }
            else { $expStatus = 'healthy' }
        }
        
        if ($rank[$expStatus] -gt $rank[$expWorst]) {
            $expWorst = $expStatus
        }

    
        $syncStatus = 'unknown'
        $lastSyncDateTime = $null
        $lastSyncStatus = $null
        if ($token.PSObject.Properties.Name -contains 'lastSyncDateTime' -and $token.lastSyncDateTime) {
            try { $lastSyncDateTime = [datetime]$token.lastSyncDateTime } catch { $lastSyncDateTime = $null }
        }

        if ($token.PSObject.Properties.Name -contains 'lastSyncStatus' -and $token.lastSyncStatus) {
            try { $lastSyncStatus = [string]$token.lastSyncStatus } catch { $lastSyncStatus = '' }
        }

        $isSyncSuccess = ($lastSyncStatus -ne 'failed')

        if ($lastSyncDateTime) {
            $syncAgeDays = ($now - $lastSyncDateTime).TotalDays
            
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
            connectorName = 'vppTokenExpirationDateTime'
            status        = $expWorst
        }
        [pscustomobject][ordered]@{
            connectorName = 'vppTokenLastSyncDateTime'
            status        = $syncWorst
        }
    )
}