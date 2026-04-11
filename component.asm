; // ==================================
; // component.asm
; // ----------------------------------
; //	Components are utility helpers to GameObjects that
; // allow for easy adding of features and a composition
; // structure for them (HasA vs IsA). 
; //	Some examples of components are SpriteComponents
; // that describe what a GameObject should look like or
; // TransformComponents that describe where a GameObject
; // is located spatially. 
; //	These are the generic component methods that
; // all components inherit from.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE component.inc

.data
COMPONENT_VTABLE Component_vtable <OFFSET free_component>

.code
init_component PROC PUBLIC USES esi
	mov (Component PTR [ecx]).componentType, DEFAULT_COMPONENT_ID
	mov (Component PTR [ecx]).pVt, OFFSET COMPONENT_VTABLE

	ret
init_component ENDP

new_component PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Component
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_component

	ret ; // Return with the address of the memory block in HeapAlloc
new_component ENDP

; // ecx stores the "this" pointer
free_component PROC PUBLIC
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_component ENDP

; // ----------------------------------
; // free_component_virtual
; // Calls the component's virtual free method
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_component_virtual PROC PUBLIC USES ebx
	mov ebx, (Component PTR [ecx]).pVt
	mov ebx, (Component_vtable PTR [ebx]).pFree
	call ebx
	ret
free_component_virtual ENDP

END