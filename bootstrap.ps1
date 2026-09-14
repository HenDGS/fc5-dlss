param()
$ErrorActionPreference = 'Stop'
function Invoke-Git([string[]]$Arguments) {
    & git @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($Arguments -join ' ')" }
}
$upstream = Join-Path $PSScriptRoot 'Luma-Framework'
Invoke-Git @('-C', $PSScriptRoot, 'submodule', 'update', '--init', '--', 'Luma-Framework')
Invoke-Git @('-C', $upstream, 'submodule', 'update', '--init', '--', 'Source/External/reshade')
$reshade = Join-Path $upstream 'Source/External/reshade'
Invoke-Git @('-C', $reshade, 'submodule', 'update', '--init', '--', 'deps/imgui', 'deps/minhook', 'deps/stb')
foreach ($patch in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'patches') -Filter '*.patch' -File -ErrorAction SilentlyContinue) {
    # A failed reverse check is expected on a fresh clone. Windows PowerShell
    # 5.1 converts redirected native stderr to errors under Stop.
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & git -C $upstream apply --reverse --check $patch.FullName 2>$null
        $alreadyApplied = $LASTEXITCODE -eq 0
    } finally { $ErrorActionPreference = $previousPreference }
    if ($alreadyApplied) { continue }
    Invoke-Git @('-C', $upstream, 'apply', '--check', $patch.FullName)
    Invoke-Git @('-C', $upstream, 'apply', $patch.FullName)
}
# Only the FC5 overlay is materialized. Preserve any differing previous copy.
$backup = Join-Path $PSScriptRoot ('backups/overlay-' + [guid]::NewGuid().ToString('N'))
foreach ($folder in @('Source/Games/Far Cry 5', 'Shaders/Far Cry 5')) {
    $source = Join-Path $PSScriptRoot $folder
    foreach ($file in Get-ChildItem -LiteralPath $source -File) {
        $relative = Join-Path $folder $file.Name
        $target = Join-Path $upstream $relative
        if (Test-Path -LiteralPath $target) {
            if ((Get-FileHash -LiteralPath $target).Hash -eq (Get-FileHash -LiteralPath $file.FullName).Hash) { continue }
            $saved = Join-Path $backup $relative
            New-Item -ItemType Directory -Path (Split-Path $saved) -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $saved
        }
        New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target
    }
}
if (Test-Path -LiteralPath $backup) { Write-Host "Previous overlay preserved: $backup" }
Write-Host 'Pinned upstream and FC5 overlay ready. No game files changed.'
