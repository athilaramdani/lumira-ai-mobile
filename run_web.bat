@echo off
echo Menjalankan Firebase Local Emulators di terminal baru...
start cmd /k "firebase emulators:start"

echo Mengunduh dependencies...
call flutter pub get

echo.
echo Menjalankan aplikasi di Chrome dengan disable web security...
call flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=C:\tmp\chrome_dev"

pause
