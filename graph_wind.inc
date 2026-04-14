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

VOID		TYPEDEF DWORD
UINT		TYPEDEF DWORD
WNDPROC		TYPEDEF DWORD
HINSTANCE	TYPEDEF HANDLE
HICON		TYPEDEF HANDLE
HCURSOR		TYPEDEF HANDLE
HBRUSH		TYPEDEF HANDLE
LPCSTR		TYPEDEF PTR BYTE
LPMSG		TYPEDEF PTR MSG
LPVOID		TYPEDEF PTR VOID
HWND		TYPEDEF HANDLE
HMENU		TYPEDEF HANDLE
HDC			TYPEDEF HANDLE
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

LoadCursorA PROTO, hInstance:HINSTANCE, lpCursorName:LPCSTR
LoadCursor TEXTEQU <LoadCursorA>

CreateWindowExA PROTO, 
	exWinStyle:DWORD,
	lpClassName:LPCSTR,
	lpWindowName:LPCSTR,
	winStyle:DWORD,
	X:DWORD,
	Y:DWORD,
	nWidth:DWORD,
	nHeight:DWORD,
	hWndParent:HWND,
	hMenu:HMENU,
	hInstance:HINSTANCE,
	lpParam:LPVOID
CreateWindowEx TEXTEQU <CreateWindowExA>
	
; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
GetSystemMetrics PROTO nIndex:DWORD

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-peekmessagea
PeekMessageA PROTO, lpMsg:LPMSG, hWnd:HWND, wMsgFilterMin:UINT, wMsgFilterMax:UINT, wRemoveMsg:UINT
PeekMessage TEXTEQU <PeekMessageA>

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-translatemessage
TranslateMessage PROTO, lpMsg:LPMSG

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-dispatchmessage
DispatchMessageA PROTO, lpMsg:LPMSG
DispatchMessage TEXTEQU <DispatchMessageA>

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-defwindowproca
DefWindowProcA PROTO hWnd:HWND, Msg:UINT, wParam:WPARAM, lParam:LPARAM
DefWindowProc TEXTEQU <DefWindowProcA>

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-postquitmessage
PostQuitMessage PROTO nExitCode:DWORD

; // from learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getstockobject
GetStockObject PROTO i:DWORD

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdc
GetDC PROTO hWnd:HWND

; // from learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-releasedc
ReleaseDC PROTO hWnd:HWND, hDC:HDC

; // from learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-stretchdibits
StretchDIBits PROTO hdc:HDC, 
	xDest:DWORD,		yDest:DWORD, 
	DestWidth:DWORD,	DestHeight:DWORD, 
	xSrc:DWORD,			ySrc:DWORD, 
	SrcWidth:DWORD,		SrcHeight:DWORD, 
	lpBits:DWORD, 
	lpbmi:DWORD, 
	iUsage:DWORD, 
	rop:DWORD

; // ********************************
; // Constants
; // ********************************
BLACK_BRUSH			= 4

COLOR_WINDOW        = 5				; std window color
COLOR_BACKGROUND    = 2				; 2=blue F=gray
IDI_APPLICATION     = 32512			; application icon
IDC_ARROW           = 07f00h		; mouse cursor--arrow
CW_USEDEFAULT       = 80000000h		; default window size & position

PM_REMOVE			= 1

SM_CXSCREEN			= 0
SM_CYSCREEN			= 1

; Window Style Constants
WS_POPUP			= 80000000h
WS_VISIBLE			= 10000000h

WM_QUIT				= 12h
WM_DESTROY			= 0002h
WM_ERASEBKGND		= 0014h

ENDIF