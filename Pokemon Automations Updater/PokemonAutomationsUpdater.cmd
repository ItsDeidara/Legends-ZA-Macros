@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"
cls
color 0B
title Pokemon Automation Updater
echo.
powershell -Command "Write-Host '=====================================================' -ForegroundColor Magenta"
powershell -Command "Write-Host '       Pokemon Automation Updater - Windows' -ForegroundColor Magenta"
powershell -Command "Write-Host '=====================================================' -ForegroundColor Magenta"
echo.
set "URL="
set /p "URL=PASTE DIRECT ZIP URL: (right click and copy link from the discord release button): "
if "%URL%"=="" (
    powershell -Command "Write-Host '[ERROR] No URL entered.' -ForegroundColor Red"
    goto :FAIL
)
for %%F in ("%URL%") do set "ZIPNAME=%%~nxF"
if "%ZIPNAME%"=="" set "ZIPNAME=update.zip"
echo.
powershell -Command "Write-Host '[INFO] Downloading to: %ZIPNAME%' -ForegroundColor Cyan"
echo.
:: --- DOWNLOAD IN ONE LINE (NO ^) ---
powershell -NoProfile -Command "$client = New-Object System.Net.WebClient; try { $client.DownloadFile('%URL%', '%ZIPNAME%'); Write-Host '[SUCCESS] Downloaded' -ForegroundColor Green } catch { Write-Host ('FAILED: ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"
if errorlevel 1 (
    powershell -Command "Write-Host '[ERROR] DOWNLOAD FAILED.' -ForegroundColor Red"
    goto :FAIL
)
if not exist "%ZIPNAME%" (
    powershell -Command "Write-Host '[ERROR] File not created.' -ForegroundColor Red"
    goto :FAIL
)
powershell -Command "Write-Host '[INFO] Extracting...' -ForegroundColor Cyan"
set "TEMP=__extract__"
if exist "%TEMP%" rmdir /S /Q "%TEMP%" >nul 2>nul
mkdir "%TEMP%"
powershell -NoProfile -Command "try { Expand-Archive -Path '%ZIPNAME%' -DestinationPath '%TEMP%' -Force } catch { exit 1 }"
if errorlevel 1 (
    powershell -Command "Write-Host '[ERROR] Extraction failed.' -ForegroundColor Red"
    goto :FAIL
)
set "REPLACED=0"
set "DEST=%CD%"
for /R "%TEMP%" %%F in (*) do (
    set "REL=%%F"
    set "REL=!REL:%TEMP%\=!"
    if exist "!REL!" set /A REPLACED+=1
)
echo.
powershell -Command "Write-Host '[INFO] Destination: %DEST%' -ForegroundColor Cyan"
powershell -Command "Write-Host '[INFO] Replacing files...' -ForegroundColor Cyan"
xcopy /S /Y /Q "%TEMP%\*" "." >nul
if errorlevel 1 (
    powershell -Command "Write-Host '[ERROR] Copy failed.' -ForegroundColor Red"
    goto :FAIL
)
echo.
powershell -Command "Write-Host '=====================================================' -ForegroundColor Green"
powershell -Command "Write-Host '                    SUCCESS!' -ForegroundColor Green"
powershell -Command "Write-Host 'Updated to: %ZIPNAME%' -ForegroundColor Green"
powershell -Command "Write-Host 'Destination: %DEST%' -ForegroundColor Green"
powershell -Command "Write-Host 'Files replaced: %REPLACED%' -ForegroundColor Green"
powershell -Command "Write-Host '=====================================================' -ForegroundColor Green"
goto :CLEANUP
:FAIL
echo.
powershell -Command "Write-Host '=====================================================' -ForegroundColor Red"
powershell -Command "Write-Host '                 UPDATE FAILED' -ForegroundColor Red"
powershell -Command "Write-Host '=====================================================' -ForegroundColor Red"
:CLEANUP
echo.
powershell -Command "Write-Host '[INFO] Cleaning up temporary files...' -ForegroundColor Cyan"
if exist "%ZIPNAME%" (
    del "%ZIPNAME%" >nul 2>nul
    if exist "%ZIPNAME%" (
        powershell -Command "Write-Host '[WARN] Could not delete %ZIPNAME%' -ForegroundColor Yellow"
    ) else (
        powershell -Command "Write-Host '[OK] Deleted %ZIPNAME%' -ForegroundColor Green"
    )
)
if exist "%TEMP%" (
    rmdir /S /Q "%TEMP%" >nul 2>nul
    if exist "%TEMP%" (
        powershell -Command "Write-Host '[WARN] Could not delete %TEMP% folder' -ForegroundColor Yellow"
    ) else (
        powershell -Command "Write-Host '[OK] Deleted %TEMP% folder' -ForegroundColor Green"
    )
)
echo.
echo [PRESS ANY KEY TO CLOSE]
pause >nul
popd
endlocal