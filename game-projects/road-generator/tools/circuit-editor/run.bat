@echo off
REM Wrapper Windows - delegue a run.py
cd /d "%~dp0"
python run.py %*
