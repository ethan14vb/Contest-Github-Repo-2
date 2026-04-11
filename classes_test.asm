; // ==================================
; // classes_test.asm
; // ----------------------------------
; // Tests if classes can be created and freed
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc

; // Classes
INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE render_command.inc

ExitProcess PROTO STDCALL : DWORD

.code
main PROC PUBLIC
	local pTrans: DWORD, pRect: DWORD, pRC

	INVOKE initialize_heap

	; // Create the classes
	INVOKE new_transform_component, 1, 2, 0
	mov pTrans, eax
	INVOKE new_rect_component, 5, 6, 255, 127, 56, 255
	mov pRect, eax
	INVOKE new_render_command, RC_RECT, pTrans, pRect
	mov pRC, eax

	; // do stuff with the classes
	mov edi, pTrans
	mov (TransformComponent PTR [edi]).x, 5
	mov edi, pRect
	mov (RectComponent PTR [edi]).a, 10
	mov edi, pRC
	mov (RenderCommand PTR [edi]).rcType, RC_SPRITE

	; // Free the classes
	mov ecx, pTrans
	INVOKE free_component_virtual

	mov ecx, pRect
	INVOKE free_component_virtual

	mov ecx, pRC
	INVOKE free_render_command, pRC

	INVOKE ExitProcess, 0
	ret
main ENDP

END main
