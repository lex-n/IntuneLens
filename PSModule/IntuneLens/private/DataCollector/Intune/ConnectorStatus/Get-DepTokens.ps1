function Get-DepTokens {
    <#
    .SYNOPSIS
        Gets Apple DEP (Device Enrollment Program) tokens.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/depOnboardingSettings
        to get Apple Device Enrollment Program tokens.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-DepTokens -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/depOnboardingSettings"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,tokenExpirationDateTime,lastSuccessfulSyncDateTime,lastSyncErrorCode"

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $tokens = foreach ($d in $resp.data.value) {
            [pscustomobject]@{
                id                         = if ($d.id) { $d.id } else { 'N/A' }
                tokenExpirationDateTime    = if ($d.tokenExpirationDateTime) { [datetime]$d.tokenExpirationDateTime } else { $null }
                lastSuccessfulSyncDateTime = if ($d.lastSuccessfulSyncDateTime) { [datetime]$d.lastSuccessfulSyncDateTime } else { $null }
                lastSyncErrorCode          = if($d.lastSyncErrorCode) { $d.lastSyncErrorCode } else { 0 }
            }
        }

        $results = [pscustomobject]@{
            success    = $resp.success
            tokens = $tokens
        }

        return $results
    }
}