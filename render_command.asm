; // ==================================
; // render_command.asm
; // ----------------------------------
; // A render command is meant to be compiled into
; // a list of commands and passed to the renderer
; // which will decide how exactly to render all of
; // the commands passed to it.
; // ==================================

INCLUDE default_header.inc
INCLUDE render_command.inc
INCLUDE heap_functions.inc

.code
; // ----------------------------------
; // init_render_command
; // Initializes memory with the contents of a RenderCommand
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_render_command PROC PUBLIC USES esi, pTransform : DWORD, pRenderable : DWORD
	mov esi, pTransform
	mov (RenderCommand PTR [ecx]).pTransform, esi
	mov esi, pRenderable
	mov (RenderCommand PTR [ecx]).pRenderable, esi
	ret
init_render_command ENDP

new_render_command PROC PUBLIC USES ecx edx, pTransform: DWORD, pRenderable: DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF RenderCommand
	mov ecx, eax ; // Move the memory address to eax so it can function as a "this" pointer
	INVOKE init_render_command, pTransform, pRenderable

	ret ; // Return with the address of the memory block in HeapAlloc
new_render_command ENDP

free_render_command PROC PUBLIC USES ebx ecx edx esi edi
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_render_command ENDP

END
