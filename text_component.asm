; // ==================================
; // TextComponent
; // ----------------------------------
; // Defines how text should appear on the screen.
; // ==================================

INCLUDE default_header.inc
INCLUDE text_component.inc
INCLUDE heap_functions.inc

.code
init_text_component PROC PUBLIC USES ebx ecx esi, pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD, pText : DWORD
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
	mov esi, pText
	mov (TextComponent PTR [ecx]).pText, esi

	mov eax, ecx

	ret
init_text_component ENDP

new_text_component PROC PUBLIC USES ebx ecx esi, pFontTexture : DWORD, charW : DWORD, charH : DWORD, spacing : DWORD, maxChars : DWORD, pText : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TextComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_text_component, pFontTexture, charW, charH, spacing, maxChars, pText

	ret ; // Return with the address of the memory block in HeapAlloc
new_text_component ENDP

END