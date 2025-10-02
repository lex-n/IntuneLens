function Show-Section {
    param(
        [string] $Title,
        [pscustomobject] $Data
    )

    Write-Host ("### " + $Title) -ForegroundColor DarkGray

    $paddingWidth = ($Data.PSObject.Properties.Name | Measure-Object -Property Length -Maximum).Maximum
    if (-not $paddingWidth -or $paddingWidth -lt 25) { $paddingWidth = 25 }

    $formatString = "{0,-$paddingWidth} : {1}"

    foreach ($prop in $Data.PSObject.Properties) {
        Write-Host ($formatString -f $prop.Name, $prop.Value)
    }

    Write-Host ""
}

function Get-IntuneLensHealthOverview {
    <#
    .SYNOPSIS
        Builds and displays Intune Health Overview for the current tenant.

    .DESCRIPTION
        Get-IntuneLensHealthOverview orchestrates the collection and analysis of data, 
        and renders the Intune Health Overview report to console in a human-friendly format.

    .PARAMETER AccessToken
        Bearer token for Microsoft Graph.

    .PARAMETER Protected
        Optional switch. If specified, sensitive tenant information such as
        "Organization name", "Default domain", "Tenant creation datetime"
        are masked in the report and displayed as "Protected".
        Other fields remain unchanged.

    .EXAMPLE
        Get-IntuneLensHealthOverview
        Displays the full health overview report with all details visible.

        Get-IntuneLensHealthOverview -Protected
        Displays the health overview report, but masks sensitive tenant information.
    
    .NOTES
        Author: Alex Nuryiev
    #>
    
    [CmdletBinding()]
    param(
        [string] $AccessToken,
        [switch] $Protected
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

    Write-Host "Building IntuneLens report... Please wait, this may take a few moments." -ForegroundColor Green

    $organization = Get-EntraIdOrganization -AccessToken $AccessToken
    $defaultDomain = Get-EntraIdDefaultDomain -AccessToken $AccessToken
    $orgName = if ($Protected) { 'Protected' } else { $organization.displayName }
    $defDomain = if ($Protected) { 'Protected' } else { $defaultDomain.id }
    $orgCreatedDateTime = if ($Protected) { 'Protected' } else { $organization.createdDateTime }

    $entraIdPremiumLicenseInsight = Get-EntraIdPremiumLicenseInsight -AccessToken $AccessToken
    $entraIdLicenseLevel = Get-EntraIdLicenseLevel -Insight $entraIdPremiumLicenseInsight

    $entraIdUsersCount = Get-EntraIdUsersCount -AccessToken $AccessToken
    $entraIdGroupsCount = Get-EntraIdGroupsCount -AccessToken $AccessToken
    $entraIdApplicationsCount = Get-EntraIdApplicationsCount -AccessToken $AccessToken
    $entraIdDevicesCount = Get-EntraIdDevicesCount -AccessToken $AccessToken

    $microsoftEntraConnectStatus = Get-EntraIdMicrosoftEntraConnectStatus -Organization $organization
    $companyBrandingConfigStatus = Get-EntraIdBrandingConfigStatus -AccessToken $AccessToken -OrganizationId $organization.id

    $mdmPolicies = Get-EntraIdMdmPolicies -AccessToken $AccessToken
    $mamPolicies = Get-EntraIdMamPolicies -AccessToken $AccessToken
    $mobilitySummary = Get-EntraIdMobility -MdmPolicy $mdmPolicies -MamPolicy $mamPolicies

    $securityDefaultsPolicy = Get-EntraIdSecurityDefaultsPolicy -AccessToken $AccessToken

    $mdmAuthority = Get-MdmAuthority -AccessToken $AccessToken -OrganizationId $organization.id
    $intuneSubscriptionState = Get-IntuneSubscriptionState -AccessToken $AccessToken

    $skus = Get-SubscribedSkus -AccessToken $AccessToken
    $totalIntuneLicenses = Get-IntuneTotalLicenses -SubscribedSkus $skus
    $totalIntuneLicensedUsers = Get-IntuneTotalLicensedUsers -SubscribedSkus $skus

    $managedDeviceOverview = Get-ManagedDeviceOverview -AccessToken $AccessToken

    $deviceComplianceStatus = Get-DeviceComplianceStatusOverview -AccessToken $AccessToken

    $deviceManagementSettings = Get-DeviceManagementSettings -AccessToken $AccessToken
    $compliancePolicySettings = Get-IntuneCompliancePolicySettings -DeviceManagementSettings $deviceManagementSettings

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
        'Apple Push Notification Certificate'              = $ApplePushNotificationCertificate
        'Apple VPP'                                        = $VppTokens
        'Apple DEP'                                        = $DepTokens
        'Managed Google Play'                              = $ManagedGooglePlaySettings
        'Windows Autopilot'                                = $WindowsAutopilotSettings
        'NDES Connectors'                                  = $NdesConnectors
        'Mobile Threat Defense Connectors (non-Microsoft)' = $MobileThreatDefenseConnectors
        'Microsoft Defender for Endpoint Connector'        = $MicrosoftDefenderForEndpointConnector
        'JAMF'                                             = $JamfConnector
    }

    $connectorsNotEnabled = [ordered]@{}
    foreach ($name in $connectorInputs.Keys) {
        $val = $connectorInputs[$name]
        if ($null -eq $val -or (@($val).Count -eq 0)) {
            $connectorsNotEnabled[$name] = 'Not Enabled'
        }
    }

    $combinedConnectorStatus = [ordered]@{}

    if ($null -ne $connectorStatusSection -and $connectorStatusSection.Count -gt 0) {
        foreach ($p in $connectorStatusSection.PSObject.Properties) {
            $combinedConnectorStatus[$p.Name] = $p.Value
        }
    }

    if ($null -ne $connectorsNotEnabled -and $connectorsNotEnabled.Count -gt 0) {
        foreach ($name in $connectorsNotEnabled.Keys) {
            $combinedConnectorStatus[$name] = $connectorsNotEnabled[$name]
        }
    }


    $EntraIdReport = [ordered]@{
        "Basic information"      = [pscustomobject][ordered]@{
            "Organization name"       = $orgName
            "Default domain"          = $defDomain
            "Tenant created at"       = $orgCreatedDateTime
            "Tenant type"             = $organization.tenantType
            "Tenant level"            = $entraIdLicenseLevel
            "Users"                   = $entraIdUsersCount
            "Groups"                  = $entraIdGroupsCount
            "Applications"            = $entraIdApplicationsCount
            "Devices"                 = $entraIdDevicesCount
            "Microsoft Entra Connect" = $microsoftEntraConnectStatus
            "Company branding"        = $companyBrandingConfigStatus
            "Security defaults"       = if ($securityDefaultsPolicy.isEnabled) { "Enabled" } else { "Not Enabled" }
        }
        "Entra ID licenses"      = [pscustomobject][ordered]@{
            "Microsoft Entra ID P1"                            = $entraIdPremiumLicenseInsight.entitledP1LicenseCount
            "Microsoft Entra ID P2"                            = $entraIdPremiumLicenseInsight.entitledP2LicenseCount
            "Total Entra ID licenses"                          = $entraIdPremiumLicenseInsight.entitledTotalLicenseCount
            "P1 conditional access usage (members)"            = $entraIdPremiumLicenseInsight.p1ConditionalAccessUsers
            "P1 conditional access usage (guests)"             = $entraIdPremiumLicenseInsight.p1ConditionalAccessGuestUsers
            "P2 risk-based conditional access usage (members)" = $entraIdPremiumLicenseInsight.p2RiskBasedConditionalAccessUsers
            "P2 risk-based conditional access usage (guests)"  = $entraIdPremiumLicenseInsight.p2RiskBasedConditionalAccessGuestUsers
        }
        "Mobility (MDM and WIP)" = [pscustomobject][ordered]@{
            "Microsoft Intune" = if ($mobilitySummary.hasMicrosoftIntune) { "Yes" } else { "No" }
            "MDM applies to"   = $mobilitySummary.mdmAppliesTo
            "WIP applies to"   = $mobilitySummary.mamAppliesTo
        }
    }

    $IntuneReport = [ordered]@{
        "Basic information"                 = [pscustomobject][ordered]@{
            "MDM authority"                                      = $mdmAuthority
            "Subscription state"                                 = $intuneSubscriptionState.subscriptionState
            "Total enrolled devices"                             = $managedDeviceOverview.enrolledDeviceCount
            "MDM enrolled devices"                               = $managedDeviceOverview.mdmEnrolledCount
            "Co-managed devices"                                 = $managedDeviceOverview.dualEnrolledDeviceCount
            "Mark devices with no compliance policy assigned as" = $compliancePolicySettings.devicesWithoutCompliancePolicyAssigned
        }
        "Intune licenses"                   = [pscustomobject][ordered]@{
            "Total Intune licenses" = $totalIntuneLicenses
            "Total licensed users"  = $totalIntuneLicensedUsers
        }
        "Device operating system"           = [pscustomobject][ordered]@{
            "Windows"        = $managedDeviceOverview.windowsCount
            "macOS"          = $managedDeviceOverview.macOSCount
            "iOS"            = $managedDeviceOverview.iOSCount
            "Android"        = $managedDeviceOverview.androidCount
            "Linux"          = $managedDeviceOverview.linuxCount
            "Windows Mobile" = $managedDeviceOverview.windowsMobileCount
            "Total"          = $managedDeviceOverview.enrolledDeviceCount
        }
        "Device compliance status"          = [pscustomobject][ordered]@{
            "Compliant"       = $deviceComplianceStatus.compliantDeviceCount
            "In grace period" = $deviceComplianceStatus.inGracePeriodCount
            "Not compliant"   = $deviceComplianceStatus.nonCompliantDeviceCount
            "Not applicable"  = $deviceComplianceStatus.notApplicableDeviceCount
            "Error"           = $deviceComplianceStatus.errorDeviceCount
            "Conflict"        = $deviceComplianceStatus.conflictDeviceCount
        }
        "Service health and message center" = [pscustomobject][ordered]@{
            "Active incidents"         = @($intuneActiveIncidents).Count
            "Active advisories"        = @($intuneActiveAdvisories).Count
            "Action required messages" = @($intuneActionRequiredMessages).Count
        }
        "Connector status"                  = [pscustomobject]$combinedConnectorStatus
    }

    Write-Host ""
    Write-Host "# IntuneLens - Intune Health Overview" -ForegroundColor Yellow

    Write-Host "## Entra ID Overview" -ForegroundColor Green
    foreach ($sectionName in $EntraIdReport.Keys) {
        Show-Section -Title $sectionName -Data $EntraIdReport[$sectionName]
    }
    Write-Host ""

    Write-Host "## Intune Overview" -ForegroundColor Green
    foreach ($sectionName in $IntuneReport.Keys) {
        Show-Section -Title $sectionName -Data $IntuneReport[$sectionName]
    }
    Write-Host ""
}