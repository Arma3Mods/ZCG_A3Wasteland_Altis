:: make_pbo.bat
::
:: This script makes a PBO out of the current mission and copies it to a given
:: directory based on a match on your Windows username
::

::@ECHO OFF

:: Set your ArmA3 profile name etc. below

IF "%username%" == "Zenon" (
	SET "LOCAL_ARMA_PROFILE=PanaetiusServer"
	:: My local standalone server dir
	SET "PBO_DESTINATION_DIR=C:\DEV\A3Wasteland\"
)

:: General definitions

SET "LOCAL_MISSION_NAME=ArmA3_Wasteland.Altis"
SET "SOURCE_DIR=C:\DEV\A3Wasteland\ArmA3_Wasteland.Altis"
SET "PBO_TOOL=C:\Program Files (x86)\Bohemia Interactive\Tools\BinPBO Personal Edition\BinPBO.exe"

:: Business end

ECHO Packaging into PBO...


"%PBO_TOOL%" "%SOURCE_DIR%" "%PBO_DESTINATION_DIR%"
echo "%PBO_TOOL%" "%SOURCE_DIR%" "%PBO_DESTINATION_DIR%"
echo Created PBO %PBO_DESTINATION_DIR%%LOCAL_MISSION_NAME%.pbo