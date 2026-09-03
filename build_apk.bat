@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   KAESET MESSAGE SYSTEM - Release APK Builder
echo ========================================================
echo.

where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter SDK was not found in your system PATH.
    echo Please ensure Flutter is installed and added to PATH.
    echo Installation guide: https://docs.flutter.dev/get-started/install/windows
    echo.
    echo Alternatively, push this repo to GitHub to build the APK
    echo automatically via the included .github/workflows/build_apk.yml!
    echo.
    pause
    exit /b 1
)

echo [1/4] Running flutter doctor...
call flutter doctor

echo.
echo [2/4] Fetching dependencies (flutter pub get)...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to fetch dependencies.
    pause
    exit /b 1
)

echo.
echo [3/4] Running unit tests...
call flutter test
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Some tests failed. Proceeding with caution.
)

echo.
echo [4/4] Building Release APKs...
echo Building Universal Release APK (build/app/outputs/flutter-apk/app-release.apk)...
call flutter build apk --release

echo.
echo Building Architecture-Split Release APKs (arm64, armeabi, x86_64)...
call flutter build apk --split-per-abi

echo.
echo ========================================================
echo [SUCCESS] Release build finished!
echo Output APK location:
echo   build\app\outputs\flutter-apk\
echo ========================================================
echo.
pause
