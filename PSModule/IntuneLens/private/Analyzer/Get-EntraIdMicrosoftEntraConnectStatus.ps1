function Get-EntraIdMicrosoftEntraConnectStatus {
    <#
    .SYNOPSIS
        Checks if Microsoft Entra Connect is enabled.

    .DESCRIPTION
        Checks if Microsoft Entra Connect (directory synchronization with 
        on-premises Active Directory) is enabled.

    .PARAMETER Organization
        The object returned by Get-EntraIdOrganization.

    .EXAMPLE
        $org = Get-EntraIdOrganization -AccessToken <AccessToken>
        $status = Get-EntraIdMicrosoftEntraConnectStatus -Organization $org

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [pscustomobject] $Organization
    )

    switch ($Organization.onPremisesSyncEnabled) {
        $true { return "Enabled" }
        $false { return "Disabled" }
        default { return "Not Enabled" }
    }
}