; // ==================================
; // main.asm
; // ----------------------------------
; // The entry point of the program.
; // main.asm is responsible for updating the currently running scene 
; // and the inialization of the engine.
; // ==================================

INCLUDE default_header.inc
INCLUDE rectangle_test_scene.inc
INCLUDE scene.inc
INCLUDE graph_wind.inc

; // Irvine32 protos
Randomize PROTO

; // Win32 protos
ExitProcess PROTO : DWORD
Sleep		PROTO : DWORD ; // This function was added because it is the Win32 method of waiting for a specified number of miliseconds

.data
; // Engine data
deltaTime REAL4 0.016667

; // Window data
ClassName   BYTE "GameEngineClass", 0
WindowName  BYTE "Demo Game", 0

hInstance HINSTANCE		?
hWnd      HANDLE		?
wc        WNDCLASSEX	<>
msg       MSG           <>

.code
WndProc PROC PUBLIC, hWin : DWORD, uMsg : DWORD, wParam : DWORD, lParam : DWORD
	mov eax, hWin
	mov eax, uMsg
	mov eax, wParam
	mov eax, lParam
	ret
WndProc ENDP

WinMain PROC PUBLIC
	local pScene

	; // Engine initialization
	INVOKE Randomize
	INVOKE initialize_heap

	; // Window initialization
	INVOKE GetModuleHandle, 0
    mov hInstance, eax

	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, 0
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra, 0
	mov wc.cbWndExtra, 0

	mov eax, hInstance
    mov wc.hInstance, eax

	mov wc.hbrBackground, COLOR_WINDOW + 1
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, OFFSET ClassName
    mov wc.hIcon, 0
    mov wc.hIconSm, 0

	INVOKE LoadCursor, 0, IDC_ARROW
    mov wc.hCursor, eax
	
	INVOKE RegisterClassEx, ADDR wc

	INVOKE GetSystemMetrics, SM_CXSCREEN
    mov ecx, eax
    INVOKE GetSystemMetrics, SM_CYSCREEN
    mov edx, eax
		
	INVOKE CreateWindowEx, 
		0, 
		ADDR ClassName, 
		ADDR WindowName, 
		WS_POPUP OR WS_VISIBLE, 
		0, 
		0, 
		ecx, 
		edx, 
		0, 
		0, 
		hInstance, 
		0
    mov hWnd, eax

	; // Scene initialization
	INVOKE new_scene, 100
	mov pScene, eax
	
	INVOKE populate_rectangle_test_scene, pScene

loop_start:
	mov ecx, pScene
	INVOKE scene_update, deltaTime

	INVOKE Sleep, 16 ; // Sleep for 1/60 seconds
	jmp loop_start

loop_exit:
	INVOKE free_scene

	INVOKE ExitProcess, 0
	ret
WinMain ENDP

END WinMain
