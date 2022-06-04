#Include <Gdip_All>

;--------------------- Environment variables-----------------------------------
;The following variable should be adjusted due to persoanl envrionment

_primaryScreenNumber := 1
_secondScreenNumber := 2
_primaryScreenScaleFactor := 1.5
_secondScreenScaleFactor := 1.25


;-----------------------End of Environment variables---------------------------



;Don't Edit if you don't know what impact will happen
;Check if the destination folder exists or not
_configFile := "config.ini"
_destinationFolder := 
if !FileExist(_configFile)
{
    _destinationFolder := CreateFolderFunc()
    file := FileOpen(_configFile, "rw")
    if !IsObject(file)
    {
        MsgBox Can't open "%_configFile%" for writing.
        ExitApp
    }
    IniWrite, %_destinationFolder%, %_configFile%, "ConfigSection" , screenshotsfolder

}
Else
{
    IniRead, _destinationFolder, %_configFile%, "ConfigSection", screenshotsfolder
}

IfEqual, _destinationFolder, ERROR
{
    MsgBox No Destination Folder selected please delete %_configFile% in script folder and rerun the script.
    ExitApp
}



CoordMode, Mouse, Screen
; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
	ExitApp
}
OnExit("ExitFunc")

;1. Feature: Take screenshot from dedicated area
; Howto: Hold ctr, alt button and draw area with mouse, the screenshot from the area will taken and stored into _fileName specificed location
;-----------------------Start the implementation-----------------------------------------------------

^!LButton::
    MouseGetPos, Xi, Yi
Return

^!LButton up::
    pToken := Gdip_Startup()
    MouseGetPos, Xf, Yf
 
    If (Xi > Xf)
    {
        Aux := Xi 
        Xi := Xf 
        Xf := Aux
    }
    If (Yi > Yf)
    {
        Aux := Yi 
        Yi := Yf 
        Yf := Aux
    }
    
	nL := Xi 	; convert the Left,top, right, bottom into left, top, width, height
    nT := Yi
    nW := Xf - Xi
    nH := Yf - Yi
    M := GetMonitorInfo(_secondScreenNumber)
	_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
    if ( nL >= _x )
    {
        nL /= _primaryScreenScaleFactor
        nL *= _secondScreenScaleFactor
        nW /= _primaryScreenScaleFactor
        nw *= _secondScreenScaleFactor
        nH /= _primaryScreenScaleFactor
        nH *= _secondScreenScaleFactor
    }
	iRect := nL "|" nT "|" nW "|" nH
    p := Gdip_BitmapFromScreen(iRect)
    FormatTime, oNow, , yy_MM_dd-HH_mm_ss
    _fileName := _destinationFolder "\" oNow ".png"
	Gdip_SaveBitmapToFile(p, _fileName, 100)
	Gdip_DisposeImage(p)

Return
;-------- end of the implementation from feature 1--------------------------------------------------------

/* Don't use this
^p::
Send !{PrintScreen}
;FileAppend, %ClipboardAll%, C:\tmp\Logo.clip ;
;CopyImage("test.jpg")
FormatTime, oNow, , yy_MM_dd-HH_mm_ss
oDir := "C:\Users\A7HK2U8\Workspace\screentshots"
oPath := oDir "\" oNow ".png"
pToken := Gdip_Startup()
p := Gdip_CreateBitmapFromClipboard()
Gdip_SaveBitmapToFile(p, oPath, 100)
Gdip_DisposeImage(p)
Gdip_Shutdown(pToken)

CopyImage(ImageFile) {
	pToken := Gdip_Startup()
	Gdip_SetBitmapToClipboard(pBitmap := Gdip_CreateBitmapFromFile(ImageFile))
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
}
Return
*/

;2. Feature: Take screenshot from primary monitor
;Howto: press alt and button a, the screenshot from primary monitor will be taken and stored to _fileName specified location
;------------------start implementation----------------------
!a::
p := Gdip_BitmapFromScreen(_primaryScreenNumber)
FormatTime, oNow, , yy_MM_dd-HH_mm_ss
_fileName := _destinationFolder "\" oNow ".png"
Gdip_SaveBitmapToFile(p, _fileName, 100)
Gdip_DisposeImage(p)
return
;-----------------end of implementation---------------------

;3. Feature: Take screenshot from secondary monitor
;Howto: press alt and button b, the screenshot from secondary monitor will be taken and stored to _fileName specified location
;------------------start implementation----------------------
!b::
M := GetMonitorInfo(2)
_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
_x /= _primaryScreenScaleFactor
_x *= _secondScreenScaleFactor
_w /= _primaryScreenScaleFactor
_w *= _secondScreenScaleFactor
_h /= _primaryScreenScaleFactor
_h *= _secondScreenScaleFactor

iRect := _x "|" _y "|" _w "|" _h

p := Gdip_BitmapFromScreen(iRect)
FormatTime, oNow, , yy_MM_dd-HH_mm_ss
_fileName := _destinationFolder "\" oNow ".png"
Gdip_SaveBitmapToFile(p, _fileName, 100)
Gdip_DisposeImage(p)
return

ExitFunc(ExitReason, ExitCode)
{
   global
   ; gdi+ may now be shutdown on exiting the program
   Gdip_Shutdown(pToken)
}

CreateFolderFunc()
{
FileSelectFolder, _folder, , 3, "Please select folder for screenshots. If no folder selected the script will exist"
    if _folder =
    {
        MsgBox, "You didn't select a folder the script will exit"
        ExitApp
    }
    return _folder
}