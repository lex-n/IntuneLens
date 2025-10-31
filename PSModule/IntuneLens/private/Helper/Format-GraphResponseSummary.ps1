function Format-GraphResponseSummary {
    <#
    .SYNOPSIS
        Provides a one-line summary of Microsoft Graph response.

    .DESCRIPTION
        Helper function that extracts key fields from a Graph API response
        and returns a simplified summary with success status and 
        any error information if available.

    .PARAMETER Response
        The response object returned by Invoke-Graph.

    .EXAMPLE
        $resp = Invoke-Graph -Method GET -Url $url -Headers $headers
        Format-GraphResponseSummary -Response $resp

    .NOTES
        Author: Alex Nuryiev
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] $Response
    )

    if ($null -eq $Response) {
        return "@{status=unknown; statusCode=N/A; errorCode=N/A; errorMessage=No response object.}"
    }

    if ($Response.success -and -not $Response.errorCode -and -not $Response.errorMessage) {
        return "@{status=success; statusCode=$($Response.statusCode); message=OK}"
    }

    return "@{status=error; statusCode=$($Response.statusCode); errorCode=$($Response.errorCode); errorMessage=$($Response.errorMessage)}"
}