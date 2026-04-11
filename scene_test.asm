; // ==================================
; // scene_test.asm
; // ----------------------------------
; // Tests if scenes can be created and initialized
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE scene.inc

ExitProcess PROTO STDCALL : DWORD

.code
main PROC PUBLIC
	local pScene

	INVOKE initialize_heap

	INVOKE new_scene, 5
	mov pScene, eax
	mov ecx, eax

	INVOKE free_scene

	INVOKE ExitProcess, 0
	ret
main ENDP

END main