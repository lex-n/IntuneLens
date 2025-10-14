function Get-ConnectorStatus {
    <#
    .SYNOPSIS
        Gets Intune connector status entries.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/connectorStatus
        to retrieve connector status information.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-ConnectorStatus -AccessToken <AccessToken>

    .NOTES
        Author: Alex Nuryiev
    #>

    param(
        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $base = "https://graph.microsoft.com/beta"
    $endpoint = "$base/deviceManagement/connectorStatus"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($null -eq $resp.value -or $resp.value.Count -eq 0) {
            return @()
        }

        $items = foreach ($c in $resp.value) {
            [pscustomobject]@{
                connectorName       = $c.connectorName
                connectorInstanceId = $c.connectorInstanceId
                status              = $c.status
            }
        }

        return $items
    }
    catch {
        throw
    }
}