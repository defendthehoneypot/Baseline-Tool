@echo off
CLS
REM ------------------------------------------------------------------------------------------------------------------------
REM baseline collection tool v1.0
REM by Doug Richmond (doug@defendthehoneypot.com)
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
REM		- Main Directory containing baseline_tool.cmd
REM			- Tools: contains binaries for running with the script

REM Setup:
REM Set base folder, set input source file if needed, and make Results directory.
SET scriptlocation=%~dp0
SET src=%1
SET dtstamp=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
mkdir Results_%dtstamp%

echo.
echo #######################################
echo Collect list all files and folders on the C drive
echo #######################################
echo.
dir /a /s /r /n /t C c:\  >> %scriptlocation%Results_%dtstamp%\baseline-files.txt

echo.
echo #######################################
echo Collect process list
echo #######################################
echo.
%scriptlocation%\tools\pslist.exe -accepteula -nobanner -t >> %scriptlocation%Results_%dtstamp%\baseline-processlist.txt

echo.
echo #######################################
echo Collect network information
echo #######################################
echo.
netstat -nao >> %scriptlocation%Results_%dtstamp%\baselinenetstat.txt

echo.
echo #######################################
echo Collect signature check from all files
echo #######################################
echo.
%scriptlocation%\tools\sigcheck.exe -accepteula -nobanner -c -e -h -r -s c:\   >> %scriptlocation%Results_%dtstamp%\baseline-sigcheck.txt

echo.
echo #######################################
echo Run autorunsc.exe to collect information about autostart locations
echo #######################################
echo.
%scriptlocation%\tools\autorunsc.exe -accepteula -nobanner -a * -ct >> %scriptlocation%Results_%dtstamp%\baseline-autoruns.csv

echo.
echo #######################################
echo Collect all services
echo #######################################
echo.
sc query >> %scriptlocation%Results_%dtstamp%\baseline-services.txt