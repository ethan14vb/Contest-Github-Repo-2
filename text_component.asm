; // ==================================
; // TextComponent
; // ----------------------------------
; // Defines how text should appear on the screen.
; // ==================================

INCLUDE default_header.inc
INCLUDE text_component.inc
INCLUDE heap_functions.inc

.data
TEXT_COMPONENT_VTABLE Component_vtable <OFFSET free_text_component>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_text_component
; // Initializes memory with the contents of a TextComponent
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_text_component PROC PUBLIC USES ebx ecx edx esi, pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD
	local pThis
	; // Parent constructor
	INVOKE init_renderable_component, 0FFFFFFFFh, 4
	mov (Component PTR [ecx]).componentType, TEXT_COMPONENT_ID
	mov (Component PTR [ecx]).pVt, OFFSET TEXT_COMPONENT_VTABLE

	mov pThis, ecx
	mov esi, pFontTexture
	mov (TextComponent PTR [ecx]).pFontTexture, esi
	mov esi, charW
	mov (TextComponent PTR [ecx]).charW, esi
	mov esi, charH
	mov (TextComponent PTR [ecx]).charH, esi
	mov esi, spacing
	mov (TextComponent PTR [ecx]).spacing, esi
	mov esi, maxChars
	mov (TextComponent PTR [ecx]).textMaxLen, esi

	mov (TextComponent PTR [ecx]).offsetX, 0
	mov (TextComponent PTR [ecx]).offsetY, 0
		
	mov eax, maxChars
	inc eax
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, eax
	mov ecx, pThis
	mov (TextComponent PTR [ecx]).pText, eax

	mov eax, ecx

	ret
init_text_component ENDP

; // ----------------------------------
; // new_text_component
; // Allocates memory for a TextComponent and then calls
; // the initializer method on it.
; // ----------------------------------
new_text_component PROC PUBLIC USES ebx ecx esi, pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TextComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_text_component, pFontTexture, charW, charH, spacing, maxChars

	ret ; // Return with the address of the memory block in HeapAlloc
new_text_component ENDP

; // ----------------------------------
; // free_text_component
; // Destructs the TextComponent and frees it
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_text_component PROC PUBLIC USES ebx ecx edx esi edi
	local pThis
	mov pThis, ecx
	
	mov edi, (TextComponent PTR [ecx]).pText
	INVOKE HeapFree, hHeap, 0, edi
	INVOKE HeapFree, hHeap, 0, pThis

	ret
free_text_component ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // set_text_component_text
; // Copies a string into the text component's string buffer.
; // There a few laws about this function.
; //
; // Law 1: Thou shalt not pass in a string that is not null terminated
; // Law 2: Thou shalt not pass in a string that is larger than the buffer.
; //
; // If you do not abide by these laws, may God have mercy upon your heap.
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
set_text_component_text PROC PUBLIC USES ebx ecx edx esi edi, pText: DWORD
	mov edi, (TextComponent PTR [ecx]).pText
	mov esi, pText

	test esi, esi
	jz set_text_component_text_need_null

set_text_component_text_copy_loop:
	mov al, BYTE PTR [esi]

	; // Write the byte to the destination
	mov BYTE PTR [edi], al

	; // Check for a null terminator
	test al, al
	jz set_text_component_text_exit

	inc esi
	inc edi
	jmp set_text_component_text_copy_loop

set_text_component_text_need_null:
	; // In case we were passed a null pointer
	mov BYTE PTR [edi], 0

set_text_component_text_exit:
	ret
set_text_component_text ENDP

END