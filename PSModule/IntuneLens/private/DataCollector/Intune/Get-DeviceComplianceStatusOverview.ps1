function Get-DeviceComplianceStatusOverview {
    <#
    .SYNOPSIS
        Gets Intune device compliance status overview.

    .DESCRIPTION
        Calls the Microsoft Graph endpoint /deviceManagement/deviceCompliancePolicyDeviceStateSummary
        to retrieve aggregated counts of devices by compliance state.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph (required).

    .EXAMPLE
        Get-DeviceComplianceStatusOverview -AccessToken <AccessToken>

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
    $endpoint = "$base/deviceManagement/deviceCompliancePolicyDeviceStateSummary"
    $headers = @{ Authorization = "Bearer $AccessToken" }

    $url = $endpoint

    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop

    return [pscustomobject]@{
        compliantDeviceCount     = $resp.compliantDeviceCount
        inGracePeriodCount       = $resp.inGracePeriodCount
        nonCompliantDeviceCount  = $resp.nonCompliantDeviceCount
        unknownDeviceCount       = $resp.unknownDeviceCount
        notApplicableDeviceCount = $resp.notApplicableDeviceCount
        errorDeviceCount         = $resp.errorDeviceCount
        conflictDeviceCount      = $resp.conflictDeviceCount        
    }
}