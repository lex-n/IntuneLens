function Get-ManagedGooglePlaySettings {
    <#
    .SYNOPSIS
        Gets Managed Google Play app sync settings.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/androidManagedStoreAccountEnterpriseSettings
        to get Managed Google Play app sync settings.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-ManagedGooglePlaySettings -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/androidManagedStoreAccountEnterpriseSettings"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=bindStatus,lastAppSyncDateTime,lastAppSyncStatus"

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($null -eq $resp -or ($resp.bindStatus -and $resp.bindStatus.ToString().ToLowerInvariant() -eq 'notbound')) { 
            return @()
        }

        $lastSync = if ($resp.lastAppSyncDateTime) { [datetime]$resp.lastAppSyncDateTime } else { $null }
        $status = if ($resp.lastAppSyncStatus) { [string]$resp.lastAppSyncStatus } else { $null }

        return [pscustomobject]@{
            lastAppSyncDateTime = $lastSync
            lastAppSyncStatus   = $status
        }
    }
    catch {
        throw
    }
}