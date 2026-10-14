[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('official','china_test')][string]$Channel,
    [string]$ApkPath,
    [string]$AppUrl,
    [string]$FirmwarePath,
    [string]$FirmwareUrl,
    [string]$FirmwareVersion,
    [Parameter(Mandatory=$true)][string]$OutputFile,
    [string]$Notes = '',
    [string]$AaptPath
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
function Assert-DownloadUrl([string]$Url) {
    $uri=$null
    if(-not [Uri]::TryCreate($Url,[UriKind]::Absolute,[ref]$uri) -or $uri.Scheme -ne 'https' -or -not $uri.Host -or $uri.UserInfo -or $uri.Fragment){throw 'Download URLs must use HTTPS.'}
}
function Get-Crc32([byte[]]$Bytes) {
    [uint32]$crc=[uint32]::MaxValue
    foreach($byte in $Bytes){$crc=$crc -bxor $byte;for($bit=0;$bit -lt 8;$bit++){if($crc -band 1){$crc=[uint32](($crc -shr 1) -bxor 0xEDB88320L)}else{$crc=$crc -shr 1}}}
    return [uint32]($crc -bxor [uint32]::MaxValue)
}
if(-not $ApkPath -and -not $FirmwarePath){throw 'Choose at least one APK or firmware file.'}
$manifest=[ordered]@{schema=1;channel=$Channel}
if($ApkPath){
    Assert-DownloadUrl $AppUrl
    $apk=Get-Item -LiteralPath $ApkPath
    if($apk.PSIsContainer -or $apk.Extension -ne '.apk' -or $apk.Length -le 0 -or $apk.Length -gt 512MB){throw 'Invalid APK file.'}
    if(-not $AaptPath){
        $project=Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $local=Join-Path $project 'android/local.properties'
        $sdkLine=Get-Content -LiteralPath $local | Where-Object {$_ -like 'sdk.dir=*'} | Select-Object -First 1
        if(-not $sdkLine){throw 'Android SDK path is unavailable. Supply -AaptPath.'}
        $sdk=$sdkLine.Substring(8).Replace('\\','\').Replace('\:',':')
        $tools=@(Get-ChildItem -LiteralPath (Join-Path $sdk 'build-tools') -Directory | Where-Object {$_.Name -match '^\d+\.\d+\.\d+$'} | Sort-Object {[version]$_.Name} -Descending)
        foreach($tool in $tools){$candidate=Join-Path $tool.FullName 'aapt.exe';if(Test-Path -LiteralPath $candidate -PathType Leaf){$AaptPath=$candidate;break}}
        if(-not $AaptPath){throw 'aapt was not found.'}
    }
    $badging=@(& $AaptPath dump badging $apk.FullName)
    if($LASTEXITCODE -ne 0){throw 'Cannot inspect APK metadata.'}
    $line=@($badging | Where-Object {$_ -like 'package:*'}) | Select-Object -First 1
    if($line -notmatch "^package: name='([^']+)' versionCode='(\d+)' versionName='([^']+)'"){throw 'Invalid APK metadata.'}
    $package=$Matches[1];$code=[int]$Matches[2];$version=$Matches[3]
    if($package -ne 'com.infibo.app.global' -or $code -lt 1 -or $version -notmatch '^\d+\.\d+\.\d+$'){throw 'APK is not an official/test Infibo release.'}
    $manifest.app=[ordered]@{package_name=$package;version=$version;version_code=$code;url=$AppUrl;size=$apk.Length;sha256=(Get-FileHash -LiteralPath $apk.FullName -Algorithm SHA256).Hash.ToLowerInvariant();notes=$Notes}
}
if($FirmwarePath){
    Assert-DownloadUrl $FirmwareUrl
    $firmware=Get-Item -LiteralPath $FirmwarePath
    if($firmware.PSIsContainer -or -not $firmware.Name.EndsWith('_APP_OTA.bin') -or $firmware.Length -lt 8 -or $firmware.Length -gt 2MB){throw 'Choose a valid APP_OTA.bin firmware file.'}
    if($FirmwareVersion -notmatch '^(\d+)\.(\d+)\.(\d+)$'){throw 'Invalid firmware version.'}
    $major=[int]$Matches[1];$minor=[int]$Matches[2];$patch=[int]$Matches[3]
    if($major -gt 15 -or $minor -gt 15 -or $patch -gt 15){throw 'Firmware version cannot fit the register.'}
    $register=($major -shl 8) -bor ($minor -shl 4) -bor $patch
    $manifest.firmware=[ordered]@{product='Immortal-Main-Board';version=$FirmwareVersion;firmware_register=('0x{0:X4}' -f $register);file=$firmware.Name;url=$FirmwareUrl;size=$firmware.Length;sha256=(Get-FileHash -LiteralPath $firmware.FullName -Algorithm SHA256).Hash.ToLowerInvariant();crc32=('0x{0:X8}' -f (Get-Crc32 ([IO.File]::ReadAllBytes($firmware.FullName))));notes=$Notes}
}
$output=[IO.Path]::GetFullPath($OutputFile)
New-Item -ItemType Directory -Path (Split-Path -Parent $output) -Force | Out-Null
[IO.File]::WriteAllText($output,($manifest | ConvertTo-Json -Depth 5)+"`r`n",[Text.UTF8Encoding]::new($false))
Write-Output "Manifest saved: $output"
