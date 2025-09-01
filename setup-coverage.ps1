# setup-coverage.ps1 (ASCII only)

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[i] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[+] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[!] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[x] $m" -ForegroundColor Red }

if (-not (Test-Path "./pubspec.yaml")) { Err "pubspec.yaml not found."; exit 1 }

# Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Err "Flutter not in PATH."; exit 1
}
Ok "Flutter detected."

# dotnet
$dotnet = "C:\Program Files\dotnet\dotnet.exe"
if (-not (Test-Path $dotnet)) { Err "dotnet not found. Install .NET SDK 8 first."; exit 1 }
if (-not (($env:PATH -split ";") -contains "C:\Program Files\dotnet")) {
  $env:PATH = "$env:PATH;C:\Program Files\dotnet"
  Ok "PATH updated with .NET."
} else { Ok ".NET already in PATH." }

# ReportGenerator
$tools = "$env:USERPROFILE\.dotnet\tools"
try {
  $rg = Get-Command reportgenerator -ErrorAction SilentlyContinue
  if ($rg) {
    Info "Updating ReportGenerator..."
    & $dotnet tool update -g dotnet-reportgenerator-globaltool | Out-Null
  } else {
    Info "Installing ReportGenerator..."
    & $dotnet tool install -g dotnet-reportgenerator-globaltool | Out-Null
  }
  if (Test-Path $tools) {
    if (-not (($env:PATH -split ";") -contains $tools)) {
      $env:PATH = "$env:PATH;$tools"
      Ok "PATH updated with dotnet tools."
    }
  } else {
    # add anyway in session
    if (-not (($env:PATH -split ";") -contains $tools)) {
      $env:PATH = "$env:PATH;$tools"
    }
  }
  if (-not (Get-Command reportgenerator -ErrorAction SilentlyContinue)) {
    Err "reportgenerator not in PATH. Close and reopen PowerShell or re-run."; exit 1
  }
  Ok "ReportGenerator ready."
} catch {
  Err ("ReportGenerator install/update failed: " + $_.Exception.Message)
  exit 1
}

# Ensure a test exists
$testDir = "test"
$hasTest = $false
if (Test-Path $testDir) {
  $t = Get-ChildItem $testDir -Filter "*_test.dart" -Recurse -ErrorAction SilentlyContinue
  if ($t) { $hasTest = $true }
}
if (-not $hasTest) {
  Warn "No *_test.dart found. Creating sample test."
  New-Item -ItemType Directory -Force -Path $testDir | Out-Null
  @"
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1 + 1 = 2', () => expect(1 + 1, 2));
}
"@ | Set-Content "$testDir\sample_test.dart" -Encoding UTF8
  Ok "Created test\sample_test.dart"
} else { Ok "Tests detected." }

# pub get
Info "Running flutter pub get..."
flutter pub get | Out-Null

# coverage
New-Item -ItemType Directory -Force -Path "coverage" | Out-Null
$lcov = "coverage\lcov.info"
Info "Running tests with coverage..."
flutter test --coverage --coverage-path=$lcov
if (-not (Test-Path $lcov)) { Err "coverage\lcov.info not generated."; exit 1 }
Ok "lcov.info generated."

# report
$target = "coverage\html"
Info "Generating HTML report..."
reportgenerator -reports:$lcov -targetdir:$target -reporttypes:"Html;HtmlSummary;Badges" | Out-Null
if (-not (Test-Path "$target\index.html")) { Err "index.html not found."; exit 1 }
Ok "Report ready at coverage\html\index.html"

try { Invoke-Item "$target\index.html" } catch { Warn "Open manually: coverage\html\index.html" }

if (Test-Path "$target\badge_linecoverage.svg") { Ok "Badge: coverage\html\badge_linecoverage.svg" }
if (Test-Path "$target\badge_branchcoverage.svg") { Ok "Badge: coverage\html\badge_branchcoverage.svg" }

Ok "All done."
