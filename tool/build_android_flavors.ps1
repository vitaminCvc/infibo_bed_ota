$ErrorActionPreference = 'Stop'

$builds = @(
    @{ Flavor = 'global'; Target = 'lib/main_global.dart' }
    @{ Flavor = 'india'; Target = 'lib/main_india.dart' }
    @{ Flavor = 'spain'; Target = 'lib/main_spain.dart' }
    @{ Flavor = 'turkey'; Target = 'lib/main_turkey.dart' }
)

foreach ($build in $builds) {
    $flavor = $build.Flavor
    Write-Host "Building Android APK for flavor: $flavor"

    & flutter build apk --debug --flavor $flavor --target $build.Target
    if ($LASTEXITCODE -ne 0) {
        throw "Android APK build failed for flavor '$flavor' with exit code $LASTEXITCODE."
    }
}
