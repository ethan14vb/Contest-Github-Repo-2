; // ==================================
; // TextComponent
; // ----------------------------------
; // Defines how text should appear on the screen.
; // ==================================

IFNDEF TEXT_COMPONENT_INC
TEXT_COMPONENT_INC EQU 1

INCLUDE renderable_component.inc

TextComponent STRUCT
	baseRenderableComponent RenderableComponent <>

	pFontTexture	DWORD ?
	pText			DWORD ?
	textMaxLen		DWORD ?

	; // Info about the dimensions of the characters in the texture
	charW			DWORD ?
	charH			DWORD ?

	; // Extra format info
	spacing			DWORD ?
TextComponent ENDS

init_text_component PROTO pFontTexture:DWORD, charW: DWORD, charH: DWORD, spacing: DWORD, maxChars:DWORD
new_text_component PROTO pFontTexture:DWORD, charW: DWORD, charH: DWORD, spacing: DWORD, maxChars:DWORD
set_text_component_text PROTO pText:DWORD

ENDIF
