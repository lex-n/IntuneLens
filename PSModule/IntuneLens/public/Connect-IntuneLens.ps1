function Connect-IntuneLens {
    <#
    .SYNOPSIS
        Starts an interactive device-code sign-in to the IntuneLens application.

    .DESCRIPTION
        Connect-IntuneLens acquires an access token for Microsoft Graph using the device code flow.

    .PARAMETER ClientId
        The Application (client) ID of IntuneLens multi-tenant app registered in Entra ID.

    .PARAMETER Scopes
        Delegated Graph scopes to request.

    .EXAMPLE
        Connect-IntuneLens

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    param(
        [string]$ClientId = "0b99c4c0-d80b-4914-88f8-1c42f78320e6",
        [string[]]$Scopes = @(
            "DeviceManagementConfiguration.Read.All",
            "DeviceManagementManagedDevices.Read.All",
            "Directory.Read.All"
        )
    )

    # Endpoints via 'common' (or replace with 'organizations' to filter out personal accounts)
    $authBase = "https://login.microsoftonline.com/common/oauth2/v2.0"
    $deviceCodeUrl = "$authBase/devicecode"
    $tokenUrl = "$authBase/token"

    # Request device code
    $dc = Invoke-RestMethod -Method Post -Uri $deviceCodeUrl -Body @{
        client_id = $ClientId
        scope     = ($Scopes -join " ")
    }

    Write-Host "To sign in to the IntuneLens application, use a web browser to open the page: " -ForegroundColor Green -NoNewline
    Write-Host $($dc.verification_uri)

    Write-Host "And enter the code to authenticate: " -ForegroundColor Green -NoNewline
    Write-Host $($dc.user_code)

    # Waiting for token
    $expiresAt = (Get-Date).AddSeconds([int]$dc.expires_in)
    $interval = [int]$dc.interval
    $token = $null

    while (-not $token) {
        if ((Get-Date) -ge $expiresAt) { throw "Device code expired. Run again." }
        Start-Sleep -Seconds $interval
        try {
            $token = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body @{
                grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
                client_id   = $ClientId
                device_code = $dc.device_code
            } -ErrorAction Stop
        }
        catch {
            # keep polling
        }
    }

    $accessToken = $token.access_token

    # Extract tenantId (tid) from JWT (payload — 2nd segment)
    function Convert-FromBase64Url([string]$b64u) {
        $s = $b64u.Replace('-', '+').Replace('_', '/')
        switch ($s.Length % 4) { 2 { $s += '==' }; 3 { $s += '=' } }
        return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))
    }

    $jwtParts = $accessToken.Split('.')
    $payloadRaw = Convert-FromBase64Url $jwtParts[1]
    $payload = $payloadRaw | ConvertFrom-Json
    $tenantId = $payload.tid
    $expiresIn = [int]$token.expires_in
    $expiresOn = (Get-Date).AddSeconds($expiresIn)

    # Return all useful info
    $authHeader = @{ Authorization = "Bearer $accessToken" }
    $me = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/me" -Headers $authHeader

    $context = [PSCustomObject]@{
        AccessToken = $accessToken
        TokenType   = $token.token_type
        ExpiresOn   = $expiresOn
        TenantId    = $tenantId
        User        = $me.userPrincipalName
        DisplayName = $me.displayName
    }

    # Store for later use by other commands (module scope)
    $script:IntuneLensContext = $context
}