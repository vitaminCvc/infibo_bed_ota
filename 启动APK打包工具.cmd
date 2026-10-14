@echo off
set "PACKAGER=%~dp0..\infibo_app_v1.0_1610\tool\apk_packager\Apk-Packager-Gui.ps1"
if not exist "%PACKAGER%" (
  echo Shared APK packager was not found. Keep infibo_ota next to infibo_app_v1.0_1610.
  pause
  exit /b 1
)
start "" powershell.exe -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "%PACKAGER%"
