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

    $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
    if (-not $resp.success) {
        return $resp
    }
    else {
        return [pscustomobject]@{
            success                  = $resp.success
            compliantDeviceCount     = if ($resp.data -and $resp.data.compliantDeviceCount) {
                $resp.data.compliantDeviceCount
            }
            else { 0 }

            inGracePeriodCount       = if ($resp.data -and $resp.data.inGracePeriodCount) {
                $resp.data.inGracePeriodCount
            }
            else { 0 }

            nonCompliantDeviceCount  = if ($resp.data -and $resp.data.nonCompliantDeviceCount) {
                $resp.data.nonCompliantDeviceCount
            }
            else { 0 }

            unknownDeviceCount       = if ($resp.data -and $resp.data.unknownDeviceCount) {
                $resp.data.unknownDeviceCount
            }
            else { 0 }

            notApplicableDeviceCount = if ($resp.data -and $resp.data.notApplicableDeviceCount) {
                $resp.data.notApplicableDeviceCount
            }
            else { 0 }

            errorDeviceCount         = if ($resp.data -and $resp.data.errorDeviceCount) {
                $resp.data.errorDeviceCount
            }
            else { 0 }
            
            conflictDeviceCount      = if ($resp.data -and $resp.data.conflictDeviceCount) {
                $resp.data.conflictDeviceCount
            }
            else { 0 }
        }
    }
}