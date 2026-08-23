@echo off
cd /d "%appdata%\.minecraft"
java -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/phausterlove/minecraft-pack/main/pack.toml
pause
