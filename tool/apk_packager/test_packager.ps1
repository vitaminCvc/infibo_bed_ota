$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$worker = Join-Path $PSScriptRoot 'Build-InfiboApks.ps1'
$testRoot = Join-Path $env:TEMP ('infibo-apk-packager-test-' + [guid]::NewGuid().ToString('N'))
$project = Join-Path $testRoot 'project'
$destination = Join-Path $testRoot 'APK output with spaces'
$mockFlutter = Join-Path $testRoot 'mock-flutter.ps1'
$calls = Join-Path $testRoot 'calls.txt'

function Assert-That([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}

try {
    New-Item -ItemType Directory -Path (Join-Path $project 'lib') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $project 'pubspec.yaml') -Value "name: infibo_app`nversion: 1.2.3+4"
    foreach ($flavor in @('global', 'india', 'spain', 'turkey', 'america', 'britain', 'australia')) {
        Set-Content -LiteralPath (Join-Path $project "lib/main_$flavor.dart") -Value '// fake entry point'
    }
    @'
$flavor = $args[[array]::IndexOf($args, '--flavor') + 1]
$target = $args[[array]::IndexOf($args, '--target') + 1]
$server = @($args | Where-Object { $_ -like '--dart-define=API_BASE_URL=*' })[0]
$filling = @($args | Where-Object { $_ -like '--dart-define=INDIA_AUTO_WATER_FILLING=*' }) -join ''
Add-Content -LiteralPath $env:INFIBO_TEST_CALLS -Value ("$flavor|$target|$server" + $(if ($filling) { "|$filling" }))
if ($flavor -eq $env:INFIBO_TEST_FAIL) { exit 7 }
$output = Join-Path (Get-Location).Path 'build/app/outputs/flutter-apk'
New-Item -ItemType Directory -Path $output -Force | Out-Null
Set-Content -LiteralPath (Join-Path $output "app-$flavor-release.apk") -Value "$flavor|$server"
exit 0
'@ | Set-Content -LiteralPath $mockFlutter -Encoding utf8

    $env:INFIBO_TEST_CALLS = $calls
    $env:INFIBO_TEST_FAIL = ''
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $worker -Edition official -Destination $destination -ProjectRoot $project -FlutterExecutable $mockFlutter | Out-Null
    Assert-That ($LASTEXITCODE -eq 0) 'Official build should succeed.'
    $first = @(Get-ChildItem -LiteralPath $destination -Filter '*.apk')
    Assert-That ($first.Count -eq 1) 'Single selection should produce one APK.'
    Assert-That ($first[0].Name -match '^Infibo_official_v1\.2\.3_') 'APK name should identify edition and app version.'
    Assert-That (-not (Test-Path -LiteralPath (Join-Path $project 'build/app/outputs/flutter-apk/app-global-release.apk'))) 'Built APK should be moved from Flutter output.'
    $officialCall = @(Get-Content -LiteralPath $calls)[0]
    Assert-That ($officialCall -eq 'global|lib/main_global.dart|--dart-define=API_BASE_URL=http://192.241.254.196') "Official build arguments should match the requested configuration. Got: $officialCall"

    Remove-Item -LiteralPath $calls
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $worker -All -Destination $destination -ProjectRoot $project -FlutterExecutable $mockFlutter | Out-Null
    Assert-That ($LASTEXITCODE -eq 0) 'Build all should succeed.'
    $allCalls = @(Get-Content -LiteralPath $calls)
    Assert-That ($allCalls.Count -eq 9) 'Build all should invoke Flutter nine times.'
    Assert-That (@($allCalls | Where-Object { $_ -eq 'global|lib/main_global.dart|--dart-define=API_BASE_URL=http://8.138.247.157' }).Count -eq 1) 'Domestic test should use the China test server.'
    Assert-That ((Get-ChildItem -LiteralPath $destination -Filter '*.apk').Count -eq 10) 'Each edition should create its own APK without overwriting prior builds.'

    Assert-That (@($allCalls | Where-Object { $_ -like 'india|*|--dart-define=INDIA_AUTO_WATER_FILLING=true' }).Count -eq 1) 'India must enable automatic filling.'
    Assert-That (@($allCalls | Where-Object { $_ -like 'india|*|--dart-define=INDIA_AUTO_WATER_FILLING=false' }).Count -eq 1) 'Legacy India must disable automatic filling.'
    Assert-That (@(Get-ChildItem -LiteralPath $destination -Filter 'Infibo_india_legacy_*.apk').Count -eq 1) 'Legacy APK must have a distinct edition filename.'
    $officialFolder = Join-Path $testRoot 'Official APKs'
    $chinaFolder = Join-Path $testRoot 'China test APKs'
    $routeConfigPath = Join-Path $testRoot 'routes.json'
    @{
        editions = @('official', 'china_test')
        all = $false
        destinations = @{ official = $officialFolder; china_test = $chinaFolder }
        projectRoot = $project
    } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $routeConfigPath -Encoding utf8
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $worker -ConfigPath $routeConfigPath -FlutterExecutable $mockFlutter | Out-Null
    Assert-That ($LASTEXITCODE -eq 0) 'Each selected edition should accept its own destination.'
    Assert-That (@(Get-ChildItem -LiteralPath $officialFolder -Filter '*.apk').Count -eq 1) 'Official APK should go to the official folder.'
    Assert-That (@(Get-ChildItem -LiteralPath $chinaFolder -Filter '*.apk').Count -eq 1) 'China test APK should go to the China test folder.'

    $configPath = Join-Path $testRoot 'gui config.json'
    @{
        editions = @('britain')
        all = $false
        destination = $destination
        projectRoot = $project
    } | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding utf8
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $worker -ConfigPath $configPath -FlutterExecutable $mockFlutter | Out-Null
    Assert-That ($LASTEXITCODE -eq 0) 'GUI configuration should be accepted by the worker.'
    Assert-That ((Get-ChildItem -LiteralPath $destination -Filter 'Infibo_britain_*.apk').Count -eq 2) 'Repeated builds must keep both APKs.'

    $env:INFIBO_TEST_FAIL = 'spain'
    $stale = Join-Path $project 'build/app/outputs/flutter-apk/app-spain-release.apk'
    Set-Content -LiteralPath $stale -Value 'stale'
    $ErrorActionPreference = 'Continue'
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $worker -Edition spain -Destination $destination -ProjectRoot $project -FlutterExecutable $mockFlutter *> $null
        $failureExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = 'Stop'
    }
    Assert-That ($failureExitCode -ne 0) 'Failed Flutter build should fail the packager.'
    Assert-That (Test-Path -LiteralPath $stale) 'Failed build must not move a stale APK.'
    $gui = Join-Path $PSScriptRoot 'Apk-Packager-Gui.ps1'
    $guiSmoke = & powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File $gui -SmokeTest
    Assert-That ($LASTEXITCODE -eq 0 -and $guiSmoke -eq 'GUI smoke passed: 9 editions') 'GUI should load all nine editions.'
    $customDefinitions = Join-Path $testRoot 'new editions.json'
    $parsedEditions = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'editions.json') -Raw -Encoding utf8 | ConvertFrom-Json
    $newEditions = @($parsedEditions)
    $newEditions += [pscustomobject]@{ id = 'japan'; label = 'Japan'; flavor = 'japan'; target = 'lib/main_japan.dart'; apiBaseUrl = 'http://192.241.254.196' }
    $newEditions | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $customDefinitions -Encoding utf8
    Set-Content -LiteralPath (Join-Path $project 'lib/main_japan.dart') -Value '// fake entry point'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $worker -DefinitionsPath $customDefinitions -Edition japan -Destination $destination -ProjectRoot $project -FlutterExecutable $mockFlutter | Out-Null
    Assert-That ($LASTEXITCODE -eq 0) 'A newly configured edition should build without changing the worker.'
    $newGuiSmoke = & powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File $gui -SmokeTest -TestDefinitionsPath $customDefinitions
    Assert-That ($LASTEXITCODE -eq 0 -and $newGuiSmoke -eq 'GUI smoke passed: 10 editions') 'A newly configured edition should appear in the GUI.'
    $env:INFIBO_TEST_FAIL = ''
    $settingsPath = Join-Path $testRoot 'saved-destinations.json'
    $guiBuild = & powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File $gui -SmokeBuild -TestProjectRoot $project -TestFlutterExecutable $mockFlutter -TestDestination $destination -TestSettingsPath $settingsPath
    Assert-That ($LASTEXITCODE -eq 0 -and $guiBuild -eq 'GUI build passed') 'GUI button should launch the worker and save the APK.'
    $savedPaths = Get-Content -LiteralPath $settingsPath -Raw -Encoding utf8 | ConvertFrom-Json
    Assert-That ($savedPaths.official -eq $destination) 'The GUI should remember the official edition destination.'
    $savedGuiSmoke = & powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File $gui -SmokeTest -TestDestination $destination -TestSettingsPath $settingsPath
    Assert-That ($LASTEXITCODE -eq 0 -and $savedGuiSmoke -eq 'GUI smoke passed: 9 editions') 'The GUI should reload saved destinations.'
    $guiAllRoot = Join-Path $testRoot 'GUI all destinations'
    $guiAll = & powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File $gui -SmokeBuild -TestBuildAll -TestProjectRoot $project -TestFlutterExecutable $mockFlutter -TestDestination $guiAllRoot
    Assert-That ($LASTEXITCODE -eq 0 -and $guiAll -eq 'GUI build passed') 'GUI build all should finish.'
    foreach ($id in @('official', 'china_test', 'india', 'india_legacy', 'spain', 'turkey', 'america', 'britain', 'australia')) {
        Assert-That (@(Get-ChildItem -LiteralPath (Join-Path $guiAllRoot $id) -Filter '*.apk').Count -eq 1) "GUI build all should route $id to its own directory."
    }
    Write-Output 'Packager tests passed.'
}
finally {
    Remove-Item Env:INFIBO_TEST_CALLS -ErrorAction SilentlyContinue
    Remove-Item Env:INFIBO_TEST_FAIL -ErrorAction SilentlyContinue
    $resolved = [IO.Path]::GetFullPath($testRoot)
    $tempRoot = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
    if ($resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
