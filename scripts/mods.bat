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

echo === Getting latest ===
git pull --rebase
if errorlevel 1 goto fail

echo.
echo === Checking your mods ===
"%PACK%\scripts\packwiz.exe" refresh
if errorlevel 1 goto fail

git add -A
git diff --cached --quiet
if errorlevel 1 (
  echo Changes found. Publishing...
  git commit -m "mod update from %username%"
  if errorlevel 1 goto fail
  git push
  if errorlevel 1 goto fail
  echo Published! Tell the other player to run this too.
) else (
  echo Nothing new to publish.
)

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

:fail
echo.
echo SOMETHING WENT WRONG - show this window to Sam.

:end
echo.
pause
endlocal
