@echo off
start "" powershell.exe -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0tool\apk_packager\Apk-Packager-Gui.ps1"
