@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
 
set /p command=Enter the command name :

set /p location=Enter the full path of the batch file :

call :check_file_exists "%location%"
call :add_command_to_registry "%command%" "%location%"

echo Done!
pause
exit /b

:check_file_exists
if not exist "%~1" (
    echo Batch file not found. Please check the path and try again.
    pause
    exit /b
)
exit /b

:add_command_to_registry
reg add "HKCU\Software\Microsoft\Command Processor" /v "AutoRun" /t REG_EXPAND_SZ /d "%~2 %~1" /f

if %errorlevel% neq 0 (
    echo Failed to add command to CMD. Please try again or run as administrator.
    pause
    exit /b
)
exit /b
