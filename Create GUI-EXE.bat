@echo off
echo Simple AAB to APK Converter Builder
echo ===================================
echo.

REM Check if Python is installed
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Python is not installed or not in PATH
    pause
    exit /b
)

REM Install PyInstaller if not already installed
echo Installing PyInstaller...
pip install pyinstaller

REM Create the executable
echo Creating executable...
pyinstaller --onefile --windowed aab_to_apk_converter.py

echo.
echo Build completed!
echo The executable is located in the "dist" folder.
echo.
echo Remember to:
echo 1. Include bundletool.jar in the same folder as the executable
echo 2. Ensure Java is installed on the target system
echo.

pause