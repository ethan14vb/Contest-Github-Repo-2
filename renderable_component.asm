; // ==================================
; // renderable_component.asm
; // ----------------------------------
; // A subclass of component that provides
; // fields for the RenderableComponents which
; // are RectComponents and SpriteComponents
; // ==================================

INCLUDE default_header.inc
INCLUDE renderable_component.inc
INCLUDE component_ids.inc
INCLUDE heap_functions.inc

.code
; // ----------------------------------
; // init_renderable_component
; // Initializes memory with the contents of a RenderableComponent
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_renderable_component PROC PUBLIC USES esi, visible : DWORD, layer : DWORD
	; // Parent constructor
	INVOKE init_component
	mov (Component PTR [ecx]).componentType, RENDERABLE_COMPONENT_ID

	; // Height & Width
	mov esi, visible
	mov (RenderableComponent PTR [ecx]).visible, esi
	mov esi, layer
	mov (RenderableComponent PTR [ecx]).layer, esi

	mov eax, ecx
	ret
init_renderable_component ENDP

END 
