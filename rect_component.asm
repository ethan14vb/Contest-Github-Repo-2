; // ==================================
; // RectComponent
; // ----------------------------------
; // Defines how a GameObject should appear using a rectangle.
; // Should be used with a transform for proper functionality.
; // The origin is defined by a transform.
; // ==================================

INCLUDE default_header.inc
INCLUDE rect_component.inc
INCLUDE heap_functions.inc

.code
; // ----------------------------------
; // init_rect_component
; // Initializes memory with the contents of a RectComponent
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_rect_component PROC PUBLIC USES ebx esi, h: DWORD, w : DWORD, r : BYTE, g : BYTE, b : BYTE, a : BYTE
	; // Parent constructor
	INVOKE init_renderable_component, 0FFFFFFFFh, 1
	mov (Component PTR [ecx]).componentType, RECT_COMPONENT_ID

	; // Height & Width
	mov esi, h
	mov (RectComponent PTR [ecx]).h, esi
	mov esi, w
	mov (RectComponent PTR [ecx]).w, esi

	; // RGBA
	mov bl, r
	mov (RectComponent PTR [ecx]).r, bl
	mov bl, g
	mov (RectComponent PTR [ecx]).g, bl
	mov bl, b
	mov (RectComponent PTR [ecx]).b, bl
	mov bl, a
	mov (RectComponent PTR [ecx]).a, bl

	mov eax, ecx
	ret
init_rect_component ENDP

; // ----------------------------------
; // new_rect_component
; // Allocates memory for a RectComponent and then calls
; // the initializer method on it.
; // ----------------------------------
new_rect_component PROC PUBLIC USES ebx ecx esi, h: DWORD, w : DWORD, r : BYTE, g : BYTE, b : BYTE, a : BYTE
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF RectComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_rect_component, h, w, r, g, b, a

	ret ; // Return with the address of the memory block in HeapAlloc
new_rect_component ENDP

END 
