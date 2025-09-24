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

    $url = "$endpoint`?`$select=id,expirationDateTime,lastSyncDateTime"

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($null -eq $resp.value -or $resp.value.Count -eq 0) {
            return @()
        }

        $items = foreach ($t in $resp.value) {
            [pscustomobject]@{
                id                 = $t.id
                expirationDateTime = if ($t.expirationDateTime) { [datetime]$t.expirationDateTime } else { $null }
                lastSyncDateTime   = if ($t.lastSyncDateTime) { [datetime]$t.lastSyncDateTime }   else { $null }
            }
        }

        return $items
    }
    catch {
        throw
    }
}