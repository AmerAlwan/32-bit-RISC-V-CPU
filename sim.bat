@echo off
REM ============================================================
REM Cleanup: Kill any orphaned simulation processes
REM ============================================================
taskkill /IM xsimk.exe /F 2>nul

REM ============================================================
REM Run Vivado simulation
REM ============================================================
set SCRIPT=scripts\run_sim.tcl

vivado -mode tcl -source "%SCRIPT%" -nolog -nojournal

exit /b %ERRORLEVEL%