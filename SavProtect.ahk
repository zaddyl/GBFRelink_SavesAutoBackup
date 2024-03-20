#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
DetectHiddenWindows, On
uac()

Gui Font, s9, Segoe UI
Gui Add, text, x10 y12 cwhite, 遊戲狀態：
Gui Add, text, x10 y32 cwhite, 存檔狀態：
Gui Add, checkbox, x28 y52 cwhite gStartup vbootset, 開機時啟動
lkpath = %A_appdata%\Microsoft\Windows\Start Menu\Programs\Startup\savprotect.lnk
if(fileexist(lkpath)){
	Guicontrol,, bootset, 1
}
Gui Show, w152 h229, GBFR存檔保護
gui, add, text, x28 y103 cwhite, ↓雙擊存檔還原↓
gui, add, text, x12 y205 cwhite, [YYYYMMDDHHMMSS]
Gui color, black
Gui Add, text, x85 y12 vRun cGreen, 運行中
guicontrol, hide, Run
Gui Add, text, x85 y12 vStop cRed, 未運行
guicontrol, hide, Stop
Gui Add, text, x75 y32 vGet cRed, 等待備份
guicontrol, hide, Get
Gui Add, text, x85 y32 vMiss cGray, 未找到
guicontrol, hide, Miss
Gui Add, text, x85 y32 vDone cGreen, 已備份
guicontrol, hide, Done
gui add, button, x75 y73 h23 cwhite gsavestat, 手動備份
iniread, bakhk, %A_ScriptDir%\Settings.ini, main, bakupHK, f11
gui add, hotkey, x10 y73 w60 vbakhk ghkswitch, %bakhk%
gui, add, listbox, x10 y122 w130 h80 center vsvls gsaverestore
gui, -0x20000
getbak()
goto start
Return

saverestore:
gui,Submit
msgbox, 4,,確認還原存檔%svls%?
ifmsgbox,Yes
{
	fileremovedir, C:\Users\%A_UserName%\Appdata\Local\GBFR\Saved,1
     filecopydir, %A_ScriptDir%\Bak\SaveGames_%svls%, C:\Users\%A_UserName%\Appdata\Local\GBFR\Saved\SaveGames
	return
}
ifmsgbox,no
{
	return
}

getbak(){
	i=0
	loop,files, %A_ScriptDir%\Bak\*, D
	{
		guicontrol,,svls,%A_loopfiletimecreated%
		i++
	}
	return
}

start:
gosub savestat
winget, winstat, pid, ahk_exe granblue_fantasy_relink.exe
if(winstat){
	guicontrol, hide, Stop
	guicontrol, show, Run
	guicontrol, hide, miss
	guicontrol, hide, done
	guicontrol, show, get
	WinWaitClose, ahk_exe granblue_fantasy_relink.exe
}else{
	guicontrol, hide, Run
	guicontrol, show, Stop
	winwait, ahk_exe granblue_fantasy_relink.exe
}
goto start
return

Savestat:
SavPath1 = C:\Users\%A_UserName%\AppData\Local\GBFR\Saved\SaveGames\SaveData1.dat
SavPath2 = C:\Users\%A_UserName%\AppData\Local\GBFR\Saved\SaveGames\SaveData2.dat
SavPath3 = C:\Users\%A_UserName%\AppData\Local\GBFR\Saved\SaveGames\SaveData3.dat
if (fileexist(SavPath1) or fileexist(SavPath2)  or fileexist(SavPath3)){
	savebak()
	guicontrol, hide, miss
	guicontrol, hide, get
	guicontrol, show, done
	gosub mention
} else {
	guicontrol, hide, get
	guicontrol, hide, done
	guicontrol, show, miss
}
return

startup:
guicontrolget, bs,, bootset
if(bs){
	filecreateshortcut, %A_ScriptDir%\SavProtect.exe, %A_appdata%\Microsoft\Windows\Start Menu\Programs\Startup\savprotect.lnk, %A_ScriptDir%,
	if(errorlevel=1){
		msgbox, 創建失敗，請檢查是否被殺軟攔截，或是權限不足
	}
}else{
	filedelete, %A_APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\savprotect.lnk
	if(errorlevel=1){
		msgbox, 刪除失敗
	}
}
return

savebak(){
	filecopydir, C:\Users\%A_UserName%\Appdata\Local\GBFR\Saved\SaveGames, %A_ScriptDir%\Bak\SaveGames_%A_NOW%
	guicontrol, hide, miss
	guicontrol, hide, get
	guicontrol, show, done
	i=0
	loop, Files, %A_ScriptDir%\Bak\*, D
	{
		if(i=0){
			dirt:=A_loopfiletimecreated, dir:=A_loopfilepath
		}
		if (A_loopfiletimecreated<dirt){
			dirt:=A_loopfiletimecreated, dir:=A_loopfilepath
		}
		if(i>3){
			fileremovedir, %dir%, 1
			break
		}
		i++	
	}
	return
}

mention:
l=0
while(l<4){
	gui, font, cred
	guicontrol, Font, done
	sleep 100
	gui, font, cgreen
	guicontrol, Font, done
	sleep 100
	l++
}
return

hkswitch:
hotkey, %bakhk%, savestat
iniwrite, %bakhk%, %A_ScriptDir%\Settings.ini, main, bakupHK
return

uac(){
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		ExitApp
	}
}

guiescape:
GuiClose:
ExitApp
return

