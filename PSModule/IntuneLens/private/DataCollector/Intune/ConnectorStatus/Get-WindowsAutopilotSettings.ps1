function Get-WindowsAutopilotSettings {
    <#
    .SYNOPSIS
        Gets Windows Autopilot settings info.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/windowsAutopilotSettings
        to get Windows Autopilot settings.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-WindowsAutopilotSettings -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/windowsAutopilotSettings"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        return [pscustomobject]@{
            lastSyncDateTime = if ($resp.lastSyncDateTime) { [datetime]$resp.lastSyncDateTime } else { $null }
            syncStatus       = if ($resp.syncStatus) { [string]$resp.syncStatus } else { $null }
        }
    }
    catch {
        $statusCode = $null
        try {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                $statusCode = $_.Exception.Response.StatusCode.value__
            }
        }
        catch { }

        if ($statusCode -eq 404 -or $statusCode -eq 400) {
            return @()
        }

        throw
    }
}