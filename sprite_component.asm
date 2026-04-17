; // ==================================
; // SpriteComponent
; // ----------------------------------
; // Defines how a GameObject should appear using a texture.
; // Should be used with a transform for proper functionality.
; // ==================================

INCLUDE default_header.inc
INCLUDE sprite_component.inc
INCLUDE heap_functions.inc

.code
; // ----------------------------------
; // init_sprite_component
; // Initializes memory with the contents of a SpriteComponent
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_sprite_component PROC PUBLIC USES ebx esi, originX:DWORD, originY:DWORD, pTexture:DWORD
	; // Parent constructor
	INVOKE init_renderable_component, 0FFFFFFFFh, 1
	mov (Component PTR [ecx]).componentType, SPRITE_COMPONENT_ID

	; // Origin
	mov esi, originX
	mov (SpriteComponent PTR [ecx]).originX, esi
	mov esi, originY
	mov (SpriteComponent PTR [ecx]).originY, esi

	; // pTexture
	mov esi, pTexture
	mov (SpriteComponent PTR [ecx]).pTexture, esi

	; // Booleans
	mov (SpriteComponent PTR [ecx]).isCell, 0
	mov (SpriteComponent PTR [ecx]).flipX, 0
	mov (SpriteComponent PTR [ecx]).flipY, 0

	mov eax, ecx
	ret
init_sprite_component ENDP

; // ----------------------------------
; // new_sprite_component
; // Allocates memory for a SpriteComponent and then calls
; // the initializer method on it.
; // ----------------------------------
new_sprite_component PROC PUBLIC USES ebx ecx esi, originX:DWORD, originY : DWORD, pTexture : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF SpriteComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_sprite_component, originX, originY, pTexture

	ret ; // Return with the address of the memory block in HeapAlloc
new_sprite_component ENDP

END 
