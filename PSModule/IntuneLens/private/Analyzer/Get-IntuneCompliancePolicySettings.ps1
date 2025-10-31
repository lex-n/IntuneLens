function Get-IntuneCompliancePolicySettings {
    <#
    .SYNOPSIS
        Analyzes Intune compliance policy settings.

    .DESCRIPTION
        Translates the secureByDefault flag into the user-friendly setting
        “Mark devices with no compliance policy assigned as Compliant/Not compliant”.

    .PARAMETER DeviceManagementSettings
        The object returned by Get-DeviceManagementSettings.

    .EXAMPLE
        $settings = Get-DeviceManagementSettings -AccessToken <AccessToken>
        Get-IntuneCompliancePolicySettings -DeviceManagementSettings $settings

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [object] $DeviceManagementSettings
    )

    if (-not $DeviceManagementSettings.success) {
        return [pscustomobject]@{
            status = Format-GraphResponseSummary -Response $DeviceManagementSettings
        }
    }

    $result = if ($DeviceManagementSettings.secureByDefault -eq $true) {
        "Not compliant"
    }
    elseif ($DeviceManagementSettings.secureByDefault -eq $false) {
        "Compliant"
    }
    else {
        "N/A"
    }

    return [pscustomobject]@{
        devicesWithoutCompliancePolicyAssigned = $result
    }
}