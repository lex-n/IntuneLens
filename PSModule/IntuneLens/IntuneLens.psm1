Set-StrictMode -Version Latest

$private = Get-ChildItem -Path "$PSScriptRoot/private" -Filter *.ps1 -File -Recurse -ErrorAction SilentlyContinue
$public = Get-ChildItem -Path "$PSScriptRoot/public"  -Filter *.ps1 -File -ErrorAction SilentlyContinue

# Load private first
$private | ForEach-Object { . $_.FullName }
# Then public (functions to export)
$public  | ForEach-Object { . $_.FullName }

# Export public functions
Export-ModuleMember -Function $public.BaseName