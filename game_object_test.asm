; // ==================================
; // game_objects_test.asm
; // ----------------------------------
; // Tests if GameObjects can be created and freed
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE game_object.inc

ExitProcess PROTO STDCALL : DWORD

.code
main PROC PUBLIC
	local pGameObject

	INVOKE initialize_heap

	INVOKE new_game_object, 1
	mov pGameObject, eax

	INVOKE new_transform_component, 5, 10, 0
	INVOKE add_component, pGameObject, eax

	INVOKE new_rect_component, 6, 7, 255, 255, 9, 255
	INVOKE add_component, pGameObject, eax

	mov ecx, pGameObject
	INVOKE free_game_object

	INVOKE ExitProcess, 0
	ret
main ENDP

END main