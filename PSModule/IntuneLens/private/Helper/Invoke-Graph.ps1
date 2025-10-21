function Invoke-Graph {
    <#
    .SYNOPSIS
        Sends a Microsoft Graph request and returns a structured response.

    .DESCRIPTION
        Helper function that wraps Invoke-RestMethod to call Microsoft Graph API.
        Handles throttling (HTTP 429) error with automatic retries.
        Returns a consistent object with success flag, status code, data, and error details.

    .PARAMETER Url
        Full Microsoft Graph request URL.

    .PARAMETER Headers
        HTTP headers including Authorization bearer token.

    .PARAMETER Method
        HTTP method to use. Default is GET.

    .PARAMETER MaxRetries
        Number of retry attempts for throttling error. Default is 3.

    .PARAMETER InitialDelayMs
        Initial delay before retrying (in milliseconds). Default is 1000.

    .EXAMPLE
        $resp = Invoke-Graph -Method GET -Url $url -Headers $headers

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $Url,
        [Parameter(Mandatory)] [hashtable] $Headers,
        [ValidateSet('GET')] [string] $Method = 'GET',
        [int] $MaxRetries = 3,
        [int] $InitialDelayMs = 1000
    )

    $delayMs = $InitialDelayMs

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            $data = Invoke-RestMethod -Method $Method -Uri $Url -Headers $Headers -StatusCodeVariable statusCode
            
            return [pscustomobject]@{
                success      = $true
                statusCode   = $statusCode
                data         = $data
                errorCode    = $null
                errorMessage = $null
            }
        }
        catch {
            $statusCode = $null
            try { $statusCode = $_.Exception.Response.StatusCode.value__ } 
            catch {
                return [pscustomobject]@{
                    success      = $false
                    statusCode   = $null
                    data         = $null
                    errorCode    = 'Exception'
                    errorMessage = $_.Exception.Message
                }
            }

            $isThrottled = ($statusCode -eq 429)

            $retryAfterSec = $null
            try {
                if ($_.Exception.Response -and $_.Exception.Response.Headers) {
                    $retryAfterRaw = $_.Exception.Response.Headers['Retry-After']
                    if ($retryAfterRaw) { $retryAfterSec = [int]$retryAfterRaw }
                }
            }
            catch {
                return [pscustomobject]@{
                    success      = $false
                    statusCode   = $null
                    data         = $null
                    errorCode    = 'Exception'
                    errorMessage = $_.Exception.Message
                }
            }

            if ($attempt -lt $MaxRetries -and $isThrottled) {
                if ($retryAfterSec -and $retryAfterSec -gt 0) {
                    Start-Sleep -Seconds $retryAfterSec
                }
                else {
                    Start-Sleep -Milliseconds $delayMs
                    $delayMs = [Math]::Min($delayMs * 2, 8000)
                }
                continue
            }

            $errorCode = $null
            $errorMessage = $_.Exception.Message

            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                try {
                    $parsed = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
                    if ($parsed -and $parsed.error) {
                        $errorCode = $parsed.error.code
                        $errorMessage = $parsed.error.message
                    }
                }
                catch {
                    return [pscustomobject]@{
                        success      = $false
                        statusCode   = $null
                        data         = $null
                        errorCode    = 'Exception'
                        errorMessage = $_.Exception.Message
                    }
                }
            }

            return [pscustomobject]@{
                success      = $false
                statusCode   = $statusCode
                data         = $null
                errorCode    = $errorCode
                errorMessage = $errorMessage
            }
        }
    }
}