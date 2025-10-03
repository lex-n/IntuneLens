function Disconnect-IntuneLens {
    <#
    .SYNOPSIS
        Clears the current IntuneLens session.

    .DESCRIPTION
        Removes the in-memory authentication context created by Connect-IntuneLens.
        After running this command, other IntuneLens commands will require a fresh Connect-IntuneLens.

    .EXAMPLE
        Disconnect-IntuneLens

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([pscustomobject])]
    param()

    $existingContext = $null
    $contextVariable = Get-Variable -Name IntuneLensContext -Scope Script -ErrorAction SilentlyContinue
    if ($null -ne $contextVariable) {
        $existingContext = $contextVariable.Value
    }

    if (-not $existingContext) {
        return [pscustomobject]@{
            Message = "No active IntuneLens session found."
        }
    }

    $displayName = $existingContext.DisplayName
    $upn = $existingContext.User
    $tenantId = $existingContext.TenantId

    $target = if ($upn) { "$upn ($tenantId)" } else { $tenantId }

    if ($PSCmdlet.ShouldProcess($target, "Clear IntuneLens session")) {
        try {
            $script:IntuneLensContext = $null
            
            Remove-Variable -Name IntuneLensContext -Scope Script -ErrorAction SilentlyContinue
            Write-Host "IntuneLens session context cleared."
        }
        catch {
            Write-Host "Failed to remove IntuneLens context variable: $($_.Exception.Message)"
        }

        [pscustomobject]@{
            Disconnected      = $true
            User              = $displayName
            UserPrincipalName = $upn
            TenantId          = $tenantId
            Message           = "Session cleared."
        }
    }
}