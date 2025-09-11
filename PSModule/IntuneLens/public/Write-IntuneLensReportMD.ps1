function Write-IntuneLensReportMD {
    <#
    .SYNOPSIS
        Writes an IntuneLens report to a Markdown (.md) file.

    .DESCRIPTION
        Write-IntuneLensReportMD takes a typed [IntuneLensReport] from Get-IntuneLensHealthReport,
        renders each section, and writes the final Markdown file to disk. If the optional Microsoft 
        formatter module (FormatMarkdownTable) is installed, it will be used automatically; 
        otherwise a simple built-in renderer is used.

    .PARAMETER Path
        Destination file path for the Markdown output (e.g., ./reports/IntuneLens_report.md).

    .PARAMETER Report
        An [IntuneLensReport] object produced by Get-IntuneLensHealthReport.

    .PARAMETER Title
        Optional document title. Defaults to "IntuneLens – Intune Health Report".

    .EXAMPLE
        $report = Get-IntuneLensHealthReport -ClientId '00000000-0000-0000-0000-000000000000'
        Write-IntuneLensReportMD -Path ("./reports/IntuneLens_report_{0}.md" -f (Get-Date -Format 'yyyyMMdd_HHmmss')) -Report $report 

    .NOTES
        Author: Alex Nuryiev

    .LINK
        https://github.com/microsoft/FormatPowerShellToMarkdownTable
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]  $Path,
        [Parameter(Mandatory)][IntuneLensReport] $Report,
        [string] $Title = 'IntuneLens - Intune Health Report'
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $dir = Split-Path -Path $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

    $fmtCols = Get-Command Format-MarkdownTableTableStyle -ErrorAction SilentlyContinue
    $fmtRows = Get-Command Format-MarkdownTableListStyle  -ErrorAction SilentlyContinue

    function New-MDTableCols {
        param([object[]]$Items, [string[]]$Property)
        if ($fmtCols) {
            return ($Property ? ($Items | Format-MarkdownTableTableStyle @Property)
                : ($Items | Format-MarkdownTableTableStyle)) 
        }
        if (-not $Items -or $Items.Count -eq 0) { return '' }
        if (-not $Property -or $Property.Count -eq 0) { $Property = $Items[0].PSObject.Properties.Name }
        $header = '| ' + ($Property -join ' | ') + ' |'
        $rule = '| ' + (($Property | ForEach-Object { '---' }) -join ' | ') + ' |'
        $rows = foreach ($r in $Items) {
            $cells = foreach ($p in $Property) { ($r.$p -as [string]) -replace '\r?\n', ' ' }
            '| ' + ($cells -join ' | ') + ' |'
        }
        @($header, $rule) + $rows -join "`n"
    }

    function New-MDTableRows {
        param([psobject]$Obj, [string[]]$Property)
        if ($fmtRows) {
            return ($Property ? ($Obj | Format-MarkdownTableListStyle @Property)
                : ($Obj | Format-MarkdownTableListStyle)) 
        }
        if (-not $Property -or $Property.Count -eq 0) { $Property = $Obj.PSObject.Properties.Name }
        $rows = foreach ($p in $Property) { [pscustomobject]@{ Property = $p; Value = $Obj.$p } }
        New-MDTableCols -Items $rows -Property @('Property', 'Value')
    }

    function Render-Section {
        param([IntuneLensSection] $Section)
        $md = "## $($Section.Title)`n"
        $data = $Section.Data
        if ($null -eq $data) { return ($md + "_No data_`n") }

        if ($data -is [System.Collections.IEnumerable] -and -not ($data -is [string])) {
            $arr = @($data)
            if ($arr.Count -gt 0) {
                $props = $arr[0].PSObject.Properties.Name
                $md += (New-MDTableCols -Items $arr -Property $props) + "`n"
            }
            else {
                $md += "_No data_`n"
            }
        }
        elseif ($data -is [psobject]) {
            $md += (New-MDTableRows -Obj $data) + "`n"
        }
        else {
            $md += "```````$data```````n"
        }

        if ($Section.SubSections) {
            foreach ($sub in $Section.SubSections) { $md += "`n" + (Render-Section -Section $sub) }
        }
        return $md
    }

    $md = "# $Title`n"
    $md += "_Collected: $($Report.CollectedAt)_`n`n"
    foreach ($s in $Report.Sections) { $md += (Render-Section -Section $s) + "`n" }

    Set-Content -Path $Path -Value $md -Encoding UTF8
    return $Path
}