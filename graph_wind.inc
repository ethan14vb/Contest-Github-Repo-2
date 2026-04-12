; // ==================================
; // graph_win.inc
; // ----------------------------------
; // My version of GraphWin.inc from the Irvine library that
; // doesn't rename windows function protos.
; // ==================================

IFNDEF GRAPH_WIN_INC
GRAPH_WIN_INC EQU 1

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
WNDCLASSEXA STRUCT
	cbSize DWORD ?
	; // More members coming next commit
ENDS

ENDIF