; // ==================================
; // main.asm
; // ----------------------------------
; // The entry point of the program.
; // main.asm is responsible for updating the currently running scene 
; // and the inialization of the engine.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE rectangle_test_scene.inc
INCLUDE scene.inc
INCLUDE graph_wind.inc

; // Irvine32 protos
Randomize PROTO

; // Win32 protos
ExitProcess PROTO : DWORD
Sleep		PROTO : DWORD ; // This function was added because it is the Win32 method of waiting for a specified number of miliseconds

.data
deltaTime REAL4 0.016667

.code
main PROC PUBLIC
	local pScene

	INVOKE Randomize
	INVOKE initialize_heap

	INVOKE new_scene, 100
	mov pScene, eax
	
	INVOKE populate_rectangle_test_scene, pScene

loop_start:
	mov ecx, pScene
	INVOKE scene_update, deltaTime

	INVOKE Sleep, 16 ; // Sleep for 1/60 seconds
	jmp loop_start

	INVOKE free_scene

	INVOKE ExitProcess, 0
	ret
main ENDP

END main
