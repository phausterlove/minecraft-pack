@echo off
setlocal
set PACK=C:\minecraft-pack
cd /d "%PACK%"

echo === Indexing mods ===
"%PACK%\scripts\packwiz.exe" refresh
if errorlevel 1 goto fail

echo === Publishing ===
git add -A
git commit -m "mod update from %computername%"
git pull --rebase
if errorlevel 1 goto fail
git push
if errorlevel 1 goto fail

echo.
echo Published. Tell your brother to run sync_mods.
goto end

:fail
echo.
echo SOMETHING WENT WRONG - show this window to Sam.

:end
pause
endlocal
