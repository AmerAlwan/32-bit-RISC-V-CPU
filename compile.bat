@echo off
REM ============================================================
REM Standalone compile check (RTL + TB)
REM Priority given to SystemVerilog Packages
REM ============================================================

setlocal enabledelayedexpansion

set RTL_DIR=src
set TB_DIR=testbench

set RTL_LIST=rtl_files.f
set TB_LIST=tb_files.f

REM Clean old lists
if exist "%RTL_LIST%" del "%RTL_LIST%"
if exist "%TB_LIST%" del "%TB_LIST%"

echo === Collecting RTL files ===

REM --- PASS 1: Collect Packages Only ---
for /R "%RTL_DIR%" %%f in (*pkg.sv) do (
    echo "%%f" >> "%RTL_LIST%"
    echo   [PRIORITY PKG] %%f
)

REM --- PASS 2: Collect remaining SV files ---
for /R "%RTL_DIR%" %%f in (*.sv) do (
    set "filepath=%%f"
    REM Check if the file was already added as a package
    echo !filepath! | findstr /i "pkg.sv" >nul
    if errorlevel 1 (
        echo "%%f" >> "%RTL_LIST%"
        echo   [RTL] %%f
    )
)

echo === Collecting testbench files ===
for /R "%TB_DIR%" %%f in (*.sv) do (
    echo "%%f" >> "%TB_LIST%"
    echo   [TB] %%f
)

echo.
echo === Compiling All Sources ===
REM We compile RTL and TB together so the TB can see the RTL Packages
call xvlog -sv -f "%RTL_LIST%" -f "%TB_LIST%"
if errorlevel 1 goto :error

echo.
echo ========================================
echo   PASS: Compilation Successful
echo ========================================
exit /b 0

:error
echo.
echo ========================================
echo   ERROR: Compilation Failed
echo ========================================
exit /b 1