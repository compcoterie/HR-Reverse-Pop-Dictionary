#NoEnv  ; Recommended for performance and compatibility for future releases.
; #Warn  ; Common error detector.
SendMode Input  ; Increase speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Consistent starting directory.

DebugMsg := false ;for testing purposes,
ClickToHideTip := false true makes it so every time you left click it will hide any tooltips
TipDisplayTime := 5000 ;how long to show the tooltip in milliseconds.
Path := "C:\Users\lohan\Desktop\empid.csv" ;the full path to the definition file

IfNotExist, %Path%
{
	msgbox No definition file found. Make sure the path in the script is correct.
	ExitApp
}

Definitions := {} ;initialize the array
FileLoop:
Loop, read, % Path ;loop through the csv file 1 line at a time
{
	acronym =  ;reset the variables every line
	definition = 
    Loop, parse, A_LoopReadLine, CSV ;parse each line of the file to get the individual cells
    {
		if (A_Index = 1) ;if index is 1 this is the acronym, if its blank skip this line, if not save the acronym to a variable
			If (A_Loopfield = "")
				continue FileLoop
			else
				acronym := A_LoopField
		else	;if it's not the first index then this is one of the definitions
			definition .= A_LoopField . "`n"
    }
	Definitions[acronym] := definition ;save the acronym and definition into the Definitions array
}
traytip,,Definitions loaded. The script is ready.
If DebugMsg
	For key, value in Definitions
		MsgBox %key% = %value%

~LButton::
	if ClickToHideTip && TipDisplayed ;if a tip is displayed and ClickToHideTip is enabled, hide the tip
	{
		tooltip
		TipDisplayed := false
	}
	if (A_PriorHotkey <> "~LButton" or A_TimeSincePriorHotkey > 400)
	{
		MouseGetPos, mousedrag_x, mousedrag_y
		keywait lbutton
		mousegetpos, mousedrag_x2, mousedrag_y2
		if (abs(mousedrag_x2 - mousedrag_x) > 10 or abs(mousedrag_y2 - mousedrag_y) > 10)
			AcronymCheck("ClickDrag") ;click and drag
		return
	}
	AcronymCheck("DoubleClick") ;double click
return

AcronymCheck(trigger)
{
	global
	ClipBackup := ClipboardAll ;save the current clipboard to recall later
	Clipboard =   ;set the clipboard to a blank variable
	mousegetpos,xpos,ypos
	ypos += 10
	if (trigger = "DoubleClick")
		sleep 200 ;wait a little bit on a double click or the control c won't register the text
	sendinput ^c  ;copy whatever text is highlighted into the clipboard
	Clipwait,1 ;wait up to 1 second for the text to be copied to the clipboard
	if (errorlevel = 0 and clipboard <> "") ;If the clipwait didn't timeout and the clipboard is not empty(meaning something was copied)
	{
		for acronym,definition in Definitions  ;loop through the Definitions array 1 key at a time
			if clipboard = %acronym%  ;compare the highlighted text to the acronyms in the array, if a match is found
			{
				tooltip, %clipboard% - %definition%, %xpos%, %ypos% ;show a tooltip to display the definition
				TipDisplayed := true
				if (TipDisplayTime) ;if TipDisplayTime is not blank or 0
					SetTimer, RemoveToolTip,%TipDisplayTime% ;set a timer to remove the tooltip after x seconds
			}
	}
	Clipboard := ClipBackup ;reset the clipboard to what it was before this script executed
	ClipBackup = ;set this blank to free up memory in case the clipboard was very large	
}

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
	TipDisplayed := false
return