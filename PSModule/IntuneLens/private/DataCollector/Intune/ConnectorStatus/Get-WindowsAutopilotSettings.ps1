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

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        $data = $resp.data

        return [pscustomobject]@{
            success          = $resp.success
            id               = if ($data.id) { $data.id } else { 'N/A' }
            lastSyncDateTime = if ($data.lastSyncDateTime) { [datetime]$data.lastSyncDateTime } else { $null }
            syncStatus       = if ($data.syncStatus) { [string]$data.syncStatus } else { 'N/A' }
        }
    }
}