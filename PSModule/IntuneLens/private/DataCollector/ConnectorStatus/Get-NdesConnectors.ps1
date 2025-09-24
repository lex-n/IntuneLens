function Get-NdesConnectors {
    <#
    .SYNOPSIS
        Gets NDES (Network Device Enrollment Service) connectors.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/ndesConnectors
        to get NDES (Network Device Enrollment Service) connectors.
        Intended for use by analyzers, not for direct export.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-NdesConnectors -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/ndesConnectors"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = "$endpoint`?`$select=id,lastConnectionDateTime,state"

    try {
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

        if ($null -eq $resp.value -or $resp.value.Count -eq 0) {
            return @() 
        }

        $items = foreach ($c in $resp.value) {
            [pscustomobject]@{
                id                     = $c.id
                lastConnectionDateTime = if ($c.lastConnectionDateTime) { [datetime]$c.lastConnectionDateTime } else { $null }
                state                  = if ($c.state) { [string]$c.state } else { $null }
            }
        }

        return $items
    }
    catch {
        throw
    }
}