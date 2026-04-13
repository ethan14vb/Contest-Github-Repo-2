; // ==================================
; // graph_win.inc
; // ----------------------------------
; // My version of GraphWin.inc from the Irvine library
; // ==================================

IFNDEF GRAPH_WIN_INC
GRAPH_WIN_INC EQU 1

INCLUDE heap_functions.inc

; // ********************************
; // Types
; // ********************************

UINT		TYPEDEF DWORD
WNDPROC		TYPEDEF DWORD
HINSTANCE	TYPEDEF HANDLE
HICON		TYPEDEF HANDLE
HCURSOR		TYPEDEF HANDLE
HBRUSH		TYPEDEF HANDLE
LPCSTR		TYPEDEF PTR BYTE
HWND		TYPEDEF HANDLE
WPARAM		TYPEDEF DWORD
LPARAM		TYPEDEF DWORD

; // ********************************
; // Structs
; // ********************************
POINT STRUCT
  X   DWORD ?
  Y   DWORD ?
POINT ENDS

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-msg
MSG STRUCT
	hwnd		HWND	?
	message		UINT	?
	wParam		WPARAM	?
	lparam		LPARAM	?
	time		DWORD	?
	pt			POINT	<>
MSG ENDS

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
WNDCLASSEXA STRUCT
	cbSize			UINT		?
	style			UINT		?
	lpfnWndProc		WNDPROC		?
	cbClsExtra		DWORD		?
	cbWndExtra		DWORD		?
	hInstance		HINSTANCE	?
	hIcon			HICON		?
	hCursor			HCURSOR		?
	hbrBackground	HBRUSH		?
	lpszMenuName	LPCSTR		?	
	lpszClassName	LPCSTR		?
	hIconSm			HICON		?
WNDCLASSEXA ENDS
WNDCLASSEX TEXTEQU <WNDCLASSEXA>

; // ********************************
; // Protos
; // ********************************
GetModuleHandleA PROTO, pString:PTR BYTE
GetModuleHandle TEXTEQU <GetModuleHandleA>

RegisterClassExA PROTO, pWndClass :PTR WNDCLASSEX
RegisterClassEx TEXTEQU <RegisterClassExA>

ENDIF