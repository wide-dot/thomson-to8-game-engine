@echo off
REM Wrapper Windows - delegue a install.py
cd /d "%~dp0"
python install.py %*
