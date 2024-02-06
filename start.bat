@echo off
title LunarCore
pushd %~dp0
cd /d "%~dp0"
cls

set USER_CONFIG_FILE=start.user.bat
if not exist %USER_CONFIG_FILE% (
    call :LOG [ERROR] You need to setup %USER_CONFIG_FILE% properly!
    pause
    exit /b 0
)
call %USER_CONFIG_FILE%

>nul 2>&1 reg query "HKU\S-1-5-19" || (
    call :LOG [WARN] Currently running with non Administrator privileges, raising...
    echo set UAC = CreateObject^("Shell.Application"^) > "%temp%\UAC.vbs"
    echo UAC.ShellExecute "%~f0","%1","","runas",1 >> "%temp%\UAC.vbs"
    "%temp%\UAC.vbs"
    del /f /q "%temp%\UAC.vbs" >nul 2>nul
    exit /b 0
)

call :LOG [INFO] Welcome to LunarCore
call :LOG [INFO] To proper exit this console, use [Ctrl + C] and enter N not Y.
call :LOG [INFO]
call :LOG [INFO] Initializing...

call :LOG [INFO] Starting proxy daemon...
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2^>nul') do set "ORIG_PROXY_ENABLE=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2^>nul') do set "ORIG_PROXY_SERVER=%%b"
echo set ws = createobject("wscript.shell") > "%temp%\proxy.vbs"
echo ws.currentdirectory = "%PROXY_DIR%" >> "%temp%\proxy.vbs"
echo ws.run "cmd /c ProxyTool.exe",0 >> "%temp%\proxy.vbs"
"%temp%\proxy.vbs"
del /f /q "%temp%\proxy.vbs" >nul 2>nul

call :LOG [INFO] Starting MongoDB daemon...
if not exist "%DATABASE_DIR%" md "%DATABASE_DIR%"
echo set ws = createobject("wscript.shell") > "%temp%\db.vbs"
echo ws.currentdirectory = "%MONGODB_DIR%" >> "%temp%\db.vbs"
echo ws.run "cmd /c mongod.exe --dbpath "^&chr(34)^&"%DATABASE_DIR%"^&chr(34)^&"",0 >> "%temp%\db.vbs"
"%temp%\db.vbs"
del /f /q "%temp%\db.vbs" >nul 2>nul

call :LOG [INFO] Starting server...
"%JAVA_DIR%\java.exe" -jar "%SERVER_DIR%\%SERVER_JAR_NAME%"
call :LOG [INFO] Server stopped

call :LOG [INFO] Shutting down MongoDB daemon...
taskkill /t /f /im mongod.exe >nul 2>nul

call :LOG [INFO] Shutting down proxy daemon...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d "%ORIG_PROXY_ENABLE%" /f >nul 2>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%ORIG_PROXY_SERVER%" /f >nul 2>nul
taskkill /t /f /im ProxyTool.exe >nul 2>nul

call :LOG [INFO] See you again :)
goto :EOF

:LOG
echo [%time:~0,8%] %*
