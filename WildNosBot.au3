#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=NosTale.ico
#AutoIt3Wrapper_Outfile=bin\WildNosBot.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Wild Nostale Bot
#AutoIt3Wrapper_Res_Fileversion=1.0.1.107
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=2016 (c) WildGenie.net
#AutoIt3Wrapper_Res_Language=1055
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_AU3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/sf
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rsln
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** Start added by AutoIt3Wrapper ***
#include <FileConstants.au3>
#include <APIProcConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <SliderConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIvkeysConstants.au3>
; *** End added by AutoIt3Wrapper ***

Opt("MustDeclareVars", 1)
Opt("GUICloseOnESC", 0)

#Region    ;************ Includes ************
#include <File.au3>
#include <WinAPIProc.au3>
#include <Process.au3>
#include "NomadMemory.au3"
#include "PostMessage.au3"
#EndRegion    ;************ Includes ************

Opt("WinTitleMatchMode", 2)
SetPrivilege("SeDebugPrivilege", 1)

#Region
#EndRegion

Global $fstart = False
Global $fstate = "Yüklendi"
Global $fselect = False

Global $fpaused
Global $lnostaleclientlist
Global $lnostaleclienthwn
Global $scharname = ""

Global $hProc, $hProcInfo, $hProcPid

Global $sClientLang = "TUR_tur"
Global $sPathDir = @ProgramFilesDir & "\GameforgeLive\Games\" & $sClientLang & "\NosTale\"

Global $sClientExe = "NostaleX.dat"
Global $sFClientPath = $sPathDir & $sClientExe

Global $lnostaleclient = WinList("[Class:TNosTaleMainF]")

If Not $lnostaleclient[0][0] Then
	_runclient()
	$lnostaleclient = WinList("[Class:TNosTaleMainF]")
	If Not $lnostaleclient[0][0] Then Exit MsgBox(16, "Hata", "NosTale bulunamadı.")
EndIf

$lnostaleclienthwn = WinGetProcess($lnostaleclient[1][1])
Global $ihpid = ProcessExists($lnostaleclienthwn)

If ($ihpid = @error) Then Exit MsgBox(16, "Hata", "NosTale bulunamadı.")

Global $sFClientPathNew = _WinAPI_GetProcessFileName($lnostaleclienthwn)

If @error = 0 And $sFClientPathNew <> "" Then
	Global $sDriveTemp = "", $sDirTemp = "", $sFileNameTemp = "", $sExtensionTemp = ""

	$sFClientPath = $sFClientPathNew
	$sClientExe = _ProcessGetName($lnostaleclienthwn)
	_PathSplit($sFClientPathNew, $sDriveTemp, $sDirTemp, $sFileNameTemp, $sExtensionTemp)
	$sPathDir = $sDriveTemp & $sDirTemp
EndIf


Global $ahmemomopen = _memoryopen($ihpid)

Global $iplayerinfoadress_pattern = "\xA1\x00\x00\x00\x00\x8B\x00\x8B\x80\xAC\x00\x00\x00\x8B\x40\x48"
Global $iplayerinfoadress_mask = "x????xxxxxxxxxxx"
Global $iplayerinfoadress_offset = 0x01

Global $imulticlientadress_pattern = "\x0F\x84\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x85\xC0\x0F\x85\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x48\x0F\x8C\x00\x00\x00\x00\x8D\x45\xEC\x50\x8D\x55\xE8\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8B\x45\xE8\xB9\x00\x00\x00\x00\xBA\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8B\x45\xEC\xBA\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x75\x63"
Global $imulticlientadress_mask = "xx????x????xxxx????x????xxx????xxxxxxxx????x????xxxx????x????x????xxxx????x????xx"
Global $amulticlientadress_offsets[4] = [0x02, 0x0f, 0x1b, 0x50]

Global $iattacktypeadress_pattern = "\xE8\x00\x00\x00\x00\x8B\xC3\xE8\x00\x00\x00\x00\xB2\x01\xA1\x00\x00\x00\x00\xE8\x00\x00\x00\x00\xA3\x00\x00\x00\x00\xB2\x01\xA1\x00\x00\x00\x00\xE8\x00\x00\x00\x00"
Global $iattacktypeadress_mask = "x????xxx????xxx????x????x????xxx????x????"
Global $iattacktypeadress_offset = 0x19

Global $iplayerinfo2adress_pattern = "\xA3\x00\x00\x00\x00\xA1\x00\x00\x00\x00\x8B\x15\x00\x00\x00\x00\x89\x90\x00\x00\x00\x00\x66\xBA\xC7\x01\xA1\x00\x00\x00\x00\xE8\x00\x00\x00\x00"
Global $iplayerinfo2adress_mask = "x????x????xx????xx????xxxxx????x????"
Global $iplayerinfo2adress_offset = 0x1

Global $iplayerinfo3adress_pattern = "\x8B\x40\x08\x8B\x15\x00\x00\x00\x00\x8B\x12\x8B\x52\x20\x3B\x42\x08"
Global $iplayerinfo3adress_mask = "xxxxx????xxxxxxxx"
Global $iplayerinfo3adress_offset = 0x4

Global $imacrobaradress_pattern = "\xA1\x00\x00\x00\x00\x8B\x00\x8B\x80\xB4\x00\x00\x00\xE8\x00\x00\x00\x00\x33\xC0"
Global $imacrobaradress_mask = "x????xxxxxxxxx????xx"
Global $imacrobaradress_offset = 0x01

Global $iselectbaradress_pattern = "\x83\xE0\x7F\x8B\x15\x00\x00\x00\x00\x8B\x12\x89\x42\x60\xA1\x00\x00\x00\x00\x8B\x00"
Global $iselectbaradress_mask = "xxxxx????xxxxxx????xx"
Global $iselectbaradress_offset = 0x05

Global $inostmatebaradress_pattern = "\xB2\x01\xA1\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8B\xD3\xA1\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8B\xD3\xA1\x00\x00\x00\x00\xE8\x00\x00\x00\x00"
Global $inostmatebaradress_mask = "xxx????x????xxx????x????xxx????x????"
Global $inostmatebaradress_offset = 0x0F

Global $ichatbaradress_pattern = "\x40\x75\x0E\xA1\x00\x00\x00\x00\x8B\x00\x8B\xD3\xE8\x00\x00\x00\x00"
Global $ichatbaradress_mask = "xxxx????xxxxx????"
Global $ichatbaradress_offset = 0x04

Global $iplayernameadress_pattern = "\xE8\x00\x00\x00\x00\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\xB8\x00\x00\x00\x00\xB9\x00\x00\x00\x00\x8B\x15\x00\x00\x00\x00\xE8\x00\x00\x00\x00\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x33\xC0"
Global $iplayernameadress_mask = "x????x????x????x????x????x????x????x????x????xx????x????x????x????x????x????xx"
Global $iplayernameadress_offset = 0x10

Global $iplayerinfoadress = $iplayerinfoadress_offset + _memoryscanex($ahmemomopen, $iplayerinfoadress_pattern, $iplayerinfoadress_mask)
Global $iselectbaradress = $iselectbaradress_offset + _memoryscanex($ahmemomopen, $iselectbaradress_pattern, $iselectbaradress_mask)
Global $iattacktypeadress = $iattacktypeadress_offset + _memoryscanex($ahmemomopen, $iattacktypeadress_pattern, $iattacktypeadress_mask)
Global $imacrobaradress = $imacrobaradress_offset + _memoryscanex($ahmemomopen, $imacrobaradress_pattern, $imacrobaradress_mask)
Global $inostmatebaradress = $inostmatebaradress_offset + _memoryscanex($ahmemomopen, $inostmatebaradress_pattern, $inostmatebaradress_mask)
Global $iplayerinfo2adress = $iplayerinfo2adress_offset + _memoryscanex($ahmemomopen, $iplayerinfo2adress_pattern, $iplayerinfo2adress_mask)
Global $iplayerinfo3adress = $iplayerinfo3adress_offset + _memoryscanex($ahmemomopen, $iplayerinfo3adress_pattern, $iplayerinfo3adress_mask)
Global $ichatbaradress = $ichatbaradress_offset + _memoryscanex($ahmemomopen, $ichatbaradress_pattern, $ichatbaradress_mask)
Global $iplayernameadress = $iplayernameadress_offset + _memoryscanex($ahmemomopen, $iplayernameadress_pattern, $iplayernameadress_mask)

Global $ihpaddress = $iplayerinfoadress
Global $ahpoffset = _getoffset("0,0,ac,4c")
Global $impaddress = $iplayerinfoadress
Global $ampoffset = _getoffset("0,0,b0,4c")
Global $ileveladdress = $iplayerinfo2adress
Global $aleveloffset = _getoffset("0,1d4")
Global $aexpoffset = _getoffset("568,88")
Global $igoldaddress = $iplayerinfo2adress
Global $agoldoffset = _getoffset("0,1dc")
Global $imaxhpaddress = $iplayerinfoadress
Global $amaxhpoffset = _getoffset("0,0,ac,48")
Global $imaxmpaddress = $iplayerinfoadress
Global $amaxmpoffset = _getoffset("0,0,b0,48")
Global $iselectaddress = $iselectbaradress
Global $aselectoffset = _getoffset("0,0,60")
Global $iselecthpaddress = $iselectbaradress
Global $aselecthpoffset = _getoffset("0,0,20,4,C,4C")
Global $isitaddress = $iplayerinfo3adress
Global $asitoffset = _getoffset("0,0,81")

Global $inm1hpaddress = $inostmatebaradress
Global $anm1hpoffset = _getoffset("0,b4,0,b0,4C")
Global $inm2hpaddress = $inostmatebaradress
Global $anm2hpoffset = _getoffset("0,b4,4,b0,4C")

Global $inameaddress = $iplayernameadress
Global $anameoffset = _getoffset("0,0")

Global $imacrobarenableaddress = $imacrobaradress
Global $amacrobarenableoffset[16]
$amacrobarenableoffset[0] = 15
For $i = 1 To 15
	$amacrobarenableoffset[$i] = _getoffset("0,0,b4," & Hex(0x68 + (($i - 1) * 4), 2) & ",41")
Next
$iattacktypeadress = $iattacktypeadress
Global $aattacktypeoffset = _getoffset("0,14")

Global $ichatpaneladress = $ichatbaradress
Global $achatpaneloffset = _getoffset("0,0,cc")

;Global Const $nodelay = "\x8B\x45\xF0\x83\xCA\xFF\xE8\x00\x00\x00\x00\x89\x45\xFC\x8D\x4D\xEC\xBA\x00\x00\x00\x00\x8B\xC6"
;Global Const $nodelay_mask = "xxxxxxx????xxxxxxx????xx"
;Global Const $nodelay2 = "\xBA\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8D\x43\x20\x8B\xD6\xE8\x00\x00\x00\x00"
;Global Const $nodelay2_mask = "x????x????xxxxxx????"

Global Const $mob = "\x80\xBB\xCE\x00\x00\x00\x00"
Global Const $mob_mask = "xxx????"
Global Const $item = "\x80\xBB\xCF\x00\x00\x00\x00"
Global Const $item_mask = "xxx????"
Global Const $npc1 = "\x80\xBB\xC8\x00\x00\x00\x00\x0F\x84\x00\x00\x00\x00\x8B\x15\x00\x00\x00\x00\xA1\x00\x00\x00\x00\x8B\x00\xE8\x00\x00\x00\x00"
Global Const $npc1_mask = "xxxxxxxxx????xx????x????xxx????"
Global Const $npc2 = "\x80\xBB\xCD\x00\x00\x00\x00\x0F\x84\x00\x00\x00\x00\x8B\x15\x00\x00\x00\x00\xA1\x00\x00\x00\x00"
Global Const $npc2_mask = "xxxxxxxxx????xx????x????"
Global Const $playeronmap = "\x80\xBB\xCC\x00\x00\x00\x00\x0F\x84\x00\x00\x00\x00\x68\x00\x00\x00\x00\x33\xC9\xB2\xFF\xB0\xFF\xE8\x00\x00\x00\x00\xA1\x00\x00\x00\x00"
Global Const $playeronmap_mask = "xxxxxxxxx????x????xxxxxxx????x????"
Global Const $zoom = "\x75\x0E\xD9\x43\x5C\xD8\x1D\x00\x00\x00\x00\xDF\xE0\x9E\x74\x2E\xD9\x05\x00\x00\x00\x00\xD8\x5B\x58\xDF\xE0\x9E\x73\x0A"
Global Const $zoom_mask = "xxxxxxx????xxxxxxx????xxxxxxxx"

Global Const $ts = "\x80\xBB\xCA\x00\x00\x00\x00\x0F\x84\x00\x00\x00\x00\xA1\x00\x00\x00\x00\xDF\x40\x04\xD8\x35\x00\x00\x00\x00"
Global Const $ts_mask = "xxxxxxxxx????x????xxxxx????"
Global Const $portal = "\x80\xBB\xC9\x00\x00\x00\x00\x0F\x84\x00\x00\x00\x00\xA1\x00\x00\x00\x00\xDF\x40\x04"
Global Const $portal_mask = "xxxxxxxxx????x????xxx"
Global Const $0pt = "\x8B\x00\x99\x52\x50\xA1\x00\x00\x00\x00\x8B\x00\x33\xD2\x33\x04\x24\x33\x54\x24\x04\x83\xC4\x08\x52\x50\x8D\x45\xF0\xE8\x00\x00\x00\x00\xFF\x75\xF0\x68\x00\x00\x00\x00"
Global Const $0pt_mask = "xxxxxx????xxxxxxxxxxxxxxxxxxxx????xxxx????"
Global Const $akt4nameadress = "\x0F\x8E\x00\x00\x00\x00\x66\xFF\xCE\x74\x11"
Global Const $akt4nameadress_mask = "xx????xxxxx"
Global Const $showlvladress = "\x76\x20\x80\xC3\xFD\x80\xEB\x02\x73\x18\x8B\x86\x00\x00\x00\x00\x05\x00\x00\x00\x00\x8B\x15\x00\x00\x00\x00\x8B\x12\xE8\x00\x00\x00\x00"
Global Const $showlvladress_mask = "xxxxxxxxxxxx????x????xx????xxx????"
Global Const $akt4infoadress1 = "\x75\x1E\x6A\x01\xA1\x00\x00\x00\x00\x8B\x00"
Global Const $akt4infoadress1_mask = "xxxxx????xx"
Global Const $akt4infoadress2 = "\x75\x33\x8B\x43\x08\x33\xD2\x52"
Global Const $akt4infoadress2_mask = "xxxxxxxx"
Global Const $ghostwalkadress1 = "\xE8\x00\x00\x00\x00\xD9\x86\x00\x00\x00\x00\xA1\x00\x00\x00\x00\xD8\x18\xDF\xE0\x9E\x76\x32\xE8\x00\x00\x00\x00\x89\x45\xEC\x33\xC0\x89\x45\xF0\xDF\x6D\xEC\xD9\x86\x00\x00\x00\x00"
Global Const $ghostwalkadress1_mask = "x????xx????x????xxxxxxxx????xxxxxxxxxxxxx????"
Global Const $ghostwalkadress2 = "\x55\x8B\xEC\xB9\x00\x00\x00\x00\x6A\x00\x6A\x00\x49\x75\xF9\x53\x56\x57\x8B\xF2\x33\xC0\x55\x68\x00\x00\x00\x00\x64\xFF\x30"
Global Const $ghostwalkadress2_mask = "xxxx????xxxxxxxxxxxxxxxx????xxx"
Global Const $life = "\x03\xC3\x2B\xC1\x99\x52\x50\xA1\x00\x00\x00\x00\x8B\x00\x33\xD2"
Global Const $life_mask = "xxxxxxxx????xxxx"
Global Const $bad = "\x83\xC2\x0A\x8B\x45\xFC\xE8\x00\x00\x00\x00\x8B\x45\xFC\xFF\x80\x00\x00\x00\x00\x8B\x45\xFC\x05\x00\x00\x00\x00\xBA\x00\x00\x00\x00"
Global Const $bad_mask = "xxxxxxx????xxxxx????xxxx????x????"
Global Const $good = "\x83\xC2\x1E\x8B\x45\xFC\xE8\x00\x00\x00\x00\x8B\x45\xFC\xFF\x80\x00\x00\x00\x00\x8B\x45\xFC\x05\x00\x00\x00\x00\xBA\x00\x00\x00\x00"
Global Const $good_mask = "xxxxxxx????xxxxx????xxxx????x????"
Global Const $nice = "\x83\xC2\x3C\x8B\x45\xFC\xE8\x00\x00\x00\x00\x8B\x45\xFC\xFF\x80\x00\x00\x00\x00\x8B\x45\xFC\xFF\x80\x00\x00\x00\x00\x8B\x45\xFC\x05\x00\x00\x00\x00\xBA\x00\x00\x00\x00"
Global Const $nice_mask = "xxxxxxx????xxxxx????xxxxx????xxxx????x????"
Global Const $taglia1 = "\x83\xC2\x3C\x8B\x45\xFC\xE8\x00\x00\x00\x00\x8B\x45\xFC\xFF\x80\x00\x00\x00\x00\x8B\x45\xFC"
Global Const $taglia1_mask = "xxxxxxx????xxxxx????xxx"
Global Const $taglia2 = "\x83\xC2\x1E\x8B\x45\xFC\xE8\x00\x00\x00\x00\x8B\x45\xFC"
Global Const $taglia2_mask = "xxxxxxx????xxx"
Global Const $taglia3 = "\x83\xC2\x0A\x8B\x45\xFC\xE8\x00\x00\x00\x00"
Global Const $taglia3_mask = "xxxxxxx????"
Global Const $cava = "\xB8\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8B\xD0\x03\x96\x00\x00\x00\x00\x83\xC2\x32"
Global Const $cava_mask = "x????x????xxxx????xxx"
Global Const $pesci1 = "\xE8\x00\x00\x00\x00\xEB\x42\x33\xD2\x8A\x90\x5C\x17\x00\x00\x6B\xD2\x32\x03\x90\x00\x00\x00\x00"
Global Const $pesci1_mask = "x????xxxxxxxxxxxxxxx????"
Global Const $spara1 = "\x83\xC2\x0A\x8B\xC3\xE8\x00\x00\x00\x00\xE9\x00\x00\x00\x00\x8B\x93\x00\x00\x00\x00\x83\xC2\x14"
Global Const $spara1_mask = "xxxxxx????x????xx????xxx"

;~ Global Const $eagleeye1_pattern = "\x7E\x70\x8B\xC6\x80\x88\x59\x09\x00\x00\x02\x8B\x80\x00\x00\x00\x00\x8B\x58\x08\x4B\x83\xFB\x00"
;~ Global Const $eagleeye1_mask = "xxxxxxxxxxxxx????xxxxxxx"
;~ Global Const $eagleeye2_pattern = "\xFF\x56\x00\x8B\x85\x00\x00\x00\x00\x33\xD2\xE8\x00\x00\x00\x00\x85\xC0\x7E\x61\xCC\x8B\x59\x09\x00\x00\x02\x8B\x83\xB0\x00\x00\x00\x8B\x70\x08\x4E\x83\xFE\x00"
;~ Global Const $eagleeye2_mask = "xx?xx????xxx????xxxxxxxxxxxxxxxxxxxxxxxx"
;~ Global Const $eagleeye2_offset = 0x12

;~ Global $nodelay2a = _memoryscanex($ahmemomopen, $nodelay2, $nodelay2_mask)

Global $taglia1a = _memoryscanex($ahmemomopen, $taglia1, $taglia1_mask)
Global $taglia2a = _memoryscanex($ahmemomopen, $taglia2, $taglia2_mask)
Global $taglia3a = _memoryscanex($ahmemomopen, $taglia3, $taglia3_mask)
Global $cavaa = _memoryscanex($ahmemomopen, $cava, $cava_mask)
Global $pesci1a = _memoryscanex($ahmemomopen, $pesci1, $pesci1_mask)
Global $spara1a = _memoryscanex($ahmemomopen, $spara1, $spara1_mask)
Global $zooma = _memoryscanex($ahmemomopen, $zoom, $zoom_mask)

Global $moba = _memoryscanex($ahmemomopen, $mob, $mob_mask)
Global $itema = _memoryscanex($ahmemomopen, $item, $item_mask)
Global $npc1a = _memoryscanex($ahmemomopen, $npc1, $npc1_mask)
Global $npc2a = _memoryscanex($ahmemomopen, $npc2, $npc2_mask)
Global $player = _memoryscanex($ahmemomopen, $playeronmap, $playeronmap_mask)
Global $tsa = _memoryscanex($ahmemomopen, $ts, $ts_mask)
Global $portala = _memoryscanex($ahmemomopen, $portal, $portal_mask)
Global $0pta = _memoryscanex($ahmemomopen, $0pt, $0pt_mask)
Global $akt4nameadressa = _memoryscanex($ahmemomopen, $akt4nameadress, $akt4nameadress_mask)
Global $showlvladressa = _memoryscanex($ahmemomopen, $showlvladress, $showlvladress_mask)
Global $akt4infoadress1a = _memoryscanex($ahmemomopen, $akt4infoadress1, $akt4infoadress1_mask)
Global $akt4infoadress2a = _memoryscanex($ahmemomopen, $akt4infoadress2, $akt4infoadress2_mask)
Global $ghostwalkadress1a = _memoryscanex($ahmemomopen, $ghostwalkadress1, $ghostwalkadress1_mask)
Global $ghostwalkadress2a = _memoryscanex($ahmemomopen, $ghostwalkadress2, $ghostwalkadress2_mask)
Global $lifeaddress = _memoryscanex($ahmemomopen, $life, $life_mask)

;~ Global $eagleeye1 = _memoryscanex($ahmemomopen, $eagleeye1_pattern, $eagleeye1_mask)
;~ Global $eagleeye2 = _memoryscanex($ahmemomopen, $eagleeye2_pattern, $eagleeye2_mask)

Global Const $nodelay_pattern = "\x8B\x45\xF0\x83\xCA\xFF\xE8\x00\x00\x00\x00\x89\x45\xFC\x8D\x4D\xEC\xBA\x00\x00\x00\x00\x8B\xC6\x8B\x18\xFF\x53\x00"
Global Const $nodelay_mask = "xxxxxxx????xxxxxxx????xxxxxx?"
Global Const $nodelay_offset = 0x00

Global $nodelay_p_adress = $nodelay_offset + _memoryscanex($ahmemomopen, $nodelay_pattern, $nodelay_mask)
Global $nodelay_n_adress = $nodelay_offset + _memoryscanex($ahmemomopen, $nodelay_pattern, $nodelay_mask, False, $nodelay_p_adress + 100)

;Global Const $nodelay2 = "\xBA\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8D\x43\x20\x8B\xD6\xE8\x00\x00\x00\x00"
;Global Const $nodelay2_mask = "x????x????xxxxxx????"

Global Const $speed_pattern = "\x33\xC0\x8A\x83\x96\x00\x00\x00\x8B\x04\x85\x00\x00\x00\x00\x89\x04\x24"
Global Const $speed_mask = "xxxx?xxxxxx????xxx"
Global Const $speed_offset = 0x02
Global $speeda = $speed_offset + _memoryscanex($ahmemomopen, $speed_pattern, $speed_mask)

Global Const $sleep_pattern = "\x6A\xFF\xA1\x00\x00\x00\x00\x8B\x00\x2B\xC3\x50\xE8\x00\x00\x00\x00"
Global Const $sleep_mask = "xxx????xxxxxx????"
Global Const $sleep_a_offset = 0x03
Global $sleep_adress = $sleep_a_offset + _memoryscanex($ahmemomopen, $sleep_pattern, $sleep_mask)
Global $sleep_offset = _getoffset("0,0")

Global Const $petbag_pattern = "\x8B\x45\xF4\x33\xD2\xE8\x00\x00\x00\x00\x8B\xD0\xA1\x00\x00\x00\x00\x8B\x00\xE8\x00\x00\x00\x00\x8B\x45\xFC\x8B\x10" ;\x8D\x4D\xF4\x33\xD2\x8B\x45\xFC\x8B\x18\xFF\x53\x00\x8B\x45\xF4\x33\xD2\xE8\x00\x00\x00\x00"
Global Const $petbag_mask = "xxxxxx????xxx????xxx????xxxxx";xxxxxxxxxxxx?xxxxxx????"
Global Const $petbag_a_offset = 0x0a
Global $petbag_a_address[3]
$petbag_a_address[0] = $petbag_a_offset + _memoryscanex($ahmemomopen, $petbag_pattern, $petbag_mask)
$petbag_a_address[1] = $petbag_a_offset + _memoryscanex($ahmemomopen, $petbag_pattern, $petbag_mask, False, $petbag_a_address[0] + 25)
$petbag_a_address[2] = $petbag_a_offset + _memoryscanex($ahmemomopen, $petbag_pattern, $petbag_mask, False, $petbag_a_address[1] + 25)
Global $petbag_address = $petbag_a_address[1]

Global Const $eagleeye_pattern = "\x55\x8B\xEC\x6A\x00\x6A\x00\x6A\x00\x53\x56\x57\x8B\xDA\x33\xC0\x55\x68\x00\x00\x00\x00"
Global Const $eagleeye_mask = "xxxxxxxxxxxxxxxxxx????"
Global Const $eagleeye_a_offset = 0x00
Global $eagleeye_a_address[2]
$eagleeye_a_address[0] = $eagleeye_a_offset + _memoryscanex($ahmemomopen, $eagleeye_pattern, $eagleeye_mask)
$eagleeye_a_address[1] = $eagleeye_a_offset + _memoryscanex($ahmemomopen, $eagleeye_pattern, $eagleeye_mask, False, $eagleeye_a_address[0] + 25)
Global $eagleeye_address = $eagleeye_a_address[1]

Global $awhp = _pointer("MAXHP") * .4
Global $awmp = _pointer("MAXMP") * .3
Global $awfhp = _pointer("MAXHP") * .7
Global $awfmp = _pointer("MAXMP") * .7

$scharname = _pointer("NAME")

#Region ### START Koda GUI section ### Form=WildNosBot.kxf
Global $hgui = GUICreate("WildNosBot", 596, 413, 197, 120)
Global $Tab1 = GUICtrlCreateTab(0, 0, 585, 401, BitOR($TCS_VERTICAL, $TCS_MULTILINE, $TCS_FOCUSONBUTTONDOWN))
Global $TabSheet1 = GUICtrlCreateTabItem("Bot")
GUICtrlCreateGroup("Bot Ayarları", 50, 14, 333, 238)
Global $obuttonstart = GUICtrlCreateButton("Başlat", 218, 30, 75, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonpause = GUICtrlCreateButton("Durdur", 298, 30, 75, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $ointputcharname = GUICtrlCreateInput("", 58, 30, 153, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
GUIStartGroup()
Global $oradioattacktype_1 = GUICtrlCreateRadio("Birincil Saldırı", 58, 190, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $oradioattacktype_2 = GUICtrlCreateRadio("İkincil Saldırı", 162, 190, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradioattacktype_0 = GUICtrlCreateRadio("Saldırı Kapalı", 266, 190, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUIStartGroup()
GUIStartGroup()
Global $oradiolooton = GUICtrlCreateRadio("Eşyalar Yerden Toplansın", 210, 222, 161, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiolootoff = GUICtrlCreateRadio("Eşyalar Toplanmasın", 58, 222, 153, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiofindmobon = GUICtrlCreateRadio("Standart Arama", 58, 158, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $oradiofindplayeron = GUICtrlCreateRadio("Oyuncu Arama", 162, 158, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiofindoff = GUICtrlCreateRadio("Arama Kapalı", 266, 158, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUIStartGroup()
GUIStartGroup()
Global $oradiofindmobfilterblack = GUICtrlCreateRadio("Kara Liste Kullan", 58, 126, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiofindmobfilterwhite = GUICtrlCreateRadio("Beyaz Liste Kullan", 162, 126, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiofindmobfilteroff = GUICtrlCreateRadio("Filitre Kullanma", 266, 126, 105, 25, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUICtrlCreateLabel("Hedef YP Beceri Kullanım Aralığı", 58, 54, 313, 17, BitOR($SS_CENTER, $WS_BORDER))
Global $olabel_skill_start = GUICtrlCreateLabel("30 %", 176, 86, 52, 21)
Global $oslider_skill_start = GUICtrlCreateSlider(80, 78, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 30)
Global $olabel_skill_until = GUICtrlCreateLabel("100 %", 320, 86, 52, 21)
Global $oslider_skill_until = GUICtrlCreateSlider(224, 78, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 100)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("HP/MP/EXP/Gold/LVL Checker", 49, 253, 333, 135)
GUICtrlCreateLabel("HP:", 57, 293, 30, 17, $SS_RIGHT)
GUICtrlCreateLabel("MP:", 57, 317, 31, 17, $SS_RIGHT)
GUICtrlCreateLabel("EXP:", 57, 365, 28, 17, $SS_RIGHT)
GUICtrlCreateLabel("Gold:", 57, 341, 29, 17)
Global $oprogressexp = GUICtrlCreateProgress(89, 365, 126, 17)
Global $oprogresshp = GUICtrlCreateProgress(89, 293, 126, 17)
Global $oprogressmp = GUICtrlCreateProgress(89, 317, 126, 17)
Global $olabelgold = GUICtrlCreateLabel("", 89, 341, 53, 17)
GUICtrlCreateLabel("Level:", 153, 341, 33, 17)
Global $olabellevel = GUICtrlCreateLabel("", 185, 341, 33, 17)
Global $oprogressnm1hp = GUICtrlCreateProgress(249, 293, 126, 17)
Global $oprogressnm2hp = GUICtrlCreateProgress(249, 317, 126, 17)
GUICtrlCreateLabel("NosMate/Yardımcı HP:", 225, 269, 126, 17)
GUICtrlCreateLabel("Ana Karakter", 57, 269, 126, 17)
GUICtrlCreateLabel("N", 225, 293, 22, 17)
GUICtrlCreateLabel("Y", 225, 317, 22, 17)
GUICtrlCreateLabel("Yaratık HP:", 225, 341, 126, 17)
Global $oprogressmobhp = GUICtrlCreateProgress(249, 365, 126, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group1 = GUICtrlCreateGroup("Kullanılacak Beceriler", 386, 14, 185, 374)
Global $olabelskill_1 = GUICtrlCreateLabel("1", 442, 30, 122, 17)
Global $olabelskill_2 = GUICtrlCreateLabel("2", 442, 54, 122, 17)
Global $olabelskill_3 = GUICtrlCreateLabel("3", 442, 78, 122, 17)
Global $olabelskill_4 = GUICtrlCreateLabel("4", 442, 102, 122, 17)
Global $olabelskill_5 = GUICtrlCreateLabel("5", 442, 126, 122, 17)
Global $olabelskill_q = GUICtrlCreateLabel("Q", 442, 150, 122, 17)
Global $olabelskill_w = GUICtrlCreateLabel("W", 442, 174, 122, 17)
Global $olabelskill_e = GUICtrlCreateLabel("E", 442, 198, 122, 17)
Global $olabelskill_r = GUICtrlCreateLabel("R", 442, 222, 122, 17)
Global $olabelskill_t = GUICtrlCreateLabel("T", 442, 246, 122, 17)
Global $olabelskill_6 = GUICtrlCreateLabel("6", 442, 270, 122, 17)
Global $olabelskill_7 = GUICtrlCreateLabel("7", 442, 294, 122, 17)
Global $olabelskill_8 = GUICtrlCreateLabel("8", 442, 318, 122, 17)
Global $ocheckboxskill_1 = GUICtrlCreateCheckbox("1", 394, 30, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetBkColor(-1, 0x00FFFF)
Global $ocheckboxskill_2 = GUICtrlCreateCheckbox("2", 394, 54, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_3 = GUICtrlCreateCheckbox("3", 394, 78, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_4 = GUICtrlCreateCheckbox("4", 394, 102, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_5 = GUICtrlCreateCheckbox("5", 394, 126, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_q = GUICtrlCreateCheckbox("Q", 394, 150, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_w = GUICtrlCreateCheckbox("W", 394, 174, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_e = GUICtrlCreateCheckbox("E", 394, 198, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_r = GUICtrlCreateCheckbox("R", 394, 222, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_t = GUICtrlCreateCheckbox("T", 394, 246, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_6 = GUICtrlCreateCheckbox("6", 394, 270, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_7 = GUICtrlCreateCheckbox("7", 394, 294, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_8 = GUICtrlCreateCheckbox("8", 394, 318, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_9 = GUICtrlCreateCheckbox("9", 394, 342, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $ocheckboxskill_0 = GUICtrlCreateCheckbox("0", 394, 366, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHTBUTTON, $BS_PUSHLIKE, $BS_FLAT))
Global $olabelskill_9 = GUICtrlCreateLabel("9", 442, 342, 122, 17)
Global $olabelskill_0 = GUICtrlCreateLabel("0", 442, 366, 122, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet2 = GUICtrlCreateTabItem("Hile")
Global $Group2 = GUICtrlCreateGroup("Mini Map Hack", 314, 6, 257, 385)
GUIStartGroup()
Global $oradiommobon = GUICtrlCreateRadio("Açık", 418, 30, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiommoboff = GUICtrlCreateRadio("Kapalı", 490, 30, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Label1 = GUICtrlCreateLabel("Yaratıklar", 322, 30, 92, 17, $SS_RIGHT)
Global $oradiommobdef = GUICtrlCreateRadio("Varsayılan", 418, 46, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiomitemon = GUICtrlCreateRadio("Açık", 418, 70, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomitemoff = GUICtrlCreateRadio("Kapalı", 490, 70, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Label2 = GUICtrlCreateLabel("Eşyalar", 322, 70, 92, 17, $SS_RIGHT)
Global $oradiomitemdef = GUICtrlCreateRadio("Varsayılan", 418, 86, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiomnpc1on = GUICtrlCreateRadio("Açık", 418, 110, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomnpc1off = GUICtrlCreateRadio("Kapalı", 490, 110, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Label3 = GUICtrlCreateLabel("NPC 1", 322, 110, 92, 17, $SS_RIGHT)
Global $oradiomnpc1def = GUICtrlCreateRadio("Varsayılan", 418, 126, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiomnpc2on = GUICtrlCreateRadio("Açık", 418, 150, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomnpc2off = GUICtrlCreateRadio("Kapalı", 490, 150, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Label4 = GUICtrlCreateLabel("NPC 2", 322, 150, 92, 17, $SS_RIGHT)
Global $oradiomnpc2def = GUICtrlCreateRadio("Varsayılan", 418, 166, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiomplayeron = GUICtrlCreateRadio("Açık", 418, 190, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomplayeroff = GUICtrlCreateRadio("Kapalı", 490, 190, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Label5 = GUICtrlCreateLabel("Oyuncular", 322, 190, 92, 17, $SS_RIGHT)
Global $oradiomplayerdef = GUICtrlCreateRadio("Varsayılan", 418, 206, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiomtson = GUICtrlCreateRadio("Açık", 418, 230, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomtsoff = GUICtrlCreateRadio("Kapalı", 490, 230, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Label6 = GUICtrlCreateLabel("Zaman Boşlukları", 322, 230, 92, 17, $SS_RIGHT)
Global $oradiomtsdef = GUICtrlCreateRadio("Varsayılan", 418, 246, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUIStartGroup()
Global $oradiomportalon = GUICtrlCreateRadio("Açık", 418, 270, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomportaloff = GUICtrlCreateRadio("Kapalı", 490, 270, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlCreateLabel("Geçişler", 322, 270, 92, 17, $SS_RIGHT)
Global $oradiomportaldef = GUICtrlCreateRadio("Varsayılan", 418, 286, 145, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUIStartGroup()
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group3 = GUICtrlCreateGroup("Walk Hack", 50, 142, 257, 121)
Global $osliderspeed = GUICtrlCreateSlider(67, 184, 186, 37)
GUICtrlSetLimit(-1, 40, 0)
GUICtrlSetData(-1, 10)
GUIStartGroup()
Global $oradiospeedon = GUICtrlCreateRadio("Açık", 154, 166, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiospeedoff = GUICtrlCreateRadio("Kapalı", 226, 166, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateLabel("Speed Hack", 58, 166, 90, 17, $SS_RIGHT)
GUIStartGroup()
Global $olabelspeed = GUICtrlCreateLabel("x 1.0", 258, 198, 36, 17)
GUIStartGroup()
Global $oradiospeedportwalkon = GUICtrlCreateRadio("Açık", 154, 230, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiospeedportwalkoff = GUICtrlCreateRadio("Kapalı", 226, 230, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateLabel("Port Walk", 58, 230, 92, 17, $SS_RIGHT)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
GUIStartGroup()
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group4 = GUICtrlCreateGroup("Akt4 Hack", 50, 270, 257, 121)
GUIStartGroup()
Global $oradioghostwalkon = GUICtrlCreateRadio("Açık", 154, 294, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradioghostwalkoff = GUICtrlCreateRadio("Kapalı", 226, 294, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label7 = GUICtrlCreateLabel("Hayalet Yürüme", 58, 294, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradioshownameon = GUICtrlCreateRadio("Açık", 154, 318, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradioshownameoff = GUICtrlCreateRadio("Kapalı", 226, 318, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label12 = GUICtrlCreateLabel("İsimleri Göster", 58, 318, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradioshowlvlon = GUICtrlCreateRadio("Açık", 154, 342, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradioshowlvloff = GUICtrlCreateRadio("Kapalı", 226, 342, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label13 = GUICtrlCreateLabel("Seviyeleri Göster", 58, 342, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradioshowinfoon = GUICtrlCreateRadio("Açık", 154, 366, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradioshowinfooff = GUICtrlCreateRadio("Kapalı", 226, 366, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label14 = GUICtrlCreateLabel("Bilgileri Göster", 58, 366, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group5 = GUICtrlCreateGroup("Genel Hack", 50, 6, 257, 129)
GUIStartGroup()
Global $oradionodelayon = GUICtrlCreateRadio("Açık", 154, 30, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradionodelayoff = GUICtrlCreateRadio("Kapalı", 226, 30, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label17 = GUICtrlCreateLabel("Bekleme Yok", 58, 30, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradiozoomhackon = GUICtrlCreateRadio("Açık", 154, 54, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiozoomhackoff = GUICtrlCreateRadio("Kapalı", 226, 54, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label18 = GUICtrlCreateLabel("Zoom Hack", 58, 54, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradioeagleeyeon = GUICtrlCreateRadio("Açık", 154, 78, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradioeagleeyeoff = GUICtrlCreateRadio("Kapalı", 226, 78, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label19 = GUICtrlCreateLabel("Görünmez Patch", 58, 78, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradiopartnerbagon = GUICtrlCreateRadio("Açık", 154, 102, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiopartnerbagoff = GUICtrlCreateRadio("Kapalı", 226, 102, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label15 = GUICtrlCreateLabel("Pet Çanta Hack", 58, 102, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet3 = GUICtrlCreateTabItem("Klient")
Global $Group6 = GUICtrlCreateGroup("Klient Ayarları", 50, 222, 521, 169)
Global $oinputgamedir = GUICtrlCreateInput($sPathDir, 186, 286, 281, 21)
GUICtrlCreateLabel("Game Klient Klasörü", 66, 286, 116, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $obuttonclientdirbrowse = GUICtrlCreateButton("Araştır", 474, 286, 75, 21, BitOR($BS_FLAT, $WS_BORDER))
GUICtrlCreateLabel("Game Klient Tipi", 66, 262, 116, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $ocomboclienttype = GUICtrlCreateCombo($sClientExe, 186, 262, 145, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "NostaleX.dat|Nostale.dat")
GUICtrlCreateLabel("Game Klient Dili", 66, 238, 116, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $ocomboclientlang = GUICtrlCreateCombo($sClientLang, 186, 238, 145, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "TUR_tur|ENG|DE|RU|IT|FR|CZ|PL|<Diğer>")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group7 = GUICtrlCreateGroup("Dll Inject", 51, 132, 521, 81)
Global $oinputdll = GUICtrlCreateInput("nosPacket.dll", 187, 180, 281, 21)
GUICtrlCreateLabel("Inject Edilecek DLL", 67, 180, 116, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $obuttonbrowsedll = GUICtrlCreateButton("Araştır", 475, 180, 75, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttoninjectdll = GUICtrlCreateButton("DLL Inject", 67, 148, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group8 = GUICtrlCreateGroup("Yeni Klient ve Bot Çalıştırma", 50, 70, 521, 57)
Global $obuttonrun = GUICtrlCreateButton("Klient Çalıştır", 186, 94, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obottunnewbot = GUICtrlCreateButton("Bot Çalıştır", 442, 94, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonclientnewrunnconnect = GUICtrlCreateButton("Klient+Bot Çalıştır", 314, 94, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonrunnconnect = GUICtrlCreateButton("Klient Çalıştır ve Bağlan", 58, 94, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group9 = GUICtrlCreateGroup("Klient Seçimi", 50, 6, 521, 57)
Global $ocomboclientlis = GUICtrlCreateCombo("", 226, 22, 161, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
Global $Label8 = GUICtrlCreateLabel("Karakter ve Klient Seçimi", 66, 22, 156, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $obuttonrefreshclientlist = GUICtrlCreateButton("Yenile", 394, 22, 75, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonconnectclient = GUICtrlCreateButton("Bağlan", 474, 22, 75, 21, BitOR($BS_FLAT, $WS_BORDER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet5 = GUICtrlCreateTabItem("Otomatik Effect")
Global $Group10 = GUICtrlCreateGroup("Otomatik Efekt", 42, 6, 529, 385)
Global $Checkbox1 = GUICtrlCreateCheckbox("1", 50, 30, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox2 = GUICtrlCreateCheckbox("2", 50, 54, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox3 = GUICtrlCreateCheckbox("3", 50, 78, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox4 = GUICtrlCreateCheckbox("4", 50, 102, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox5 = GUICtrlCreateCheckbox("5", 50, 126, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox6 = GUICtrlCreateCheckbox("Q", 50, 150, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox7 = GUICtrlCreateCheckbox("W", 50, 174, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox8 = GUICtrlCreateCheckbox("E", 50, 198, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox9 = GUICtrlCreateCheckbox("R", 50, 222, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox10 = GUICtrlCreateCheckbox("T", 50, 246, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox11 = GUICtrlCreateCheckbox("6", 50, 270, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox12 = GUICtrlCreateCheckbox("7", 50, 294, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox13 = GUICtrlCreateCheckbox("8", 50, 318, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox14 = GUICtrlCreateCheckbox("9", 50, 342, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Checkbox15 = GUICtrlCreateCheckbox("0", 50, 366, 37, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_PUSHLIKE, $BS_FLAT))
Global $Combo5 = GUICtrlCreateCombo("", 90, 30, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo6 = GUICtrlCreateCombo("", 90, 54, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo7 = GUICtrlCreateCombo("", 90, 78, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo8 = GUICtrlCreateCombo("", 90, 102, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo9 = GUICtrlCreateCombo("", 90, 126, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo10 = GUICtrlCreateCombo("", 90, 150, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo11 = GUICtrlCreateCombo("", 90, 174, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo12 = GUICtrlCreateCombo("", 90, 198, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo13 = GUICtrlCreateCombo("", 90, 222, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo14 = GUICtrlCreateCombo("", 90, 246, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo15 = GUICtrlCreateCombo("", 90, 270, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo16 = GUICtrlCreateCombo("", 90, 294, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo17 = GUICtrlCreateCombo("", 90, 318, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo18 = GUICtrlCreateCombo("", 90, 342, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
Global $Combo19 = GUICtrlCreateCombo("", 90, 366, 145, 25, BitOR($CBS_SIMPLE, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet6 = GUICtrlCreateTabItem("Dinlenme Ayarları")
Global $Group11 = GUICtrlCreateGroup("YP Yenileme", 50, 6, 257, 329)
Global $osliderhp_rest_start = GUICtrlCreateSlider(154, 102, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 30)
Global $osliderhp_rest_until = GUICtrlCreateSlider(154, 142, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 100)
Global $olabelhp_rest_start_percent = GUICtrlCreateLabel("30 %", 250, 102, 52, 21)
Global $olabelhp_rest_until_percent = GUICtrlCreateLabel("100 %", 250, 142, 52, 21)
Global $olabelhp_rest_start_value = GUICtrlCreateLabel("30 YP", 250, 118, 52, 21, $SS_CENTERIMAGE)
Global $olabelhp_rest_until_value = GUICtrlCreateLabel("100 YP", 250, 158, 52, 21, $SS_CENTERIMAGE)
GUIStartGroup()
Global $oradiohp_rest_on = GUICtrlCreateRadio("Açık", 154, 30, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiohp_rest_off = GUICtrlCreateRadio("Kapalı", 226, 30, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label21 = GUICtrlCreateLabel("Dinlenme", 58, 30, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradiohp_food_on = GUICtrlCreateRadio("Açık", 154, 54, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradio_hp_food_off = GUICtrlCreateRadio("Kapalı", 226, 54, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label22 = GUICtrlCreateLabel("Yemek", 58, 54, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $Label23 = GUICtrlCreateLabel("Başlangıç YP", 58, 110, 92, 17, $SS_RIGHT)
Global $Label24 = GUICtrlCreateLabel("Bitiş YP", 58, 150, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $oradiohp_spell_on = GUICtrlCreateRadio("Açık", 154, 81, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiohp_spell_off = GUICtrlCreateRadio("Kapalı", 226, 81, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label25 = GUICtrlCreateLabel("Beceri", 58, 81, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $ocombohp_food = GUICtrlCreateCombo("", 122, 182, 41, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1|2|3|4|5|Q|W|E|R|T|6|7|8|9|0", "9")
Global $ocombohp_spell = GUICtrlCreateCombo("", 258, 182, 41, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1|2|3|4|5|Q|W|E|R|T|6|7|8|9|0", "8")
Global $Label26 = GUICtrlCreateLabel("Yemek", 58, 182, 60, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $Label27 = GUICtrlCreateLabel("Beceri", 186, 182, 68, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $Label28 = GUICtrlCreateLabel("En Fazla Bekleme Süresi", 58, 206, 156, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $oinputhp_waittime = GUICtrlCreateInput("20", 218, 206, 41, 21)
Global $Label29 = GUICtrlCreateLabel("Saniye", 266, 206, 36, 21, $SS_CENTERIMAGE)
GUIStartGroup()
Global $oradiohp_pot_on = GUICtrlCreateRadio("Açık", 153, 242, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiohp_pot_off = GUICtrlCreateRadio("Kapalı", 225, 242, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label43 = GUICtrlCreateLabel("İksir", 57, 242, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $osliderhp_pot = GUICtrlCreateSlider(153, 265, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 15)
Global $olabelhp_pot_percent = GUICtrlCreateLabel("15 %", 249, 265, 52, 21)
Global $olabelhp_pot_value = GUICtrlCreateLabel("15 YP", 249, 281, 52, 21, $SS_CENTERIMAGE)
Global $Label46 = GUICtrlCreateLabel("Kritik YP", 57, 273, 92, 17, $SS_RIGHT)
Global $ocombohp_pot = GUICtrlCreateCombo("", 130, 306, 41, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1|2|3|4|5|Q|W|E|R|T|6|7|8|9|0", "6")
Global $Label47 = GUICtrlCreateLabel("İksir", 58, 306, 68, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group12 = GUICtrlCreateGroup("BP Yenileme", 314, 7, 257, 329)
Global $oslidermp_rest_start = GUICtrlCreateSlider(418, 103, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 30)
Global $oslidermp_rest_until = GUICtrlCreateSlider(418, 143, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 100)
Global $olabelmp_rest_start_percent = GUICtrlCreateLabel("30 %", 514, 103, 52, 21)
Global $olabelmp_rest_until_percent = GUICtrlCreateLabel("100 %", 514, 143, 52, 21)
Global $olabelmp_rest_start_value = GUICtrlCreateLabel("30 BP", 514, 119, 52, 21, $SS_CENTERIMAGE)
Global $olabelmp_rest_until_value = GUICtrlCreateLabel("100 BP", 514, 159, 52, 21, $SS_CENTERIMAGE)
GUIStartGroup()
Global $oradiomp_rest_on = GUICtrlCreateRadio("Açık", 418, 31, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomp_rest_off = GUICtrlCreateRadio("Kapalı", 490, 31, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label34 = GUICtrlCreateLabel("Dinlenme", 322, 31, 92, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $oradiomp_food_on = GUICtrlCreateRadio("Açık", 418, 55, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomp_food_off = GUICtrlCreateRadio("Kapalı", 490, 55, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label35 = GUICtrlCreateLabel("Yemek", 322, 55, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $Label36 = GUICtrlCreateLabel("Başlangıç BP", 322, 111, 92, 17, $SS_RIGHT)
Global $Label37 = GUICtrlCreateLabel("Bitiş BP", 322, 151, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $oradiomp_spell_on = GUICtrlCreateRadio("Açık", 418, 79, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomp_spell_off = GUICtrlCreateRadio("Kapalı", 490, 79, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label38 = GUICtrlCreateLabel("Beceri", 322, 79, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $ocombomp_food = GUICtrlCreateCombo("", 386, 183, 41, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1|2|3|4|5|Q|W|E|R|T|6|7|8|9|0", "0")
Global $ocombomp_spell = GUICtrlCreateCombo("", 522, 183, 41, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1|2|3|4|5|Q|W|E|R|T|6|7|8|9|0", "8")
Global $Label39 = GUICtrlCreateLabel("Yemek", 322, 183, 60, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $Label40 = GUICtrlCreateLabel("Beceri", 450, 183, 68, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $Label41 = GUICtrlCreateLabel("En Fazla Bekleme Süresi", 322, 207, 156, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
Global $oinputmp_waittime = GUICtrlCreateInput("20", 482, 207, 41, 21)
Global $Label42 = GUICtrlCreateLabel("Saniye", 530, 207, 36, 21, $SS_CENTERIMAGE)
GUIStartGroup()
Global $oradiomp_pot_on = GUICtrlCreateRadio("Açık", 418, 239, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiomp_pot_off = GUICtrlCreateRadio("Kapalı", 490, 239, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Label48 = GUICtrlCreateLabel("İksir", 322, 239, 92, 17, $SS_RIGHT)
GUIStartGroup()
Global $oslidermp_pot = GUICtrlCreateSlider(418, 263, 92, 37, BitOR($GUI_SS_DEFAULT_SLIDER, $TBS_TOP, $TBS_LEFT, $TBS_ENABLESELRANGE, $TBS_FIXEDLENGTH))
GUICtrlSetData(-1, 15)
Global $olabelmp_pot_percent = GUICtrlCreateLabel("15 %", 514, 263, 52, 21)
Global $olabelmp_pot_value = GUICtrlCreateLabel("15 BP", 514, 279, 52, 21, $SS_CENTERIMAGE)
Global $Label51 = GUICtrlCreateLabel("Kritik BP", 322, 271, 92, 17, $SS_RIGHT)
Global $ocombomp_pot = GUICtrlCreateCombo("", 394, 303, 41, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1|2|3|4|5|Q|W|E|R|T|6|7|8|9|0", "7")
Global $Label52 = GUICtrlCreateLabel("İksir", 322, 303, 68, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet7 = GUICtrlCreateTabItem("Yaratık Filitresi")
Global $Group13 = GUICtrlCreateGroup("Kara Liste", 50, 14, 257, 369)
Global $olistblack = GUICtrlCreateList("", 66, 62, 225, 266)
Global $oinputblacklist = GUICtrlCreateInput("", 66, 30, 161, 21)
Global $obuttonblacklistadd = GUICtrlCreateButton("Ekle", 234, 30, 59, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonblacklistdelete = GUICtrlCreateButton("Seçimi Sil", 74, 342, 99, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonwhitelistclear = GUICtrlCreateButton("Tümünü Sil", 178, 342, 99, 21, BitOR($BS_FLAT, $WS_BORDER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group14 = GUICtrlCreateGroup("Beyaz Liste", 314, 14, 257, 369)
Global $olistwhite = GUICtrlCreateList("", 330, 62, 225, 266)
Global $oinputwhitelist = GUICtrlCreateInput("", 330, 30, 161, 21)
Global $obuttonwhitelistadd = GUICtrlCreateButton("Ekle", 498, 30, 59, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonwhitelistdelet = GUICtrlCreateButton("Seçimi Sil", 338, 342, 99, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonwhitelistclea = GUICtrlCreateButton("Tümünü Sil", 442, 342, 99, 21, BitOR($BS_FLAT, $WS_BORDER))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet8 = GUICtrlCreateTabItem("Geçiş Noktaları")
Global $Group15 = GUICtrlCreateGroup("Geçiş Noktaları", 50, 14, 521, 369)
Global $oinputwaypointadd = GUICtrlCreateInput("", 66, 30, 105, 21)
Global $obuttonwaypointadd = GUICtrlCreateButton("Ekle", 178, 30, 59, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonwaypointclear = GUICtrlCreateButton("Tümünü Sil", 66, 334, 99, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $obuttonwaypointgetcord = GUICtrlCreateButton("Getir", 242, 30, 59, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $oeditwaypoint = GUICtrlCreateEdit("", 66, 62, 233, 265)
Global $obuttonwaypointrefresh = GUICtrlCreateButton("Grafiği Yenile", 178, 334, 99, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Pic1 = GUICtrlCreatePic("D:\Project\AutoIt\Nostale\Src\1.bmp", 304, 64, 146, 146)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet4 = GUICtrlCreateTabItem("Araçlar")
Global $Group16 = GUICtrlCreateGroup("İşlemci Kullanımı", 50, 14, 257, 121)
Global $oslidercpureduc = GUICtrlCreateSlider(67, 56, 186, 37)
GUICtrlSetLimit(-1, 300, 30)
GUICtrlSetData(-1, 30)
GUIStartGroup()
Global $oradiocpureduc_on = GUICtrlCreateRadio("Açık", 154, 38, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $oradiocpureduc_off = GUICtrlCreateRadio("Kapalı", 226, 38, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateLabel("CPU Düşürücü", 58, 38, 90, 17, $SS_RIGHT)
GUIStartGroup()
Global $olabelcpureduc = GUICtrlCreateLabel("30", 258, 70, 36, 17)
Global $Label10 = GUICtrlCreateLabel("FPS Değerlerini Düşürmektedir!", 64, 88, 228, 34, BitOR($SS_CENTER, $SS_CENTERIMAGE))
GUICtrlSetColor(-1, 0x800000)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group17 = GUICtrlCreateGroup("İlave Ekran Ayarları", 50, 142, 521, 129)
Global $Button1 = GUICtrlCreateButton("1280 x 1024", 186, 166, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button2 = GUICtrlCreateButton("1440 x 900", 442, 166, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button3 = GUICtrlCreateButton("1280 x 800", 314, 166, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button4 = GUICtrlCreateButton("1024 x768", 58, 166, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button5 = GUICtrlCreateButton("1280 x 720 (HDReady)", 314, 198, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button6 = GUICtrlCreateButton("1366 x 700", 186, 198, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button7 = GUICtrlCreateButton("1920 x 1080 (FullHD)", 442, 198, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Button8 = GUICtrlCreateButton("1024 x 700", 58, 198, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Combo1 = GUICtrlCreateCombo("800", 58, 230, 123, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "800|1024|1280|1366|1920")
Global $Combo2 = GUICtrlCreateCombo("600", 314, 230, 123, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "600|700|720|768|900|1024|1080")
Global $Button9 = GUICtrlCreateButton("Diğer", 442, 230, 123, 21, BitOR($BS_FLAT, $WS_BORDER))
Global $Label11 = GUICtrlCreateLabel("x", 187, 227, 123, 21, BitOR($SS_CENTER, $SS_CENTERIMAGE))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group18 = GUICtrlCreateGroup("Zamanlayıcı", 314, 14, 257, 121)
GUIStartGroup()
Global $Radio1 = GUICtrlCreateRadio("Açık", 418, 38, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Radio2 = GUICtrlCreateRadio("Kapalı", 490, 38, 73, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateLabel("Zamanlayıcı", 322, 38, 90, 17, $SS_RIGHT)
GUIStartGroup()
GUIStartGroup()
Global $Radio3 = GUICtrlCreateRadio("Botu Durdur", 322, 93, 121, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUICtrlSetState(-1, $GUI_CHECKED)
Global $Radio4 = GUICtrlCreateRadio("Botu Kapat", 442, 93, 121, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Radio5 = GUICtrlCreateRadio("Klienti Kapat", 322, 109, 121, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
Global $Radio6 = GUICtrlCreateRadio("Bilgisayarı Kapat", 442, 109, 121, 17, BitOR($GUI_SS_DEFAULT_RADIO, $BS_PUSHLIKE, $BS_FLAT))
GUIStartGroup()
GUIStartGroup()
GUICtrlCreateLabel("Saat", 322, 70, 90, 17, $SS_RIGHT)
Global $Combo3 = GUICtrlCreateCombo("00", 419, 66, 65, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23")
Global $Combo4 = GUICtrlCreateCombo("00", 498, 66, 65, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "00|10|20|30|40|50")
GUIStartGroup()
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $hGraphic_Win = GUICreate("", 146, 146, 304, 64, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $hgui)
Global $ographicwaypoint = GUICtrlCreateGraphic(0, 0, 146, 146)
GUICtrlSetBkColor(-1, 0xFFDEAD)
GUISetState()
_WinAPI_SetLayeredWindowAttributes($hGraphic_Win, 0xFFDEAD, 100)
If GUICtrlRead($Tab1) = 6 Then
	WinSetState($hGraphic_Win, "", @SW_SHOW)
Else
	WinSetState($hGraphic_Win, "", @SW_HIDE)
EndIf

AdlibRegister("_display", 500)

_updatenametitle()

Global $ntimernormal, $ntimercritic, $ntimerskill, $ntimerlooting, $ntimerselectchk, $ntimerselectnear, $ntimerhp, $ntimermp, $ilasthp, $ilastmp, $ilastmaxhp, $ilastmaxmp

$ntimernormal = TimerInit()
$ntimercritic = TimerInit()
$ntimerskill = TimerInit()
$ntimerlooting = TimerInit()
$ntimerselectchk = TimerInit()
$ntimerhp = TimerInit()
$ntimermp = TimerInit()
$ilasthp = _pointer("HP")
$ilastmp = _pointer("MP")
$ilastmaxhp = _pointer("MAXHP")
$ilastmaxmp = _pointer("MAXMP")

While 1
	Global $nmsg
	$nmsg = GUIGetMsg()
	Switch $nmsg
		Case -3;, $obuttonexit

;~ 			_memoryasmwrite($eagleeye1, "E8", $ahmemomopen)
;~ 			_memoryasmwrite($eagleeye2, "FF", $ahmemomopen)
;~ 			_memoryasmwrite($nodelay2a, "BA 10645200", $ahmemomopen)

			_memoryasmwrite($moba, "80 BB CE000000 00", $ahmemomopen)
			_memoryasmwrite($itema, "80 BB CF 00 00 00 00", $ahmemomopen)
			_memoryasmwrite($npc1a, "80 BB C8 00 00 00 00", $ahmemomopen)
			_memoryasmwrite($npc2a, "80 BB CD 00 00 00 00", $ahmemomopen)
			_memoryasmwrite($player, "80 BB CC 00 00 00 00", $ahmemomopen)
			_memoryasmwrite($tsa, "80 BB CA 00 00 00 00", $ahmemomopen)
			_memoryasmwrite($portala, "80 BB C9 00 00 00 00", $ahmemomopen)
			_memoryasmwrite($speeda, "8A 83 9E 00 00 00", $ahmemomopen)
;~ 			_memoryasmwrite($eagleeye1, "E8", $ahmemomopen)
;~ 			_memoryasmwrite($eagleeye2, "FF", $ahmemomopen)
			_memoryasmwrite($nodelay_p_adress, "8B 45 F0 83 CA FF", $ahmemomopen)
			_memoryasmwrite($nodelay_n_adress, "8B 45 F0 83 CA FF", $ahmemomopen)
;~ 			_memoryasmwrite($nodelay2a, "BA 10645200", $ahmemomopen)
			_memoryasmwrite($zooma, "75 0E", $ahmemomopen)
			_memorypointerwrite($sleep_adress, $ahmemomopen, $sleep_offset, 30, "dword")
			_memoryasmwrite($petbag_address, "8B D0", $ahmemomopen)
			_memoryasmwrite($eagleeye_address, "55", $ahmemomopen)

			Exit
		Case $Tab1
			If GUICtrlRead($Tab1) = 6 Then
				WinSetState($hGraphic_Win, "", @SW_SHOW)
			Else
				WinSetState($hGraphic_Win, "", @SW_HIDE)
			EndIf
		Case $obuttonstart
			$fstate = "Çalışıyor"
			$fstart = True
			GUICtrlSetData($obuttonstart, "Duraklat")
			_updatenametitle()
		Case $obuttonpause
			$fstart = False
			$fstate = "Durduruldu"
			GUICtrlSetData($obuttonstart, "Başlat")
			_updatenametitle()
		Case $osliderspeed, $oradiospeedon, $oradiospeedoff
			If (GUICtrlRead($oradiospeedon) = 1) Then
				Global $vel
				$vel = GUICtrlRead($osliderspeed)
				_memoryasmwrite($speeda, "04" & Hex($vel, 2) & "90 90 90 90", $ahmemomopen)
				GUICtrlSetData($olabelspeed, StringFormat("x %.1f", ($vel / 10)))
			Else
				_memoryasmwrite($speeda, "8A 83 9E 00 00 00", $ahmemomopen)
			EndIf
		Case $oradiommobon, $oradiommoboff
			If (GUICtrlRead($oradiommobon) = 1) Then
				_memoryasmwrite($moba, "80 BB CE000000 01", $ahmemomopen)
			Else
				_memoryasmwrite($moba, "80 BB CE000000 00", $ahmemomopen)
			EndIf
		Case $oradiomitemon, $oradiomitemoff
			If (GUICtrlRead($oradiomitemoff) = 1) Then
				_memoryasmwrite($itema, "80 BB CF 00 00 00 00", $ahmemomopen)
			Else
				_memoryasmwrite($itema, "80 BB CF 00 00 00 01", $ahmemomopen)
			EndIf
		Case $oradiomnpc1on, $oradiomnpc1off
			If (GUICtrlRead($oradiomnpc1off) = 1) Then
				_memoryasmwrite($npc1a, "80 BB C8 00 00 00 01", $ahmemomopen)
			Else
				_memoryasmwrite($npc1a, "80 BB C8 00 00 00 00", $ahmemomopen)
			EndIf
		Case $oradiomnpc2on, $oradiomnpc2off
			If (GUICtrlRead($oradiomnpc2on) = 1) Then
				_memoryasmwrite($npc2a, "80 BB CD 00 00 00 01", $ahmemomopen)
			Else
				_memoryasmwrite($npc2a, "80 BB CD 00 00 00 00", $ahmemomopen)
			EndIf
		Case $oradiomplayeron, $oradiomplayeroff
			If (GUICtrlRead($oradiomplayeron) = 1) Then
				_memoryasmwrite($player, "80 BB CC 00 00 00 01", $ahmemomopen)
			Else
				_memoryasmwrite($player, "80 BB CC 00 00 00 00", $ahmemomopen)
			EndIf
		Case $oradiomtson, $oradiomtsoff
			If (GUICtrlRead($oradiomtsoff) = 1) Then
				_memoryasmwrite($tsa, "80 BB CA 00 00 00 01", $ahmemomopen)
			Else
				_memoryasmwrite($tsa, "80 BB CA 00 00 00 00", $ahmemomopen)
			EndIf
		Case $oradiomportalon, $oradiomportaloff
			If (GUICtrlRead($oradiomportaloff) = 1) Then
				_memoryasmwrite($portala, "80 BB C9 00 00 00 01", $ahmemomopen)
			Else
				_memoryasmwrite($portala, "80 BB C9 00 00 00 00", $ahmemomopen)
			EndIf
		Case $oradionodelayon, $oradionodelayoff
			If (GUICtrlRead($oradionodelayon) = 1) Then
				_memoryasmwrite($nodelay_p_adress, "90 90 90 90 90 90", $ahmemomopen)
				_memoryasmwrite($nodelay_n_adress, "90 90 90 90 90 90", $ahmemomopen)
;~ 				_memoryasmwrite($nodelay2a, "90 90 90 90 90", $ahmemomopen)
			Else
				_memoryasmwrite($nodelay_p_adress, "8B 45 F0 83 CA FF", $ahmemomopen)
				_memoryasmwrite($nodelay_n_adress, "8B 45 F0 83 CA FF", $ahmemomopen)
;~ 				_memoryasmwrite($nodelay2a, "BA 10645200", $ahmemomopen)
			EndIf
		Case $oradiozoomhackon, $oradiozoomhackoff
			If (GUICtrlRead($oradiozoomhackon) = 1) Then
				_memoryasmwrite($zooma, "EB 3C", $ahmemomopen)
			Else
				_memoryasmwrite($zooma, "75 0E", $ahmemomopen)
			EndIf
		Case $oradioeagleeyeon, $oradioeagleeyeoff
			If (GUICtrlRead($oradioeagleeyeon) = 1) Then
;~ 				_memoryasmwrite($eagleeye1, "EB", $ahmemomopen)
;~ 				_memoryasmwrite($eagleeye2, "EB", $ahmemomopen)
				_memoryasmwrite($eagleeye_address, "C3", $ahmemomopen)
			Else
;~ 				_memoryasmwrite($eagleeye1, "E8", $ahmemomopen)
;~ 				_memoryasmwrite($eagleeye2, "FF", $ahmemomopen)
				_memoryasmwrite($eagleeye_address, "55", $ahmemomopen)
			EndIf
		Case $oradiopartnerbagon, $oradiopartnerbagoff
			If (GUICtrlRead($oradiopartnerbagon) = 1) Then
				_memoryasmwrite($petbag_address, "B2 32", $ahmemomopen)
			Else
				_memoryasmwrite($petbag_address, "8B D0", $ahmemomopen)
			EndIf
		Case $osliderhp_rest_start, $osliderhp_rest_until, $osliderhp_pot, $oslidermp_rest_start, $oslidermp_rest_until, $oslidermp_pot
			GUICtrlSetData($olabelhp_rest_start_percent, StringFormat("%d %%", GUICtrlRead($osliderhp_rest_start)))
			GUICtrlSetData($olabelhp_rest_until_percent, StringFormat("%d %%", GUICtrlRead($osliderhp_rest_until)))
			GUICtrlSetData($olabelhp_pot_percent, StringFormat("%d %%", GUICtrlRead($osliderhp_pot)))

			GUICtrlSetData($olabelhp_rest_start_value, StringFormat("%d YP", Round(_pointer("MAXHP") * GUICtrlRead($osliderhp_rest_start) / 100)))
			GUICtrlSetData($olabelhp_rest_until_value, StringFormat("%d YP", Round(_pointer("MAXHP") * GUICtrlRead($osliderhp_rest_until) / 100)))
			GUICtrlSetData($olabelhp_pot_value, StringFormat("%d YP", Round(_pointer("MAXHP") * GUICtrlRead($osliderhp_pot) / 100)))

			GUICtrlSetData($olabelmp_rest_start_percent, StringFormat("%d %%", GUICtrlRead($oslidermp_rest_start)))
			GUICtrlSetData($olabelmp_rest_until_percent, StringFormat("%d %%", GUICtrlRead($oslidermp_rest_until)))
			GUICtrlSetData($olabelmp_pot_percent, StringFormat("%d %%", GUICtrlRead($oslidermp_pot)))

			GUICtrlSetData($olabelmp_rest_start_value, StringFormat("%d BP", Round(_pointer("MAXMP") * GUICtrlRead($oslidermp_rest_start) / 100)))
			GUICtrlSetData($olabelmp_rest_until_value, StringFormat("%d BP", Round(_pointer("MAXMP") * GUICtrlRead($oslidermp_rest_until) / 100)))
			GUICtrlSetData($olabelmp_pot_value, StringFormat("%d BP", Round(_pointer("MAXMP") * GUICtrlRead($oslidermp_pot) / 100)))
		Case $oslidercpureduc, $oradiocpureduc_on, $oradiocpureduc_off
			If (GUICtrlRead($oradiocpureduc_on) = 1) Then
				Global $vul
				$vul = GUICtrlRead($oslidercpureduc)
				_memorypointerwrite($sleep_adress, $ahmemomopen, $sleep_offset, $vul, "dword")
				GUICtrlSetData($olabelcpureduc, $vul)
			Else
				_memorypointerwrite($sleep_adress, $ahmemomopen, $sleep_offset, 30, "dword")
			EndIf
		Case $oslider_skill_start, $oslider_skill_until
			GUICtrlSetData($olabel_skill_start, StringFormat("%d %%", GUICtrlRead($oslider_skill_start)))
			GUICtrlSetData($olabel_skill_until, StringFormat("%d %%", GUICtrlRead($oslider_skill_until)))
		Case $obuttonrun
			_runclient()
		Case $obuttonwaypointrefresh
			drawgraph()
		Case $obuttoninjectdll
			_INJECTDLL($ihpid, GUICtrlRead($oinputdll))
		Case $ocomboclientlang
			$sClientLang = GUICtrlRead($ocomboclientlang)
			$sPathDir = @ProgramFilesDir & "\GameforgeLive\Games\" & $sClientLang & "\NosTale\"
			GUICtrlSetData($oinputgamedir, $sPathDir)
			$sFClientPath = $sPathDir & $sClientExe
		Case $ocomboclienttype, $oinputgamedir
			$sPathDir = GUICtrlRead($oinputgamedir)
			$sClientExe = GUICtrlRead($ocomboclienttype)
			$sFClientPath = $sPathDir & $sClientExe
		Case $obuttonclientdirbrowse
			_BrowseGamePath()
	EndSwitch
	If ($fstart) Then
		If Not _pointer("CHATPANEL") Then
			If Not _pointer("SELECT") Then
				If (GUICtrlRead($oradiohp_food_on) = 1) Or (GUICtrlRead($oradiohp_rest_on) = 1) Or (GUICtrlRead($oradiohp_spell_on) = 1) Then
					$ilasthp = _pointer("HP")
					$ilastmaxhp = _pointer("MAXHP")
					If (($ilasthp * 100) / $ilastmaxhp) <= GUICtrlRead($osliderhp_rest_start) Then

						$ntimerhp = TimerInit()
						$ilasthp = _pointer("HP")
						Do
							If (GUICtrlRead($oradiohp_spell_on) = 1) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombohp_spell))
							Sleep(3000)
							$ilasthp = _pointer("HP")
							If (GUICtrlRead($oradiohp_rest_on) = 1) Then
								If _pointer("SIT") <> 1 Then _postmessage_send($lnostaleclient[1][1], "c")
							EndIf
							If (GUICtrlRead($oradiohp_food_on) = 1) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombohp_food))
							Sleep(1000)
							If _pointer("HP") < $ilasthp Then ExitLoop 1
							$ilasthp = _pointer("HP")
						Until ((_pointer("HP") * 100) / _pointer("MAXHP")) > GUICtrlRead($osliderhp_rest_start)
						$ilasthp = _pointer("HP")
						While ((_pointer("HP") * 100) / _pointer("MAXHP")) <= GUICtrlRead($osliderhp_rest_until)

							Sleep(1000)
							If (GUICtrlRead($oradiohp_spell_on) = 1) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombohp_spell))
							If (GUICtrlRead($oradiohp_rest_on) = 1) Then
								If _pointer("SIT") <> 1 Then ExitLoop 1
							EndIf
							If _pointer("HP") < $ilasthp Then ExitLoop 1
							$ilasthp = _pointer("HP")
							If (TimerDiff($ntimerhp) >= GUICtrlRead($oinputhp_waittime) * 1000) Then ExitLoop 1
						WEnd
					EndIf
				EndIf
				If (GUICtrlRead($oradiomp_food_on) = 1) Or (GUICtrlRead($oradiomp_rest_on) = 1) Or (GUICtrlRead($oradiomp_spell_on) = 1) Then
					$ilastmp = _pointer("MP")
					$ilastmaxmp = _pointer("MAXMP")
					$ilasthp = _pointer("HP")
					If (($ilastmp * 100) / $ilastmaxmp) <= GUICtrlRead($oslidermp_rest_start) Then

						$ntimermp = TimerInit()
						$ilastmp = _pointer("MP")
						$ilasthp = _pointer("HP")
						Do
							If (GUICtrlRead($oradiomp_spell_on) = 1) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombomp_spell))
							Sleep(3000)
							If (GUICtrlRead($oradiomp_rest_on) = 1) Then
								If _pointer("SIT") <> 1 Then _postmessage_send($lnostaleclient[1][1], "c")
							EndIf
							$ilastmp = _pointer("MP")
							$ilasthp = _pointer("HP")
							If (GUICtrlRead($oradiomp_food_on) = 1) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombomp_food))
							Sleep(1000)
							If _pointer("HP") < $ilasthp Then ExitLoop 1
							$ilastmp = _pointer("MP")
							$ilasthp = _pointer("HP")
						Until ((_pointer("MP") * 100) / _pointer("MAXMP")) > GUICtrlRead($oslidermp_rest_start)
						$ilastmp = _pointer("MP")
						$ilasthp = _pointer("HP")
						While ((_pointer("MP") * 100) / _pointer("MAXMP")) <= GUICtrlRead($oslidermp_rest_until)
							$ilastmp = _pointer("MP")
							$ilasthp = _pointer("HP")
							Sleep(1000)
							If (GUICtrlRead($oradiomp_spell_on) = 1) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombomp_spell))
							If (GUICtrlRead($oradiomp_rest_on) = 1) Then
								If _pointer("SIT") <> 1 Then ExitLoop 1
							EndIf
							If _pointer("HP") < $ilasthp Then ExitLoop 1
							$ilastmp = _pointer("MP")
							$ilasthp = _pointer("HP")
							If (TimerDiff($ntimermp) >= GUICtrlRead($oinputmp_waittime) * 1000) Then ExitLoop 1
						WEnd
					EndIf
				EndIf
			Else
				If (TimerDiff($ntimercritic) >= 2500) Then
					If (GUICtrlRead($oradiomp_pot_on) = 1) Then
						If ((_pointer("MP") * 100) / _pointer("MAXMP")) <= GUICtrlRead($oslidermp_pot) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombomp_pot))
					EndIf
					If (GUICtrlRead($oradiohp_pot_on) = 1) Then
						If ((_pointer("HP") * 100) / _pointer("MAXHP")) <= GUICtrlRead($osliderhp_pot) Then _postmessage_send($lnostaleclient[1][1], GUICtrlRead($ocombohp_pot))
					EndIf
					$ntimercritic = TimerInit()
				EndIf
			EndIf
			If (TimerDiff($ntimernormal) >= 500) Then
				If Not (GUICtrlRead($oradioattacktype_0) = 1) Then
					If _pointer("SIT") = 1 Then _postmessage_send($lnostaleclient[1][1], "c")
					If _pointer("SELECT") And _pointer("SELECTHP") > 0 Then
						If (GUICtrlRead($oradioattacktype_1) = 1) And _pointer("ATTACKTYPE") <> 2 Then _postmessage_send($lnostaleclient[1][1], "{Space}")
						If (GUICtrlRead($oradioattacktype_2) = 1) And _pointer("ATTACKTYPE") <> 3 Then _postmessage_send($lnostaleclient[1][1], "z")
					EndIf
				EndIf
				If Not _pointer("SELECT") Or (TimerDiff($ntimerselectnear) >= 5000) Then
					If (GUICtrlRead($oradiofindmobon) = 1) Then _postmessage_send($lnostaleclient[1][1], "{F8}")
					If (GUICtrlRead($oradiofindplayeron) = 1) Then _postmessage_send($lnostaleclient[1][1], "{F6}")
					$ntimerselectnear = TimerInit()
				EndIf
				$ntimernormal = TimerInit()
			EndIf
			If (TimerDiff($ntimerskill) >= 500) Then
				If _pointer("SELECT") Then
					If _pointer("SELECTHP") >= GUICtrlRead($oslider_skill_start) And _pointer("SELECTHP") <= GUICtrlRead($oslider_skill_until) Then
						If (GUICtrlRead($ocheckboxskill_1) = 1) And (_pointer("MACROENABLE", 1) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "1")
						If (GUICtrlRead($ocheckboxskill_2) = 1) And (_pointer("MACROENABLE", 2) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "2")
						If (GUICtrlRead($ocheckboxskill_3) = 1) And (_pointer("MACROENABLE", 3) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "3")
						If (GUICtrlRead($ocheckboxskill_4) = 1) And (_pointer("MACROENABLE", 4) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "4")
						If (GUICtrlRead($ocheckboxskill_5) = 1) And (_pointer("MACROENABLE", 5) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "5")
						If (GUICtrlRead($ocheckboxskill_q) = 1) And (_pointer("MACROENABLE", 6) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "q")
						If (GUICtrlRead($ocheckboxskill_w) = 1) And (_pointer("MACROENABLE", 7) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "w")
						If (GUICtrlRead($ocheckboxskill_e) = 1) And (_pointer("MACROENABLE", 8) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "e")
						If (GUICtrlRead($ocheckboxskill_r) = 1) And (_pointer("MACROENABLE", 9) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "r")
						If (GUICtrlRead($ocheckboxskill_t) = 1) And (_pointer("MACROENABLE", 10) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "t")
						If (GUICtrlRead($ocheckboxskill_6) = 1) And (_pointer("MACROENABLE", 11) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "6")
						If (GUICtrlRead($ocheckboxskill_7) = 1) And (_pointer("MACROENABLE", 12) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "7")
						If (GUICtrlRead($ocheckboxskill_8) = 1) And (_pointer("MACROENABLE", 13) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "8")
						If (GUICtrlRead($ocheckboxskill_9) = 1) And (_pointer("MACROENABLE", 14) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "9")
						If (GUICtrlRead($ocheckboxskill_0) = 1) And (_pointer("MACROENABLE", 15) = 0xFFFFFFFF) And Random(0, 1, 1) Then _postmessage_send($lnostaleclient[1][1], "0")
					EndIf
				EndIf
				$ntimerskill = TimerInit()
			EndIf
			If (TimerDiff($ntimerlooting) >= 500) Then
				If (GUICtrlRead($oradiolooton) = 1) Then _postmessage_send($lnostaleclient[1][1], "x")
				$ntimerlooting = TimerInit()
			EndIf
		EndIf
	EndIf
WEnd

Func _BrowseGamePath()
	Local Const $sMessageChoiceNostaleDir = "Nostale yüklü olan yoldan nostaleyi seçin"
	Local $sFileOpenDialog = FileOpenDialog($sMessageChoiceNostaleDir, $sPathDir & "\", "Nostale (NostaleX.dat;Nostale.dat;Nostale.exe)", $FD_FILEMUSTEXIST)
	If Not @error Then
		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
;~ 		Local $aPathSplit =
		_PathSplit($sFileOpenDialog, $sDrive, $sDir, $sFileName, $sExtension)
		$sPathDir = $sDrive & $sDir
		$sFClientPath = $sPathDir & $sClientExe
		GUICtrlSetData($oinputgamedir, $sPathDir)
	EndIf
EndFunc   ;==>_BrowseGamePath

Func _CreateProcess($sFClientPath)
	Local $acall
	Local Const $CREATE_SUSPENDED = 0x00000004
	Local $tSTARTUPINFO = DllStructCreate("dword  cbSize;ptr Reserved;ptr Desktop;ptr Title;dword X;dword Y;dword XSize;dword YSize;dword XCountChars;dword YCountChars;dword FillAttribute;dword Flags;ushort ShowWindow;ushort Reserved2;ptr Reserved2;ptr hStdInput;ptr hStdOutput;ptr hStdError")
	Local $tPROCESS_INFORMATION = DllStructCreate("ptr Process;ptr Thread;dword ProcessId;dword ThreadId")

	$acall = DllCall("kernel32.dll", "bool", "CreateProcessW", "wstr", $sFClientPath, "wstr", '"' & $sFClientPath & '"' & " EntwellNostaleClient", "ptr", 0, "ptr", 0, "bool", 0, "dword", $CREATE_SUSPENDED, "ptr", 0, "wstr", $sPathDir, "ptr", DllStructGetPtr($tSTARTUPINFO), "ptr", DllStructGetPtr($tPROCESS_INFORMATION))

	If ($acall[0] <> 0) And (Not @error) Then Return $tPROCESS_INFORMATION ;DllStructGetData($tPROCESS_INFORMATION, "Thread")
	Return -1
EndFunc   ;==>_CreateProcess

Func _display()
	_updatedisplay($oprogresshp, _pointer("HP") * 100 / _pointer("MAXHP"))
	_updatedisplay($oprogressmp, _pointer("MP") * 100 / _pointer("MAXMP"))
	_updatedisplay($olabellevel, _pointer("Level"))
;~ 	GUICtrlSetData($oprogressexp, _pointer("EXP"))
	_updatedisplay($olabelgold, _pointer("Gold"))
	_updatedisplay($oprogressnm1hp, _pointer("NM1HP"))
	_updatedisplay($oprogressnm2hp, _pointer("NM2HP"))
	_updatedisplay($oprogressmobhp, _pointer("SELECTHP"))
	If _pointer("NAME") <> $scharname Then
		_updatenametitle()
	EndIf
EndFunc   ;==>_display

Func _getcords($sdata)
	Local $aoffeset[1][2], $aoffset, $aoffsetxy
	$aoffeset[0][0] = 0
	$aoffeset[0][1] = 0
	$aoffset = StringSplit($sdata, @CRLF, 1)

	For $i = 1 To $aoffset[0]
		ReDim $aoffeset[UBound($aoffeset) + 1][2]
		$aoffsetxy = StringSplit($aoffset[$i], ",", 1)
		$aoffeset[UBound($aoffeset) - 1][0] = Int($aoffsetxy[1])
		$aoffeset[UBound($aoffeset) - 1][1] = Int($aoffsetxy[2])
	Next
	Return $aoffeset
EndFunc   ;==>_getcords

Func _INJECTDLL($PROCESSID, $DLLPATH)
	Local $KERNEL32, $DLL_PATH, $HPROCESS, $HMODULE, $LPSTARTADDRESS, $LPPARAMETER;~, $hThread

	If $PROCESSID == 0 Then Return SetError(1, "", False)
	If Not (FileExists($DLLPATH)) Then Return SetError(2, "", False)
	If Not (StringRight($DLLPATH, 4) == ".dll") Then Return SetError(3, "", False)
	$KERNEL32 = DllOpen("kernel32.dll")
	If @error Then Return SetError(4, "", False)
	$DLL_PATH = DllStructCreate("char[255]")
	DllCall($KERNEL32, "DWORD", "GetFullPathNameA", "str", $DLLPATH, "DWORD", 255, "ptr", DllStructGetPtr($DLL_PATH), "int", 0)
	If @error Then Return SetError(5, "", False)
	$HPROCESS = DllCall($KERNEL32, "DWORD", "OpenProcess", "DWORD", 2035711, "int", 0, "DWORD", $PROCESSID)
	If @error Then Return SetError(6, "", False)
	$HMODULE = DllCall($KERNEL32, "DWORD", "GetModuleHandleA", "str", "kernel32.dll")
	If @error Then Return SetError(7, "", False)
	$LPSTARTADDRESS = DllCall($KERNEL32, "DWORD", "GetProcAddress", "DWORD", $HMODULE[0], "str", "LoadLibraryA")
	If @error Then Return SetError(8, "", False)
	$LPPARAMETER = DllCall($KERNEL32, "DWORD", "VirtualAllocEx", "int", $HPROCESS[0], "int", 0, "ULONG_PTR", DllStructGetSize($DLL_PATH), "DWORD", 12288, "int", 4)
	If @error Then Return SetError(9, "", False)
	DllCall("kernel32.dll", "BOOL", "WriteProcessMemory", "int", $HPROCESS[0], "DWORD", $LPPARAMETER[0], "str", DllStructGetData($DLL_PATH, 1), "ULONG_PTR", DllStructGetSize($DLL_PATH), "int", 0)
	If @error Then Return SetError(10, "", False)
;~$hThread =
	DllCall($KERNEL32, "int", "CreateRemoteThread", "DWORD", $HPROCESS[0], "int", 0, "int", 0, "DWORD", $LPSTARTADDRESS[0], "DWORD", $LPPARAMETER[0], "int", 0, "int", 0)
	If @error Then Return SetError(11, "", False)
	DllCall($KERNEL32, "BOOL", "CloseHandle", "DWORD", $HPROCESS[0])
	DllClose($KERNEL32)
	Return SetError(0, "", True)
EndFunc   ;==>_INJECTDLL

Func _pointer($pointer, $pointerno = 0)
	Local $areadmemory[2]
	Switch $pointer
		Case "HP"
			$areadmemory = _memorypointerread($ihpaddress, $ahmemomopen, $ahpoffset, "dword")
		Case "MP"
			$areadmemory = _memorypointerread($impaddress, $ahmemomopen, $ampoffset, "dword")
		Case "Level"
			$areadmemory = _memorypointerread($ileveladdress, $ahmemomopen, $aleveloffset, "dword")
		Case "MAXHP"
			$areadmemory = _memorypointerread($imaxhpaddress, $ahmemomopen, $amaxhpoffset, "dword")
		Case "MAXMP"
			$areadmemory = _memorypointerread($imaxmpaddress, $ahmemomopen, $amaxmpoffset, "dword")
;~ 		Case "EXP"
;~ 			$areadmemory = _memorypointerread($iexpaddress, $ahmemomopen, $aexpoffset, "dword")
		Case "GOLD"
			$areadmemory = _memorypointerread($igoldaddress, $ahmemomopen, $agoldoffset, "dword")
		Case "SELECT"
			$areadmemory = _memorypointerread($iselectaddress, $ahmemomopen, $aselectoffset, "dword")
		Case "SELECTHP"
			$areadmemory = _memorypointerread($iselecthpaddress, $ahmemomopen, $aselecthpoffset, "dword")
		Case "NM1HP"
			$areadmemory = _memorypointerread($inm1hpaddress, $ahmemomopen, $anm1hpoffset, "dword")
		Case "NM2HP"
			$areadmemory = _memorypointerread($inm2hpaddress, $ahmemomopen, $anm2hpoffset, "dword")
		Case "NAME"
			$areadmemory = _memorypointerread($inameaddress, $ahmemomopen, $anameoffset, "char[30]")
		Case "MACROENABLE"
			$areadmemory = _memorypointerread($imacrobarenableaddress, $ahmemomopen, $amacrobarenableoffset[$pointerno], "int")
		Case "SIT"
			$areadmemory = _memorypointerread($isitaddress, $ahmemomopen, $asitoffset, "byte")
		Case "ATTACKTYPE"
			$areadmemory = _memorypointerread($iattacktypeadress, $ahmemomopen, $aattacktypeoffset, "byte")
		Case "CHATPANEL"
			$areadmemory = _memorypointerread($ichatpaneladress, $ahmemomopen, $achatpaneloffset, "byte")
	EndSwitch
	Return $areadmemory[1]
EndFunc   ;==>_pointer

Func _ResumeThread($hThread)
	Local $acall
	$acall = DllCall("kernel32.dll", "dword", "ResumeThread", "handle", $hThread)
	If ($acall[0] <> -1) And (Not @error) Then Return $acall[0]
	Return -1
EndFunc   ;==>_ResumeThread

Func _runclient()
	$hProcInfo = _CreateProcess($sFClientPath)
	$hProc = DllStructGetData($hProcInfo, "Thread")
	$hProcPid = DllStructGetData($hProcInfo, "ProcessId")

	Local $ahnewmemomopen = _memoryopen($hProcPid)

	Local Const $multistart_pattern = "\x55\x68\x00\x00\x00\x00\x64\xFF\x30\x64\x89\x20\x68\x00\x00\x00\x00\x6A\xFF\x6A\x00\xE8\x00\x00\x00\x00"
	Local Const $multistart_mask = "xx????xxxxxxx????xxxxx????"
	Local Const $multistart_offset = 0x0C
	Local $multistarta = $multistart_offset + _memoryscanex($ahnewmemomopen, $multistart_pattern, $multistart_mask)

	Local Const $multiend_pattern = "\x8B\x06\xBA\x00\x00\x00\x00\xE8\x00\x00\x00\x00\x8B\x06\x8B\x80\x00\x00\x00\x00\xE8\x00\x00\x00\x00"
	Local Const $multiend_mask = "xxx????x????xxxx????x????"
	Local Const $multiend_offset = 0x00
	Local $multienda = $multiend_offset + _memoryscanex($ahnewmemomopen, $multiend_pattern, $multiend_mask)
	Local $patchdata = "EB " & Hex(Int($multienda - $multistarta - 2), 2) & "90 90 90"
	_memoryasmwrite($multistarta, $patchdata, $ahnewmemomopen)
	_memoryclose($hProcPid)
	_ResumeThread($hProc)

	_WaitForSingleObject($hProc, 3000)
EndFunc   ;==>_runclient

Func _updatedisplay($ocontrol, $value)
	Local $tmpval = GUICtrlRead($ocontrol)
	If $value <> $tmpval Then
		GUICtrlSetData($ocontrol, $value)
	EndIf
EndFunc   ;==>_updatedisplay

Func _updatenametitle()
	$scharname = _pointer("NAME")
	If $scharname == "" Then
		$fstart = False
		$fstate = "Klient Sonlandı"
		GUICtrlSetData($obuttonstart, "Başlat")
	EndIf
	If $scharname == "Entwell" Then
		$fstart = False
		$fstate = "Bağlantı Bekleniyor"
		GUICtrlSetData($obuttonstart, "Başlat")
	EndIf
	GUICtrlSetData($ointputcharname, $scharname)
	WinSetTitle($hgui, "", "WildNosBot - " & $scharname & " - " & $fstate)
	TraySetToolTip("WildNosBot - " & $scharname & " - " & $fstate)
EndFunc   ;==>_updatenametitle

Func _WaitForSingleObject($hHandle, $dwMilliseconds)
	Local $acall
	$acall = DllCall("kernel32.dll", "dword", "WaitForSingleObject", "handle", $hHandle, "dword", $dwMilliseconds)
	If ($acall[0] <> 0xFFFFFFFF) And (Not @error) Then Return $acall[0]
	Return -1
EndFunc   ;==>_WaitForSingleObject

Func drawgraph()

	;Local $xcoordinate[6] = [1, 10, 40, 40, 10, 20]
	;Local $ycoordinate[6] = [1, 10, 10, 40, 40, 20]
	Local $xycoordinate = _getcords(GUICtrlRead($oeditwaypoint))
	;_ArrayDisplay($xycoordinate)

	Local $width = 146
	Local $height = 146
	Local $top = 0
	Local $left = 0

	;Declare values of the first waypoint - just for a static reference
	Local $minX = $xycoordinate[1][0]
	Local $maxX = $xycoordinate[1][0]
	Local $minY = $xycoordinate[1][1]
	Local $maxY = $xycoordinate[1][1]

	;Find the absolute minimum and maximum values stored in your arrays
	For $m = 1 To (UBound($xycoordinate, 1) - 1) ;will loop through the coordinates to the total number actually stored
		Local $xcoord1 = $xycoordinate[$m][0]
		Local $ycoord1 = $xycoordinate[$m][1]
		If $xcoord1 < $minX Then $minX = $xcoord1
		If $xcoord1 > $maxX Then $maxX = $xcoord1
		If $ycoord1 < $minY Then $minY = $ycoord1
		If $ycoord1 > $maxY Then $maxY = $ycoord1
	Next
	;Now $min/$max values are correctly set as they only got changed if there was a waypoint larger/smaller respectively.

	;This part 'fits' the data into the size of your Graphic Control
	$maxX = $maxX - $minX
	$maxY = $maxY - $minY
	$minX = $minX / $maxX * $width
	$minY = $minY / $maxY * $height

	;Draw the Graphic Item
	GUICtrlDelete($ographicwaypoint)

	$ographicwaypoint = GUICtrlCreateGraphic($left, $top, $width, $height)
	GUICtrlSetBkColor(-1, 0xFFDEAD)
	Local $y1 = 15
	Do
		GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xF5F5F5) ; waagrecht
		GUICtrlSetGraphic(-1, $GUI_GR_MOVE, 5, $y1)
		GUICtrlSetGraphic(-1, $GUI_GR_LINE, $width - 5, $y1)
		$y1 = ($y1 + 15)
	Until $y1 > $height ; Gitter
	Local $x1 = 15
	Do
		GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xF5F5F5) ; senkrecht
		GUICtrlSetGraphic(-1, $GUI_GR_MOVE, $x1, 5)
		GUICtrlSetGraphic(-1, $GUI_GR_LINE, $x1, $height - 5)
		$x1 = ($x1 + 15)
	Until $x1 > $width ; Gitter

	;Calculate where it is in relation to the maximum & minimum totals
	Local $xcoor = $xycoordinate[1][0] / $maxX * $width
	$xcoor = $xcoor - $minX
	Local $ycoor = $xycoordinate[1][1] / $maxY * $height
	$ycoor = $ycoor - $minY

	;Set the graphic to the calculated location ^ & pen the waypoint
	GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_COLOR, 0x000000) ;You can change this if you want to be creative ;)
	GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_MOVE, $xcoor, $ycoor)

	;Cylcle through waypoints, drawing them
	For $z = 1 To (UBound($xycoordinate, 1) - 1)

		;Calculate where it is in relation to the maximum & minimum totals
		$xcoor = $xycoordinate[$z][0] / $maxX * $width
		$xcoor = $xcoor - $minX
		$ycoor = $xycoordinate[$z][1] / $maxY * $height
		$ycoor = $ycoor - $minY

		;Set the graphic to the calculated location ^ & pen the waypoint
		GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_COLOR, 0x000000) ;You can change this if you want to be creative ;)
		GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_dot, $xcoor, $ycoor)
		GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_LINE, $xcoor, $ycoor)
	Next

	;Calculate where it is in relation to the maximum & minimum totals
	$xcoor = $xycoordinate[1][0] / $maxX * $width
	$xcoor = $xcoor - $minX
	$ycoor = $xycoordinate[1][1] / $maxY * $height
	$ycoor = $ycoor - $minY

	;Set the graphic to the calculated location ^ & pen the waypoint
	GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_COLOR, 0x000000) ;You can change this if you want to be creative ;)
	GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_LINE, $xcoor, $ycoor)
	GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_dot, $xcoor, $ycoor)

	;All waypoints drawn - now will refresh the graphic & remove the pen
	GUICtrlSetGraphic($ographicwaypoint, $GUI_GR_refresh, $xcoor, $ycoor)
EndFunc   ;==>drawgraph
