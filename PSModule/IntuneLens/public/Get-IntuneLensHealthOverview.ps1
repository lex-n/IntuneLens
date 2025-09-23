function Show-Section {
    param(
        [string] $Title,
        [pscustomobject] $Data
    )

    Write-Host ("## " + $Title)

    foreach ($prop in $Data.PSObject.Properties) {
        Write-Host ("{0,-25} : {1}" -f $prop.Name, $prop.Value)
    }

    Write-Host ""
}

function Get-IntuneLensHealthOverview {
    <#
    .SYNOPSIS
        Builds and displays Intune Health Overview for the current tenant.

    .DESCRIPTION
        Get-IntuneLensHealthOverview orchestrates the collection and analysis of data, 
        and renders the report to console in a human-friendly format. 

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph.

    .EXAMPLE
        Get-IntuneLensHealthOverview
    
    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    [OutputType('IntuneLensReport')]
    param(
        [string] $AccessToken
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # AccessToken
    if (-not $AccessToken) {
        if ($script:IntuneLensContext -and $script:IntuneLensContext.AccessToken) {
            # Check if the stored token is still valid (5 min skew buffer)
            $now = Get-Date
            $limit = $now.AddMinutes(5)

            if ($script:IntuneLensContext.ExpiresOn -le $limit) {
                throw "The stored access token has expired or is about to expire. Run Connect-IntuneLens again."
            }

            $AccessToken = $script:IntuneLensContext.AccessToken
        }
        else {
            throw "No AccessToken available. Run Connect-IntuneLens first."
        }
    }

    $intuneActiveIncidents = Get-IntuneActiveIncidents -AccessToken $AccessToken
    $intuneActiveAdvisories = Get-IntuneActiveAdvisories -AccessToken $AccessToken
    $intuneActionRequiredMessages = Get-IntuneActionRequiredMessages -AccessToken $AccessToken


    $connectorStatus = Get-ConnectorStatus -AccessToken $AccessToken
    $connectorStatusSection =
    if (@($connectorStatus).Count -gt 0) {
        $o = [ordered]@{}
        foreach ($c in $connectorStatus) {
            $o[$c.connectorName] = $c.status
        }
        [pscustomobject]$o
    }
    else {
        [pscustomobject][ordered]@{
            "Connectors Enabled" = 0
        }
    }


    $ApplePushNotificationCertificate = Get-ApplePushNotificationCertificate -AccessToken $AccessToken
    $VppTokens = Get-VppTokens -AccessToken $AccessToken
    $DepTokens = Get-DepTokens -AccessToken $AccessToken
    $ManagedGooglePlaySettings = Get-ManagedGooglePlaySettings -AccessToken $AccessToken
    $WindowsAutopilotSettings = Get-WindowsAutopilotSettings -AccessToken $AccessToken
    $NdesConnectors = Get-NdesConnectors -AccessToken $AccessToken
    $MobileThreatDefenseConnectors = Get-MobileThreatDefenseConnectors -AccessToken $AccessToken
    $MicrosoftDefenderForEndpointConnector = Get-MicrosoftDefenderForEndpointConnector -AccessToken $AccessToken
    $JamfConnector = Get-JamfConnector -AccessToken $AccessToken

    $connectorInputs = [ordered]@{
        'Apple Push Notification Certificate'       = $ApplePushNotificationCertificate
        'Apple VPP'                                 = $VppTokens
        'Apple DEP'                                 = $DepTokens
        'Managed Google Play'                       = $ManagedGooglePlaySettings
        'Windows Autopilot'                         = $WindowsAutopilotSettings
        'NDES Connectors'                           = $NdesConnectors
        'Mobile Threat Defense Connectors'          = $MobileThreatDefenseConnectors
        'Microsoft Defender for Endpoint Connector' = $MicrosoftDefenderForEndpointConnector
        'JAMF'                                      = $JamfConnector
    }

    $connectorsNotEnabled = [ordered]@{}
    foreach ($name in $connectorInputs.Keys) {
        $val = $connectorInputs[$name]
        if ($null -eq $val -or (@($val).Count -eq 0)) {
            $connectorsNotEnabled[$name] = 'Not Enabled'
        }
    }

    $report = [ordered]@{
        "Service health and message center" = [pscustomobject][ordered]@{
            "Active Incidents"         = @($intuneActiveIncidents).Count
            "Active Advisories"        = @($intuneActiveAdvisories).Count
            "Action Required Messages" = @($intuneActionRequiredMessages).Count
        }
        "Connector Status"                  = $connectorStatusSection
        "Connectors (Not Enabled)"          = [pscustomobject]$connectorsNotEnabled
    }

    Write-Host ""
    Write-Host "# IntuneLens - Intune Health Overview"
    Write-Host ""

    foreach ($sectionName in $report.Keys) {
        Show-Section -Title $sectionName -Data $report[$sectionName]
    }
}