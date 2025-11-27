@echo off
CLS
REM ------------------------------------------------------------------------------------------------------------------------
REM baseline collection tool v1.0
REM by Doug Richmond (defendthehoneypot@gmail.com)
REM
REM About:
REM Script to automate collecting a system baseline
REM
REM Additional Tools Needed:
REM Microsoft pslist.exe, Download and Info: https://technet.microsoft.com/en-us/sysinternals/pslist
REM Microsoft autorunssc.exe, Download and Info: https://technet.microsoft.com/en-us/sysinternals/bb963902
REM Microsoft sigcheck.exe, Download and Info: https://technet.microsoft.com/en-us/sysinternals/bb897441
REM
REM Folder Structure:
REM             - Main Directory containing baseline_tool.cmd
REM                     - Tools: contains binaries for running with the script

REM Setup:
REM Set base folder, set input source file if needed, and make Results directory.
setlocal EnableExtensions EnableDelayedExpansion

SET "scriptlocation=%~dp0"
SET "src=%~1"
IF "%src%"=="" SET "src=C:\"

SET "hour=%time:~0,2%"
IF "%hour:~0,1%"==" " SET "hour=0%hour:~1,1%"
SET "dtstamp=%date:~-4%%date:~4,2%%date:~7,2%_%hour%-%time:~3,2%-%time:~6,2%"

SET "resultsDir=%scriptlocation%Results_%dtstamp%"
IF NOT EXIST "%resultsDir%" mkdir "%resultsDir%"

SET "toolsDir=%scriptlocation%tools"
SET "toolsList=pslist.exe autorunsc.exe sigcheck.exe"
FOR %%T IN (%toolsList%) DO (
    IF NOT EXIST "%toolsDir%\%%T" (
        echo Required tool "%%T" not found in "%toolsDir%". Please download and place it in the Tools directory.
        EXIT /B 1
    )
)

echo Target drive: %src%
echo Output folder: %resultsDir%

echo.
echo #######################################
echo Collect list of all files and folders
echo #######################################
echo.
dir /a /s /r /n /t:c %src% >> "%resultsDir%\baseline-files.txt"

echo.
echo #######################################
echo Collect process list
echo #######################################
echo.
"%toolsDir%\pslist.exe" -accepteula -nobanner -t >> "%resultsDir%\baseline-processlist.txt"

echo.
echo #######################################
echo Collect network information
echo #######################################
echo.
netstat -nao >> "%resultsDir%\baselinenetstat.txt"

echo.
echo #######################################
echo Collect signature check from all files
echo #######################################
echo.
"%toolsDir%\sigcheck.exe" -accepteula -nobanner -c -e -h -r -s %src%   >> "%resultsDir%\baseline-sigcheck.txt"

echo.
echo #######################################
echo Run autorunsc.exe to collect information about autostart locations
echo #######################################
echo.
"%toolsDir%\autorunsc.exe" -accepteula -nobanner -a * -ct >> "%resultsDir%\baseline-autoruns.csv"

echo.
echo #######################################
echo Collect all services
echo #######################################
echo.
sc query >> "%resultsDir%\baseline-services.txt"

echo.
echo Baseline collection complete.
endlocal
