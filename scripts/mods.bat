@echo off
setlocal
set PACK=C:\minecraft-pack
set MC=%appdata%\.minecraft

if not exist "%PACK%\.git" (
  echo Pack folder not found at %PACK%
  echo Run bootstrap_pack.bat first.
  goto end
)

cd /d "%PACK%"

echo === Checking your mods ===
"%PACK%\scripts\packwiz.exe" refresh
if errorlevel 1 goto fail

REM Commit local changes FIRST so a re-exported mod never blocks the pull
git add -A
git diff --cached --quiet
if errorlevel 1 (
  echo Local changes found. Saving...
  git commit -m "mod update from %username%"
  if errorlevel 1 goto fail
)

echo.
echo === Getting latest ===
git pull --rebase
if errorlevel 1 goto pullfail

echo.
echo === Publishing ===
git push
if errorlevel 1 goto fail

echo.
echo === Updating your game ===
cd /d "%MC%"
java -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/phausterlove/minecraft-pack/main/pack.toml
if errorlevel 1 goto fail

echo.
echo ================================
echo   ALL DONE - go play
echo ================================
goto end

:pullfail
echo.
echo Could not merge with the other player's changes.
echo (Did you both edit the same mod at the same time?)
echo Show this window to Sam. To recover, Sam can run:
echo    cd C:\minecraft-pack ^&^& git rebase --abort
goto end

:fail
echo.
echo SOMETHING WENT WRONG - show this window to Sam.

:end
echo.
pause
endlocal