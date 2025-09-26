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

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($null -eq $resp.value -or $resp.value.Count -eq 0) {
            return @()
        }

        $items = foreach ($d in $resp.value) {
            [pscustomobject]@{
                id                         = $d.id
                tokenExpirationDateTime    = if ($d.tokenExpirationDateTime) { [datetime]$d.tokenExpirationDateTime } else { $null }
                lastSuccessfulSyncDateTime = if ($d.lastSuccessfulSyncDateTime) { [datetime]$d.lastSuccessfulSyncDateTime } else { $null }
                lastSyncErrorCode          = $d.lastSyncErrorCode
            }
        }

        return $items
    }
    catch {
        throw
    }
}