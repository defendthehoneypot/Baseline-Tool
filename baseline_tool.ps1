<#
Baseline collection tool v1.0 (PowerShell)
About:
  Script to automate collecting a system baseline.

Additional Tools Needed:
  Microsoft pslist.exe: https://technet.microsoft.com/en-us/sysinternals/pslist
  Microsoft autorunsc.exe: https://technet.microsoft.com/en-us/sysinternals/bb963902
  Microsoft sigcheck.exe: https://technet.microsoft.com/en-us/sysinternals/bb897441

Folder Structure:
  - Main directory containing baseline_tool.ps1
      - tools: contains binaries for running with the script
#>

[CmdletBinding()]
param(
    [string]$SourcePath = 'C:\'
)

$ErrorActionPreference = 'Stop'

# Resolve important paths
$scriptLocation = Split-Path -Parent $PSCommandPath
$timestamp = Get-Date -Format 'yyyyMMdd_HH-mm-ss'
$resultsDir = Join-Path -Path $scriptLocation -ChildPath "Results_$timestamp"
$toolsDir = Join-Path -Path $scriptLocation -ChildPath 'tools'
$toolsList = @('pslist.exe', 'autorunsc.exe', 'sigcheck.exe')

# Ensure results directory exists
if (-not (Test-Path -LiteralPath $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

# Validate required tools are present
foreach ($tool in $toolsList) {
    $toolPath = Join-Path -Path $toolsDir -ChildPath $tool
    if (-not (Test-Path -LiteralPath $toolPath)) {
        Write-Error "Required tool '$tool' not found in '$toolsDir'. Please download and place it in the tools directory."
    }
}

Write-Output "Target drive: $SourcePath"
Write-Output "Output folder: $resultsDir"
Write-Output ''

# Collect list of all files and folders
Write-Output '#######################################'
Write-Output 'Collect list of all files and folders'
Write-Output '#######################################'
Write-Output ''
cmd.exe /c "dir /a /s /r /n /t:c \"$SourcePath\"" | Out-File -FilePath (Join-Path $resultsDir 'baseline-files.txt') -Encoding UTF8

# Collect process list
Write-Output '#######################################'
Write-Output 'Collect process list'
Write-Output '#######################################'
Write-Output ''
& (Join-Path $toolsDir 'pslist.exe') -accepteula -nobanner -t | Out-File -FilePath (Join-Path $resultsDir 'baseline-processlist.txt') -Encoding UTF8

# Collect network information
Write-Output '#######################################'
Write-Output 'Collect network information'
Write-Output '#######################################'
Write-Output ''
netstat -nao | Out-File -FilePath (Join-Path $resultsDir 'baselinenetstat.txt') -Encoding UTF8

# Collect signature check from all files
Write-Output '#######################################'
Write-Output 'Collect signature check from all files'
Write-Output '#######################################'
Write-Output ''
& (Join-Path $toolsDir 'sigcheck.exe') -accepteula -nobanner -c -e -h -r -s "$SourcePath" |
    Out-File -FilePath (Join-Path $resultsDir 'baseline-sigcheck.txt') -Encoding UTF8

# Run autorunsc.exe to collect information about autostart locations
Write-Output '#######################################'
Write-Output 'Run autorunsc.exe to collect information about autostart locations'
Write-Output '#######################################'
Write-Output ''
& (Join-Path $toolsDir 'autorunsc.exe') -accepteula -nobanner -a * -ct |
    Out-File -FilePath (Join-Path $resultsDir 'baseline-autoruns.csv') -Encoding UTF8

# Collect all services
Write-Output '#######################################'
Write-Output 'Collect all services'
Write-Output '#######################################'
Write-Output ''
sc.exe query | Out-File -FilePath (Join-Path $resultsDir 'baseline-services.txt') -Encoding UTF8

Write-Output ''
Write-Output 'Baseline collection complete.'
