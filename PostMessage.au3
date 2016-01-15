
Func _replacekey($key)
	$key = StringReplace($key, "{DELETE}", $vk_back)
	$key = StringReplace($key, "{TAB}", $vk_tab)
	$key = StringReplace($key, "{ENTER}", $vk_return)
	$key = StringReplace($key, "+", $vk_shift)
	$key = StringReplace($key, "{LSHIFT}", $vk_shift)
	$key = StringReplace($key, "{RSHIFT}", $vk_shift)
	$key = StringReplace($key, "^", $vk_control)
	$key = StringReplace($key, "{LCTRL}", $vk_control)
	$key = StringReplace($key, "{RCTRL}", $vk_control)
	$key = StringReplace($key, "!", $vk_menu)
	$key = StringReplace($key, "{LALT}", $vk_menu)
	$key = StringReplace($key, "{RALT}", $vk_menu)
	$key = StringReplace($key, "{PAUSE}", $vk_pause)
	$key = StringReplace($key, "{CAPSLOCK}", $vk_capital)
	$key = StringReplace($key, "{CAPSLOCK ON}", $vk_capital)
	$key = StringReplace($key, "{CAPSLOCK OFF}", $vk_capital)
	$key = StringReplace($key, "{CAPSLOCK TOGGLE}", $vk_capital)
	$key = StringReplace($key, "{ESCAPE}", $vk_escape)
	$key = StringReplace($key, "{SPACE}", $vk_space)
	$key = StringReplace($key, "{PGUP}", $vk_prior)
	$key = StringReplace($key, "{PGDN}", $vk_next)
	$key = StringReplace($key, "{END}", $vk_end)
	$key = StringReplace($key, "{HOME}", $vk_home)
	$key = StringReplace($key, "{LEFT}", $vk_left)
	$key = StringReplace($key, "{UP}", $vk_up)
	$key = StringReplace($key, "{RIGHT}", $vk_right)
	$key = StringReplace($key, "{DOWN}", $vk_down)
	$key = StringReplace($key, "{PRINTSCREEN}", $vk_snapshot)
	$key = StringReplace($key, "{INSERT}", $vk_insert)
	$key = StringReplace($key, "{DELETE}", $vk_delete)
	$key = StringReplace($key, "{NUMPAD0}", $vk_numpad0)
	$key = StringReplace($key, "{NUMPAD1}", $vk_numpad1)
	$key = StringReplace($key, "{NUMPAD2}", $vk_numpad2)
	$key = StringReplace($key, "{NUMPAD3}", $vk_numpad3)
	$key = StringReplace($key, "{NUMPAD4}", $vk_numpad4)
	$key = StringReplace($key, "{NUMPAD5}", $vk_numpad5)
	$key = StringReplace($key, "{NUMPAD6}", $vk_numpad6)
	$key = StringReplace($key, "{NUMPAD7}", $vk_numpad7)
	$key = StringReplace($key, "{NUMPAD8}", $vk_numpad8)
	$key = StringReplace($key, "{NUMPAD9}", $vk_numpad9)
	$key = StringReplace($key, "{NUMPADMULT}", $vk_multiply)
	$key = StringReplace($key, "{NUMPADADD}", $vk_add)
	$key = StringReplace($key, "{NUMPADSUB}", $vk_subtract)
	$key = StringReplace($key, "{NUMPADDOT}", $vk_decimal)
	$key = StringReplace($key, "{NUMPADDIV}", $vk_divide)
	$key = StringReplace($key, "{F1}", $vk_f1)
	$key = StringReplace($key, "{F2}", $vk_f2)
	$key = StringReplace($key, "{F3}", $vk_f3)
	$key = StringReplace($key, "{F4}", $vk_f4)
	$key = StringReplace($key, "{F5}", $vk_f5)
	$key = StringReplace($key, "{F6}", $vk_f6)
	$key = StringReplace($key, "{F7}", $vk_f7)
	$key = StringReplace($key, "{F8}", $vk_f8)
	$key = StringReplace($key, "{F9}", $vk_f9)
	$key = StringReplace($key, "{F10}", $vk_f10)
	$key = StringReplace($key, "{F11}", $vk_f11)
	$key = StringReplace($key, "{F12}", $vk_f12)
	$key = StringReplace($key, "{NUMLOCK}", $vk_numlock)
	$key = StringReplace($key, "{NUMLOCK ON}", $vk_numlock)
	$key = StringReplace($key, "{NUMLOCK OFF}", $vk_numlock)
	$key = StringReplace($key, "{NUMLOCK TOGGLE}", $vk_numlock)
	$key = StringReplace($key, "{SCROLLLOCK}", $vk_scroll)
	$key = StringReplace($key, "{SCROLLLOCK ON}", $vk_scroll)
	$key = StringReplace($key, "{SCROLLLOCK OFF}", $vk_scroll)
	$key = StringReplace($key, "{SCROLLLOCK TOGGLE}", $vk_scroll)
	Return $key
EndFunc   ;==>_replacekey

Func _postmessage_send($hwnd, $key, $delay = 10)
	If StringLen($key) == 1 Then
		If $key == "+" Or $key == "^" Or $key == "!" Then
			SetError(1)
		Else
			$key = StringUpper($key)
			$key = StringToBinary($key)
		EndIf
	Else
		$key = _replacekey($key)
	EndIf
	Local $key_
	$key_ = DllCall("user32.dll", "int", "MapVirtualKey", "int", $key, "int", 0)
	If IsArray($key_) Then
		DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hwnd, "int", $wm_keydown, "int", $key, "long", _MakeLong(1, $key_[0]))
		Sleep($delay)
		DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hwnd, "int", $wm_keyup, "int", $key, "long", _MakeLong(1, $key_[0]) + -1073741824)
	Else
		SetError(2)
	EndIf
EndFunc   ;==>_postmessage_send

Func _postmessage_click($hwnd, $x = Default, $y = Default, $button = "left", $clicks = 1, $delay = 10)
	If $button == "left" Then
		$button = $wm_lbuttondown
	ElseIf $button == "right" Then
		$button = $wm_rbuttondown
	ElseIf $button == "middle" Then
		$button = $wm_mbuttondown
		If $delay < 100 Then $delay = 100
	EndIf
	Local $winsize
	$winsize = WinGetClientSize($hwnd)
	If $x == Default Then $x = $winsize[0] / 2
	If $y == Default Then $y = $winsize[1] / 2
	For $j = 1 To $clicks
		DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hwnd, "int", $button, "int", "0", "long", _MakeLong($x, $y))
		Sleep($delay)
		DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hwnd, "int", $button + 1, "int", "0", "long", _MakeLong($x, $y))
	Next
EndFunc   ;==>_postmessage_click

Func _MakeLong($LoDWORD, $HiDWORD)
	Return BitOR($HiDWORD * 0x10000, BitAND($LoDWORD, 0xFFFF))
EndFunc   ;==>_MakeLong
