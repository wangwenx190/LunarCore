@echo off
title Building LunarCore ...
setlocal
cls
set PUBLISH_DIR=%~dp0publish
cd /d "%~dp0"
call "%~dp0gradlew.bat" jar
if exist "%PUBLISH_DIR%" rd /s /q "%PUBLISH_DIR%"
md "%PUBLISH_DIR%"
copy /y "%~dp0LunarCore.jar" "%PUBLISH_DIR%"
copy /y "%~dp0keystore.p12" "%PUBLISH_DIR%"
copy /y "%~dp0start.bat" "%PUBLISH_DIR%"
copy /y "%~dp0start.user.bat" "%PUBLISH_DIR%"
xcopy "%~dp0data" "%PUBLISH_DIR%\data" /s /i /q /r /y
echo =================================
echo PUBLISH FINISHED SUCCESSFULLY
echo =================================
endlocal
cd /d "%~dp0"
pause
exit /b 0
