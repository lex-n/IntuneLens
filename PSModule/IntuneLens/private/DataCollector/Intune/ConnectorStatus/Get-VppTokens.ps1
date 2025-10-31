function Get-VppTokens {
    <#
    .SYNOPSIS
        Gets Apple VPP (Volume Purchase Program) tokens.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceAppManagement/vppTokens
        to get Apple Volume Purchase Program tokens for iOS apps.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-VppTokens -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceAppManagement/vppTokens"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,expirationDateTime,lastSyncDateTime,lastSyncStatus"

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $tokens = foreach ($t in $resp.data.value) {
            [pscustomobject]@{
                id                 = if ($t.id) { $t.id } else { 'N/A' }
                expirationDateTime = if ($t.expirationDateTime) { [datetime]$t.expirationDateTime } else { $null }
                lastSyncDateTime   = if ($t.lastSyncDateTime) { [datetime]$t.lastSyncDateTime } else { $null }
                lastSyncStatus     = if ($t.lastSyncStatus) { [string]$t.lastSyncStatus } else { 'N/A' }
            }
        }

        $results = [pscustomobject]@{
            success = $resp.success
            tokens  = $tokens
        }

        return $results
    }
}