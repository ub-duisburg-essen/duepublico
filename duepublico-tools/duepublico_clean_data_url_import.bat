@echo off
setlocal enabledelayedexpansion

set logtemplate= - duepublico_clean_data_url_import.bat:

REM Parse command line arguments
:parse_args
if "%~1"=="" goto args_done
if "%~1"=="-d" (
    set "mcr_data_directory=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-u" (
    set "data_url=%~2"
    shift
    shift
    goto parse_args
)
shift
goto parse_args

:args_done

REM Check for required arguments
if "%mcr_data_directory%"=="" (
    echo %date% %logtemplate% This script requires flags d and u -> please make them available
    exit /b 1
)
if "%data_url%"=="" (
    echo %date% %logtemplate% This script requires flags d and u -> please make them available
    exit /b 1
)

REM Check for needed environmental files
if not exist .\env\dc.txt (
    echo %date% %logtemplate% This script needs environmental information for decryption - please make them available!
    exit /b 1
)

if not exist ..\duepublico-setup\target\bin\duepublico.cmd (
    echo %date% %logtemplate% Error - Can't find duepublico.cmd in ..\duepublico-setup\target\bin\duepublico.cmd
    exit /b 1
)

REM Check runnable duepublico.cmd (db, solr)
echo %date% %logtemplate% Check runnable duepublico.cmd with database and solr dependencies
for /f "tokens=*" %%i in ('..\duepublico-setup\target\bin\duepublico.cmd show solr configuration ^| findstr /i "Exception"') do (
    set duepublicoStatus=%%i
)

if not "!duepublicoStatus!"=="" (
    echo %date% %logtemplate% Error - duepublico.bat starts with exceptions -> check db, solr
    exit /b 1
)
REM Check for current temp directory
if exist .\env\tmp (
    rmdir /s /q .\env\tmp
)

mkdir .\env\tmp

echo %date% %logtemplate% Start download encrypted mcr data archive from %data_url%
bitsadmin /transfer "DownloadJob" %data_url% .\env\tmp\data.enc

if %errorlevel% neq 0 (
    echo %date% %logtemplate% Error downloading encrypted mcr data archive from %data_url%
    exit /b 1
)

echo %date% %logtemplate% Decrypt mcr data archive
openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in .\env\tmp\data.enc -out .\env\tmp\data.tar.gz -pass file:.\env\dc.txt

