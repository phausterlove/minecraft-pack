@echo off
setlocal
set PACK=C:\minecraft-pack
set REPO=https://github.com/phausterlove/minecraft-pack.git

where git >nul 2>&1 || (echo Install Git first. & goto end)
where gh >nul 2>&1 || (echo Install GitHub CLI first. & goto end)
gh auth status >nul 2>&1 || (echo Run: gh auth login  -- then run this again. & goto end)

for /f "tokens=*" %%a in ('gh api user --jq .login') do set GHUSER=%%a
echo GitHub user: %GHUSER%

echo === Git identity ===
git config --global user.name "%GHUSER%"
git config --global user.email "%GHUSER%@users.noreply.github.com"
git config --global core.autocrlf false
echo Set.

echo.
echo === Pack repo ===
if exist "%PACK%\.git" (
  cd /d "%PACK%"
  git pull
) else (
  git clone %REPO% "%PACK%"
  if errorlevel 1 goto fail
)

if not exist "%PACK%\scripts\packwiz.exe" (
  echo packwiz.exe MISSING from the clone - tell Sam.
  goto end
)

echo.
echo === Desktop shortcut ===
powershell -c "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\mods.lnk'); $s.TargetPath='%PACK%\scripts\mods.bat'; $s.WorkingDirectory='%PACK%'; $s.Save()"
echo Made.

echo.
echo ================================
echo   DONE
echo ================================
echo STILL BY HAND:
echo   MCreator export path -^> %PACK%\mods\
goto end

:fail
echo.
echo SOMETHING WENT WRONG - show this window to Sam.

:end
echo.
pause
endlocal
