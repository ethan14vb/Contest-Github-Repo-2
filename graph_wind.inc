; // ==================================
; // graph_win.inc
; // ----------------------------------
; // My version of GraphWin.inc from the Irvine library that
; // doesn't rename windows function protos.
; // ==================================

IFNDEF GRAPH_WIN_INC
GRAPH_WIN_INC EQU 1

INCLUDE heap_functions.inc

UINT		TYPEDEF DWORD
WNDPROC		TYPEDEF DWORD
HINSTANCE	TYPEDEF HANDLE
HICON		TYPEDEF HANDLE
HCURSOR		TYPEDEF HANDLE
HBRUSH		TYPEDEF HANDLE
LPCSTR		TYPEDEF PTR BYTE

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
WNDCLASSEXA STRUCT
	cbSize DWORD ?
	; // More members coming next commit
WNDCLASSEXA ENDS

ENDIF