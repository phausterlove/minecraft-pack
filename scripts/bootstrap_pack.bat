@echo off
setlocal enabledelayedexpansion
set PACK=C:\minecraft-pack
set REPO=https://github.com/phausterlove/minecraft-pack.git

net session >nul 2>&1
if errorlevel 1 (
  echo Requesting administrator access...
  powershell -c "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo ================================
echo   Minecraft Pack Setup
echo ================================
echo.

where winget >nul 2>&1
if errorlevel 1 (
  echo WINGET NOT FOUND. This needs Windows 11 or App Installer.
  goto end
)

set NEEDRESTART=0

echo === Git ===
where git >nul 2>&1
if errorlevel 1 (
  echo Installing Git...
  winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
  set NEEDRESTART=1
) else (
  echo Already installed.
)

echo.
echo === GitHub CLI ===
where gh >nul 2>&1
if errorlevel 1 (
  echo Installing GitHub CLI...
  winget install --id GitHub.cli -e --silent --accept-package-agreements --accept-source-agreements
  set NEEDRESTART=1
) else (
  echo Already installed.
)

if "!NEEDRESTART!"=="1" (
  echo.
  echo ================================
  echo   HALF DONE - READ THIS
  echo ================================
  echo Software installed. Windows needs a fresh window to see it.
  echo.
  echo   1. Close this window
  echo   2. Open a NEW Command Prompt
  echo   3. Type:  gh auth login
  echo      Pick GitHub.com, HTTPS, Yes, web browser
  echo   4. Run this script again
  goto end
)

echo.
echo === GitHub login ===
gh auth status >nul 2>&1
if errorlevel 1 (
  echo NOT LOGGED IN.
  echo Open a Command Prompt and run:  gh auth login
  echo Then run this script again.
  goto end
)
echo Logged in.

echo.
echo === Pack repo ===
if exist "%PACK%\.git" (
  echo Already cloned. Pulling latest.
  cd /d "%PACK%"
  git pull
) else (
  git clone %REPO% "%PACK%"
  if errorlevel 1 goto fail
)

if not exist "%PACK%\scripts" mkdir "%PACK%\scripts"

echo.
echo === packwiz ===
if exist "%PACK%\scripts\packwiz.exe" (
  echo Already present.
) else (
  echo Downloading packwiz...
  powershell -c "$ErrorActionPreference='Stop'; $r=Invoke-RestMethod https://api.github.com/repos/packwiz/packwiz/releases/latest; $a=$r.assets ^| Where-Object { $_.name -match 'windows' -and $_.name -match '(amd64^|x86_64)' } ^| Select-Object -First 1; if (-not $a) { throw 'no asset' }; Invoke-WebRequest $a.browser_download_url -OutFile '%TEMP%\pw.zip'; Expand-Archive -Force '%TEMP%\pw.zip' '%TEMP%\pw'; Copy-Item (Get-ChildItem -Recurse -Filter packwiz.exe '%TEMP%\pw' ^| Select-Object -First 1).FullName '%PACK%\scripts\packwiz.exe'"
  if not exist "%PACK%\scripts\packwiz.exe" (
    echo AUTO-DOWNLOAD FAILED.
    echo Download packwiz.exe by hand into %PACK%\scripts\ and run this again.
    goto end
  )
  echo Done.
)

echo.
echo === Desktop shortcut ===
copy /y "%PACK%\scripts\mods.bat" "%userprofile%\Desktop\" >nul
if errorlevel 1 (
  echo COULD NOT COPY mods.bat - is it in %PACK%\scripts\ ?
  goto end
)
echo Copied.

echo.
echo ================================
echo   DONE
echo ================================
echo One icon on your Desktop:
echo   mods - shares your mods AND gets your brother's
echo   Run it before you play, and after you make a mod.
echo.
echo STILL BY HAND:
echo   MCreator export path -^> %PACK%\mods\
echo   Be a collaborator on the repo
goto end

:fail
echo.
echo SOMETHING WENT WRONG - show this window to Sam.

:end
echo.
pause
endlocal
