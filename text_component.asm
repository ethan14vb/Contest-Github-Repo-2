; // ==================================
; // TextComponent
; // ----------------------------------
; // Defines how text should appear on the screen.
; // ==================================

INCLUDE default_header.inc
INCLUDE text_component.inc
INCLUDE heap_functions.inc

.code
init_text_component PROC pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD, pText : DWORD
	mov eax, pFontTexture
	mov eax, charW
	mov eax, charH
	mov eax, spacing
	mov eax, maxChars
	mov eax, pText
	ret
init_text_component ENDP

new_text_component PROC pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD, pText : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TextComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_text_component, pFontTexture, charW, charH, spacing, maxChars, pText

	ret ; // Return with the address of the memory block in HeapAlloc
new_text_component ENDP

END