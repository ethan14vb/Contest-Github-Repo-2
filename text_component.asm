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
init_text_component PROC PUBLIC USES ebx ecx edx esi, pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD
	local pThis
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

	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, maxChars + 1
	mov ecx, pThis
	mov (TextComponent PTR [ecx]).pText, eax

	mov eax, ecx

	ret
init_text_component ENDP

new_text_component PROC PUBLIC USES ebx ecx esi, pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TextComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_text_component, pFontTexture, charW, charH, spacing, maxChars

	ret ; // Return with the address of the memory block in HeapAlloc
new_text_component ENDP

free_text_component PROC PUBLIC USES ebx ecx edx esi edi
	local pThis
	mov pThis, ecx
	
	mov edi, (TextComponent PTR [ecx]).pText
	INVOKE HeapFree, hHeap, 0, edi
	INVOKE HeapFree, hHeap, 0, pThis

	ret
free_text_component ENDP

END