# IntuneLens

IntuneLens is a PowerShell module designed to help IT managers and administrators assess the health and configuration of their Microsoft Intune environment. It collects and analyzes data from Microsoft Intune via Graph API, calculates Intune health score and presents key information in the easy-to-understand reports.

The goal of this project is to make it easier for organizations to:  
- Understand their current Intune posture.  
- Highlight strengths and weaknesses in configuration.  
- Track optimization opportunities and improve overall device and policy management. 

By automating the assessment process, IntuneLens saves administrators time, reduces manual effort, and provides consistent insights that support both day-to-day operations and long-term IT strategy.

## Features

- Device compliance overview  
- App deployment and update status  
- Security baselines and configuration profiles  
- Conditional access and policy insights  
- Detection of expired tokens and misconfigurations  
- Exportable reports for IT management

## Getting Started

### Prerequisites
- PowerShell 7.2+ (recommended)  
- An Entra ID App Registration with delegated Graph API permissions for Intune
- Admin consent granted for those permissions

### Installation
Install IntuneLens module from PowerShell Gallery

```powershell

Install-Module IntuneLens

```

### Usage

Run IntuneLens health check and save report to Markdown file.

```powershell

$report = Get-IntuneLensHealthReport -ClientId '00000000-0000-0000-0000-000000000000' 
Write-IntuneLensReportMD -Path ("./reports/IntuneLens_report_{0}.md" -f (Get-Date -Format 'yyyyMMdd_HHmmss')) -Report $report 

```
The file will be created in the reports/ directory with a timestamp in the name, for example:
./reports/IntuneLens_report_20250908_171234.md

Note: IntuneLens is under active development. Instructions will be updated as the project evolves.

## Contributing

At this stage, code contributions are not open yet.
If you have suggestions or feature ideas, please contact me at: Contribution-IntuneLens@takecio.com

When the project matures, pull request guidelines and coding standards will be published here.

## Security

If you discover a security issue, please do not open a public GitHub issue.
Instead, report it privately by following the instructions in SECURITY.md.

## License

This project is licensed under the MIT License.