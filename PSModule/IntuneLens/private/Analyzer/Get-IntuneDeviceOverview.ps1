function Get-IntuneDeviceOverview {
    <#
    .SYNOPSIS
        Computes a summary overview of managed devices.

    .DESCRIPTION
        Takes devices from Get-IntuneDevices and returns analyzed metrics:
        - Platforms (Windows, Linux, Android, iOS/iPadOS, macOS, Windows Mobile, Other, Total)
        - Compliance states (Compliant, In grace period, Not evaluated, Not compliant, Other, Total)

        Used by the orchestrator to build the Device Overview section.

    .PARAMETER Devices
        Array of device objects as returned by Get-IntuneDevices.

    .EXAMPLE
        $devices = Get-IntuneDevices -AccessToken $token -All
        Get-IntuneDeviceOverview -Devices $devices
        
        Returns analyzed platform and compliance summaries.

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][object[]] $Devices
    )

    $osDistribution = Get-IntuneDeviceOperatingSystemOverview -Devices $Devices
    $complianceStatus = Get-IntuneDeviceComplianceOverview -Devices $Devices

    [pscustomobject]@{
        OperatingSystem = [pscustomobject]$osDistribution
        Compliance      = [pscustomobject]$complianceStatus
    }
}

function Get-IntuneDeviceOperatingSystemOverview {
    <#
    .SYNOPSIS
        Calculates operating system distribution for managed devices.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][object[]] $Devices
    )

    $platforms = [ordered]@{
        Windows       = 0
        Linux         = 0
        Android       = 0
        iOSiPadOS     = 0
        macOS         = 0
        WindowsMobile = 0
        Other         = 0
        Total         = 0
    }

    foreach ($d in ($Devices | Where-Object { $_ })) {
        $os = [string]$d.operatingSystem

        switch -Regex ($os) {
            '^(?i)windows' { $platforms.Windows++ }
            '^(?i)linux' { $platforms.Linux++ }
            '^(?i)android' { $platforms.Android++ }
            '^(?i)i(?:os|pados)' { $platforms.iOSiPadOS++ }
            '^(?i)mac\s*os|^macos' { $platforms.macOS++ }
            '^(?i)windows\s*(mobile|phone)' { $platforms.WindowsMobile++ }
            default { $platforms.Other++ }
        }
        $platforms.Total++
    }

    return [pscustomobject]$platforms
}

function Get-IntuneDeviceComplianceOverview {
    <#
    .SYNOPSIS
        Calculates compliance state distribution for managed devices.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][object[]] $Devices
    )

    $compliance = [ordered]@{
        Compliant     = 0
        InGracePeriod = 0
        NotEvaluated  = 0
        NotCompliant  = 0
        Other         = 0
        Total         = 0
    }

    foreach ($d in ($Devices | Where-Object { $_ })) {
        $state = [string]$d.complianceState

        switch -Regex ($state) {
            '^(?i)compliant$' { $compliance.Compliant++ }
            '^(?i)ingraceperiod$' { $compliance.InGracePeriod++ }
            '^(?i)unknown$' { $compliance.NotEvaluated++ }
            '^(?i)noncompliant$' { $compliance.NotCompliant++ }
            default { $compliance.Other++ }
        }
        $compliance.Total++
    }

    return [pscustomobject]$compliance
}