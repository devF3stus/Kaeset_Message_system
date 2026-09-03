Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  KAESET MESSAGE SYSTEM - Release APK Builder" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter SDK is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Flutter SDK from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "Alternatively, push this repository to GitHub and run the automated GitHub Action (.github/workflows/build_apk.yml) to build the APK in the cloud!" -ForegroundColor Green
    Exit 1
}

Write-Host "[1/4] Checking Flutter environment..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "[3/4] Running tests..." -ForegroundColor Yellow
flutter test

Write-Host ""
Write-Host "[4/4] Building Universal Release APK..." -ForegroundColor Yellow
flutter build apk --release

Write-Host ""
Write-Host "Building Architecture Split APKs..." -ForegroundColor Yellow
flutter build apk --split-per-abi

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "[SUCCESS] Release APKs created successfully!" -ForegroundColor Green
Write-Host "Output Directory: build/app/outputs/flutter-apk/" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
