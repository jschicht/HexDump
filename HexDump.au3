#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WinAPI.au3>
Dim $nBytes
If $cmdline[0] <> 3 Then
	ConsoleWrite("Usage:" & @CRLF)
	ConsoleWrite("HexDump InputFilename Filepos Numbytes" & @CRLF)
	ConsoleWrite("-InputFilename can be a filename or volume/disk path" & @CRLF)
	ConsoleWrite("-Filepos and numbytes can be in decimal or hex" & @CRLF)
	ConsoleWrite("-Numbytes of 0 will resolve to filesize" & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite("Examples:" & @CRLF)
	ConsoleWrite("HexDump D:\diskimage.img 0x2800 0x200" & @CRLF)
	ConsoleWrite("HexDump C: 0x0 0x200" & @CRLF)
	ConsoleWrite("HexDump PhysicalDrive1 0x0 0x200" & @CRLF)
	Exit
EndIf
If StringInStr($cmdline[1],"PhysicalDrive")=0 And (StringInStr($cmdline[1],":\")>0 And StringLen($cmdline[1]) > 3) Then
	If Not FileExists($cmdline[1]) Then
		ConsoleWrite("Error: File not found" & @CRLF)
		Exit
	EndIf
EndIf
$FilePos = $cmdline[2]
$FilePos = StringReplace($FilePos,"0x","")
$NumBytes = $cmdline[3]
$NumBytes = StringReplace($NumBytes,"0x","")
If StringIsDigit($NumBytes)=0 And StringIsXDigit($NumBytes)=0 Then
	ConsoleWrite("Error: Number of bytes must be in deciaml or hexadecimal" & @CRLF)
	Exit
EndIf
If StringIsDigit($FilePos)=0 And StringIsXDigit($FilePos)=0 Then
	ConsoleWrite("Error: File offset must be in deciaml or hexadecimal" & @CRLF)
	Exit
EndIf
If StringIsXDigit($FilePos) Then $FilePos = Dec($FilePos,2)
If StringIsXDigit($NumBytes) Then $NumBytes = Dec($NumBytes,2)
If $NumBytes = 0 Then $NumBytes = FileGetSize($cmdline[1])
$tBuffer = DllStructCreate("byte[" & $NumBytes & "]")
$hFile = _WinAPI_CreateFile("\\.\" & $cmdline[1], 2, 2, 6)
If $hFile = 0 Then
	ConsoleWrite("Error in function CreateFile: " & _WinAPI_GetLastErrorMessage() & @CRLF)
	_WinAPI_CloseHandle($hFile)
	Exit
EndIf
_WinAPI_SetFilePointerEx($hFile, $FilePos, $FILE_BEGIN)
_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $NumBytes, $nBytes)
$rData = DllStructGetData($tBuffer,1)
$OutPut = _HexEncode($rData)
If Not @error Then
	ConsoleWrite("Hexdump of: " & $cmdline[1] & @CRLF)
	ConsoleWrite($OutPut)
Else
	ConsoleWrite("Error: Dumping of file failed" & @CRLF)
EndIf

Func _WinAPI_SetFilePointerEx($hFile, $iPos, $iMethod = 0)
	Local $Ret = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', $iPos, 'int64*', 0, 'dword', $iMethod)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf
    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")

    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)

    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf
    Return SetError(0, 0, DllStructGetData($tOut, 1))
EndFunc