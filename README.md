# IntuneLens

IntuneLens is a PowerShell module designed to help IT managers and administrators assess health and configuration of Microsoft Intune environment. It collects and analyzes data from Microsoft Intune via Graph API, calculates Intune health score and presents key information in the easy-to-understand reports.

The goal of this project is to make it easier for organizations to:  
- Understand current Intune posture.
- Highlight strengths and weaknesses in Intune configuration.
- Track optimization opportunities and improve overall device and policy management.

By automating the assessment process, IntuneLens saves administrators time, reduces manual effort, and provides consistent insights that support both day-to-day operations and long-term IT strategy.

## Features

- Entra ID overview
- Intune tenant overview
- Device compliance overview - In development
- App deployment and update status - In development
- Security baselines and configuration profiles - In development
- Conditional access and policy insights - In development
- Detection of expired tokens and misconfigurations - In development
- Exportable reports for IT management - In development

## Getting Started

### Prerequisites
- PowerShell 7.2+ (recommended)  
- An Entra ID App Registration with delegated Graph API permissions for Intune
- Admin consent granted for those permissions

### Installation
The required modules are available in the PowerShell Gallery.
Installation steps:

```powershell

Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module IntuneLens

```

### Usage

Run IntuneLens health check and display the report in the console.

```powershell
# Connect to your tenant
Connect-IntuneLens

# Build and display the report
Get-IntuneLensHealthOverview

# (Optional) Build and display the report with sensitive tenant information
# (such as Organization name, Default domain, Tenant creation datetime) masked
Get-IntuneLensHealthOverview -Protected

# Clear the current IntuneLens session
Disconnect-IntuneLens

```

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