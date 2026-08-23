@echo off
setlocal
set MC=%appdata%\.minecraft

echo === Backing up existing mods folder ===
if exist "%MC%\mods" (
    if exist "%userprofile%\Desktop\mods_backup" rd /s /q "%userprofile%\Desktop\mods_backup"
    xcopy "%MC%\mods" "%userprofile%\Desktop\mods_backup\" /e /i /q
    echo Backup saved to Desktop\mods_backup
) else (
    echo No existing mods folder found.
)

echo === Copying files ===
copy /y "%~dp0packwiz-installer-bootstrap.jar" "%MC%\"
copy /y "%~dp0sync_mods.bat" "%MC%\"

powershell -c "Unblock-File -Path '%MC%\packwiz-installer-bootstrap.jar'" 2>nul

echo === Syncing mods ===
cd /d "%MC%"
call sync_mods.bat

endlocal
