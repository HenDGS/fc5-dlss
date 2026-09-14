param([ValidateSet('Development-Release','Release')][string]$Configuration = 'Release')
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'bootstrap.ps1')
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vsPath) { throw 'Visual Studio 2022 C++ tools not found.' }
$project = Join-Path $PSScriptRoot 'Luma-Framework/Source/Games/Far Cry 5/Far Cry 5.vcxproj'
& (Join-Path $vsPath 'MSBuild/Current/Bin/MSBuild.exe') $project /m "/p:Configuration=$Configuration" /p:Platform=x64 /v:minimal /nologo
if ($LASTEXITCODE -ne 0) { throw "Build failed: $LASTEXITCODE" }
