param(
    [ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+[-.a-zA-Z0-9]*$')][string]$Version = 'v1.0.0',
    [string]$AddonPath,
    [string]$ExpectedAddonSHA256
)
$ErrorActionPreference = 'Stop'
$upstream = Join-Path $PSScriptRoot 'Luma-Framework'
if (!$AddonPath) { $AddonPath = Join-Path $upstream 'Binaries/x64-Release/Luma-FarCry5.addon64' }
$addon = Get-Item -LiteralPath $AddonPath
$addonHash = (Get-FileHash -LiteralPath $addon.FullName).Hash
if ($ExpectedAddonSHA256 -and $addonHash -ne $ExpectedAddonSHA256) { throw 'Addon provenance hash mismatch.' }
$runtime = Join-Path $upstream 'Source/External/NGX/bin/rel/nvngx_dlss.dll'
if (!(Test-Path -LiteralPath $runtime)) { throw 'Pinned NVIDIA DLSS runtime missing.' }
$sourceCommit = & git -C $PSScriptRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Commit the source before packaging.' }
$sourceChanges = & git -C $PSScriptRoot status --porcelain --untracked-files=all --ignore-submodules=all
if ($LASTEXITCODE -ne 0 -or $sourceChanges) { throw 'Commit all source changes before packaging.' }
$upstreamCommit = & git -C $upstream rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Pinned upstream missing.' }

$displayVersion = $Version.TrimStart('v')
$destination = Join-Path $PSScriptRoot "artifacts/Far-Cry-5-DLSS-$Version.zip"
if (Test-Path -LiteralPath $destination) { throw 'Archive already exists; preserve it or choose a new version.' }
$stage = Join-Path $PSScriptRoot ('artifacts/stage-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$stage/bin/Luma","$stage/licenses" -Force | Out-Null
Copy-Item -LiteralPath $addon.FullName -Destination "$stage/bin/Luma-FarCry5.addon64"
Copy-Item -LiteralPath $runtime -Destination "$stage/bin/nvngx_dlss.dll"

foreach ($folder in @('Global', 'Includes', 'Far Cry 5')) {
    $root = if ($folder -eq 'Far Cry 5') { Join-Path $PSScriptRoot "Shaders/$folder" } else { Join-Path $upstream "Shaders/$folder" }
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File) {
        if ($file.Extension -notin @('.hlsl','.hlsli')) { continue }
        $relative = $file.FullName.Substring($root.Length).TrimStart('\','/')
        if ($relative -match '(^|[\\/])(Dev|Unused|Sample|Textures|Dump|Captures)([\\/]|$)') { continue }
        $target = Join-Path "$stage/bin/Luma/$folder" $relative
        New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target
    }
}

Copy-Item -LiteralPath "$PSScriptRoot/README.md","$PSScriptRoot/LICENSE.md","$PSScriptRoot/THIRD-PARTY-NOTICES.md" -Destination $stage
Get-ChildItem -LiteralPath "$PSScriptRoot/licenses" -File | Copy-Item -Destination "$stage/licenses"
$files = @(Get-ChildItem -LiteralPath $stage -Recurse -File | Sort-Object FullName | ForEach-Object {
    [ordered]@{ Path=$_.FullName.Substring($stage.Length+1).Replace('\','/'); Bytes=$_.Length; SHA256=(Get-FileHash -LiteralPath $_.FullName).Hash }
})
$forbidden = @($files | Where-Object { $_.Path -match '(?i)sdd|docs/|test-control|\.request$|\.ini$|\.pdb$|\.log$|\.cso$|FarCry5\.exe|gamerprofile' })
if ($forbidden.Count) { throw 'Forbidden development or personal files found in package.' }
$manifest = [ordered]@{
    Name='Far Cry 5 DLSS / DLAA'; Version=$displayVersion
    SourceCommit=$sourceCommit; UpstreamCommit=$upstreamCommit
    AddonSHA256=$addonHash; CreatedUTC=[DateTime]::UtcNow.ToString('o'); Files=$files
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "$stage/manifest.json" -Encoding UTF8
Compress-Archive -Path "$stage/*" -DestinationPath $destination
$archiveHash = (Get-FileHash -LiteralPath $destination).Hash
"$archiveHash  $([IO.Path]::GetFileName($destination))" | Set-Content -LiteralPath ($destination + '.sha256') -Encoding ASCII
Write-Host "Packaged $($files.Count) files: $destination"
Write-Host "SHA256: $archiveHash"
