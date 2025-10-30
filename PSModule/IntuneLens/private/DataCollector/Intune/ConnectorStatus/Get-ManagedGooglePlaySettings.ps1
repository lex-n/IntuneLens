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

    $url = $endpoint

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $data = $resp.data

        if ($null -eq $data -or ($data.bindStatus -and $data.bindStatus -eq 'notBound')) { 
            return [pscustomobject]@{
                success    = $resp.success
                bindStatus = $data.bindStatus
            }
        }

        return [pscustomobject]@{
            success             = $resp.success
            id                  = if ($data -and $data.id) { $data.id } else { 'N/A' }
            lastAppSyncDateTime = if ($data -and $data.lastAppSyncDateTime) {
                [datetime]$data.lastAppSyncDateTime
            }
            else { $null }
            lastAppSyncStatus   = if ($data -and $data.lastAppSyncStatus) {
                [string]$data.lastAppSyncStatus
            }
            else { 'N/A' }
            bindStatus          = if ($data -and $data.bindStatus) {
                [string]$data.bindStatus
            }
            else { 'N/A' }
        }
    }
}