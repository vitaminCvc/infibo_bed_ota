[CmdletBinding()]
param(
    [string[]]$Edition,
    [switch]$All,
    [string]$Destination,
    [string]$ProjectRoot,
    [string]$FlutterExecutable = 'flutter',
    [string]$DefinitionsPath,
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'Editions.ps1')

$buildAll = $All.IsPresent
$statusPath = $null
$destinationMap = @{}
if ($ConfigPath) {
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $Edition = @($config.editions)
    $buildAll = [bool]$config.all
    if ($config.PSObject.Properties['destination']) {
        $Destination = [string]$config.destination
    }
    $ProjectRoot = [string]$config.projectRoot
    if ($config.PSObject.Properties['definitionsPath']) {
        $DefinitionsPath = [string]$config.definitionsPath
    }
    if ($config.PSObject.Properties['destinations']) {
        foreach ($property in $config.destinations.PSObject.Properties) {
            $destinationMap[$property.Name] = [string]$property.Value
        }
    }
    if ($config.PSObject.Properties['flutterExecutable']) {
        $FlutterExecutable = [string]$config.flutterExecutable
    }
    if ($config.PSObject.Properties['statusPath']) {
        $statusPath = [string]$config.statusPath
    }
}
try {
if ($null -eq $Edition) { $Edition = @() }

if (-not $ProjectRoot) {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
if (-not $DefinitionsPath) {
    $DefinitionsPath = Join-Path $PSScriptRoot 'editions.json'
}
if ($buildAll -and $Edition.Count -gt 0) { throw 'Use either -All or -Edition, not both.' }
if (-not $buildAll -and $Edition.Count -eq 0) { throw 'Choose at least one edition.' }

$ProjectRoot = [IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml') -PathType Leaf)) {
    throw "Flutter project not found: $ProjectRoot"
}

$definitions = @(Get-InfiboEditions -Path $DefinitionsPath)
$selected = if ($buildAll) {
    $definitions
} else {
    foreach ($id in $Edition) {
        $match = @($definitions | Where-Object { $_.Id -eq $id })
        if ($match.Count -ne 1) { throw "Unknown edition: $id" }
        $match[0]
    }
}
$selected = @($selected | Select-Object -Unique -Property Id, Label, Flavor, Target, ApiBaseUrl, IndiaAutoWaterFilling)

foreach ($item in $selected) {
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $item.Target) -PathType Leaf)) {
        throw "Entry point not found: $($item.Target)"
    }
}
Get-Command $FlutterExecutable -ErrorAction Stop | Out-Null

$outputDirectory = Join-Path $ProjectRoot 'build/app/outputs/flutter-apk'
$resolvedDestinations = @{}
foreach ($item in $selected) {
    $folder = if ($destinationMap.ContainsKey($item.Id)) { $destinationMap[$item.Id] } else { $Destination }
    if ([string]::IsNullOrWhiteSpace($folder)) {
        throw "Choose an APK destination for $($item.Label)."
    }
    $folder = [IO.Path]::GetFullPath($folder)
    if ($folder.TrimEnd('\').Equals($outputDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)) {
        throw "Choose a directory outside the Flutter APK output folder for $($item.Label)."
    }
    $resolvedDestinations[$item.Id] = $folder
}
foreach ($folder in @($resolvedDestinations.Values | Select-Object -Unique)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$versionLine = Get-Content -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml') |
    Where-Object { $_ -match '^version:\s*([^\s+]+)' } | Select-Object -First 1
$version = if ($versionLine -and $versionLine -match '^version:\s*([^\s+]+)') {
    $Matches[1]
} else {
    'unknown'
}
$version = $version -replace '[^a-zA-Z0-9._-]', '_'

Push-Location -LiteralPath $ProjectRoot
try {
    $number = 0
    foreach ($item in $selected) {
        $number++
        Write-Output "[$number/$($selected.Count)] Building $($item.Label) ($($item.Flavor))..."
        $arguments = @(
            'build', 'apk', '--release',
            '--flavor', $item.Flavor,
            '--target', $item.Target,
            "--dart-define=API_BASE_URL=$($item.ApiBaseUrl)"
        )
        # 新旧印度版本共用入口和包名，仅通过编译开关区分硬件能力。
        # APK 文件名及保存目录仍按独立的版本 Id 区分，防止新旧安装包混淆。
        if ($item.Flavor -eq 'india') {
            $fillingValue = ([bool]$item.IndiaAutoWaterFilling).ToString().ToLowerInvariant()
            $arguments += "--dart-define=INDIA_AUTO_WATER_FILLING=$fillingValue"
        }
        & $FlutterExecutable @arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter build failed for $($item.Label) (exit code $LASTEXITCODE)."
        }

        $source = Join-Path $outputDirectory "app-$($item.Flavor)-release.apk"
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Flutter reported success but APK was not found: $source"
        }
        if ((Get-Item -LiteralPath $source).Length -eq 0) {
            throw "Flutter reported success but APK is empty: $source"
        }

        $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $baseName = "Infibo_$($item.Id)_v${version}_$stamp"
        $targetDirectory = $resolvedDestinations[$item.Id]
        $target = Join-Path $targetDirectory "$baseName.apk"
        $suffix = 2
        while (Test-Path -LiteralPath $target) {
            $target = Join-Path $targetDirectory "${baseName}_$suffix.apk"
            $suffix++
        }
        Move-Item -LiteralPath $source -Destination $target -ErrorAction Stop
        Write-Output "Saved: $target"
    }
    Write-Output "Completed $($selected.Count) APK(s)."
    if ($statusPath) { Set-Content -LiteralPath $statusPath -Value '0' -Encoding ASCII }
}
finally {
    Pop-Location
}
}
catch {
    if ($statusPath) { Set-Content -LiteralPath $statusPath -Value '1' -Encoding ASCII }
    throw
}
