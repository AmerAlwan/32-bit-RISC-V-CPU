@echo off
REM ============================================================
REM Run Vivado TCL script with clean output (no echoed commands)
REM ============================================================

set SCRIPT=scripts\create_project.tcl

REM Run Vivado and filter out TCL command echo lines
vivado -mode tcl -source "%SCRIPT%" -nolog -nojournal 2>&1 ^
  | findstr /R /V "^[#]"

REM Preserve Vivado exit code
exit /b %ERRORLEVEL%
