; // ==================================
; // main.asm
; // ----------------------------------
; // The entry point of the program.
; // main.asm is responsible for updating the currently running scene 
; // and the inialization of the engine.
; // ==================================

INCLUDE default_header.inc
INCLUDE sprite_test_scene.inc
INCLUDE resource_manager.inc
INCLUDE engine_types.inc
INCLUDE scene.inc
INCLUDE graph_wind.inc

; // Irvine32 protos
Randomize PROTO

; // Win32 protos
ExitProcess PROTO : DWORD
Sleep		PROTO : DWORD ; // This function was added because it is the Win32 method of waiting for a specified number of miliseconds

.data
EXTERNDEF pTex : DWORD
EXTERNDEF pSworTex : DWORD
EXTERNDEF pArchTex : DWORD
EXTERNDEF pHeavTex : DWORD
EXTERNDEF pFontTex : DWORD
EXTERNDEF pCastleTex : DWORD
EXTERNDEF pBackgroundTex : DWORD

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
	mov eax, uMsg
	.IF eax == WM_DESTROY
		INVOKE PostQuitMessage, 0
		xor eax, eax
		jmp WndProc_exit
	.ELSE
		INVOKE DefWindowProc, hWin, uMsg, wParam, lParam
	.ENDIF

WndProc_exit:
	ret
WndProc ENDP

WinMain PROC PUBLIC
	local pScene

	; // Engine initialization
	INVOKE Randomize
	INVOKE initialize_heap
	INVOKE SetProcessDPIAware

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

	INVOKE GetStockObject, BLACK_BRUSH
	mov wc.hbrBackground, eax
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, OFFSET ClassName
    mov wc.hIcon, 0
    mov wc.hIconSm, 0

	INVOKE LoadCursor, 0, IDC_ARROW
    mov wc.hCursor, eax
	
	INVOKE RegisterClassEx, ADDR wc

	INVOKE GetSystemMetrics, SM_CXSCREEN
    mov ecx, eax
	push ecx
    INVOKE GetSystemMetrics, SM_CYSCREEN
    mov edx, eax
	pop ecx

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
	
	INVOKE populate_sprite_test_scene, pScene

loop_start:
	; // First, read the message queue and dispatch messages
read_msgs:
	INVOKE PeekMessage, ADDR msg, 0, 0, 0, PM_REMOVE
	test eax, eax
	jz update_scene ; // If PeakMessage returns 0, then there are no messages remaining in the queue

	cmp msg.message, WM_QUIT
	je loop_exit

	INVOKE TranslateMessage, ADDR msg
	INVOKE DispatchMessage, ADDR msg
	jmp read_msgs

update_scene:
	mov ecx, pScene
	INVOKE scene_update, deltaTime, hWnd

	INVOKE Sleep, 16 ; // Sleep for 1/60 seconds
	jmp loop_start

loop_exit:
	INVOKE free_scene
	INVOKE unload_texture, pTex
	INVOKE unload_texture, pSworTex
	INVOKE unload_texture, pArchTex
	INVOKE unload_texture, pHeavTex
	INVOKE unload_texture, pFontTex
	INVOKE unload_texture, pCastleTex
	INVOKE unload_texture, pBackgroundTex

	INVOKE ExitProcess, 0
	ret
WinMain ENDP

END WinMain
