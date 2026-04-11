; // ==================================
; // rectangle_test_scene_test.asm
; // ----------------------------------
; // Tests the functionality of the rectangle test scene
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE rectangle_test_scene.inc
INCLUDE scene.inc

ExitProcess PROTO STDCALL : DWORD

.data
deltaTime REAL4 0.03333

.code
main PROC PUBLIC
	local pScene

	INVOKE initialize_heap

	INVOKE new_scene, 2
	mov pScene, eax
	
	INVOKE populate_rectangle_test_scene, pScene

	mov ecx, pScene
	INVOKE scene_update, deltaTime

	INVOKE free_scene

	INVOKE ExitProcess, 0
	ret
main ENDP

END main