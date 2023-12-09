#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\Users\Admin\Documents\GitHub\GW-Template-Updater\Source\SaveIcon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <File.au3>
#include "Source\Zip.au3" ;https://github.com/J2TEAM/AutoIt-UDF-Collection/blob/master/UDF/ZIP/zip.au3
#include <WinAPIFiles.au3>
#include <InetConstants.au3>
#include <Date.au3>
#include <FileConstants.au3>
#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $sFilePath = "Templates.zip"

Global $aTitle = "GW Template Updater"

Global $aVersion = "1.0"

Global $hDownload = InetGet ("https://www.dropbox.com/scl/fo/b6yce5ukdnuboe3fyfjbn/h?rlkey=zxqirzjh1xk8s3lbai5piaw50&dl=1", $sFilePath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

ProgressOn($aTitle & " " & $aVersion, "Updateing your templates")

ProgressSet(0, "Downloading Files...")

    Do
        Sleep(250)
    Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

	InetClose($hDownload)

ProgressSet(20, "Unzip Files...")

_Zip_UnzipAll(@ScriptDir & "\Templates.zip", @ScriptDir & "\TEMP\Templates - TEMP\",1); Before I had _Zip_Unzip. This is the Temp Folder


local $patchfiles
$patchfiles = _FileListToArrayRec(@ScriptDir&"\TEMP\Templates - TEMP\","*",1,1,0,2)
$currentfiles = _FileListToArrayRec(@ScriptDir,"*|""|TEMP;Gallery",1,1,0,2)
_ArrayDelete($patchfiles,0)
_ArrayDelete($currentfiles,0)

$patchTimes = $patchfiles
$currentTimes = $currentfiles
ReDim $patchTimes[UBound($patchfiles)][3]
ReDim $currentTimes[UBound($currentfiles)][3]

For $i = 1 To UBound($patchfiles)-1
$patchTimes[$i][0] = $patchfiles[$i]
$patchTimes[$i][1] = StringRegExpReplace($patchfiles[$i],".*\\","")
$patchfolder = StringRegExpReplace($patchfiles[$i],".*Templates - TEMP\\","")
$patchTimes[$i][2] = $patchfolder
Next

For $i = 1 To UBound($currentfiles)-1
$currentTimes[$i][0] = $currentfiles[$i]
$currentTimes[$i][1] = StringRegExpReplace($currentfiles[$i],".*\\","")
$patchfolder = StringRegExpReplace($currentfiles[$i],".*Templates - TEMP\\","")
$currentTimes[$i][2] = $patchfolder
Next

ProgressSet(60, "Moving templates...")

For $i=0 To UBound($patchfiles)-1
$index = _ArraySearch($currentTimes, $patchTimes[$i][1])
ConsoleWrite($patchTimes[$i][1]&@CRLF)
If $index < 0 Then
	ConsoleWrite("File does not already exist. Going to create "& $patchTimes[$i][0] &@CRLF)
	FileCopy($patchTimes[$i][0],@ScriptDir&"\"&$patchTimes[$i][2],$FC_CREATEPATH + $FC_OVERWRITE )
	ContinueLoop
EndIf

If _CompareFileTimeEx($patchTimes[$i][0],$currentTimes[$index][0],2) > 0 Then
	FileCopy($patchTimes[$i][0],@ScriptDir&"\"&$patchTimes[$i][2],$FC_CREATEPATH + $FC_OVERWRITE )
ConsoleWrite("copy "& $patchTimes[$i][0] & " to " &@ScriptDir&"\"&$patchTimes[$i][2]&@CRLF)
EndIf
Next

ProgressSet(80, "Deleting demporary files...")


FileDelete("Templates.zip")
DirRemove("TEMP",1)


ProgressSet(100, "Done...")

Sleep(3000)

ProgressOff()

MsgBox("", "Update Finished", "Your templates are up to date. Enjoy!" & @CRLF & "Greets Taki :)" & @CRLF & @CRLF & "Ingame: Take Luvz Rupts" & @CRLF & "Discord: droog__")



Func _CompareFileTimeEx($hSource, $hDestination, $iMethod)
;   Parameters ....:    $hSource -      Full path to the first file
;                       $hDestination - Full path to the second file
;                       $iMethod -      0   The date and time the file was created
;                                       1   The date and time the file was accessed
;                                       2   The date and time the file was modified
;   Return values .:                    -1  First file time is earlier than second file time
;                                       0   First file time is equal to second file time
;                                       1   First file time is later than second file time
;   Author ........:    Ian Maxwell (llewxam @ AutoIt forum)
    Local $hCurrent[2] = [$hSource, $hDestination], $tPointer[2] = ["", ""]
    For $iPointerCount = 0 To 1
        $hFile = _WinAPI_CreateFile($hCurrent[$iPointerCount], 2)
        $aTime = _Date_Time_GetFileTime($hFile)
        _WinAPI_CloseHandle($hFile)
        $aDate = _Date_Time_FileTimeToStr($aTime[$iMethod])
        $tFile = _Date_Time_EncodeFileTime(StringMid($aDate, 1, 2), StringMid($aDate, 4, 2), StringMid($aDate, 7, 4), StringMid($aDate, 12, 2), StringMid($aDate, 15, 2), StringMid($aDate, 18, 2))
        $aDOS = _Date_Time_FileTimeToDOSDateTime(DllStructGetPtr($tFile))
        $tFileTime = _Date_Time_DOSDateTimeToFileTime("0x" & Hex($aDOS[0], 4), "0x" & Hex($aDOS[1], 4))
        $tPointer[$iPointerCount] = DllStructGetPtr($tFileTime)
    Next
    Return _Date_Time_CompareFileTime($tPointer[0], $tPointer[1])
EndFunc   ;==>_CompareFileTimeEx