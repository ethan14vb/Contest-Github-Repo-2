; // ==================================
; // SpriteComponent
; // ----------------------------------
; // Defines how a GameObject should appear using a texture.
; // Should be used with a transform for proper functionality.
; // ==================================

IFNDEF SPRITE_COMPONENT_INC
SPRITE_COMPONENT_INC EQU 1

INCLUDE renderable_component.inc

SpriteComponent STRUCT
	baseRenderableComponent RenderableComponent <>

	originX DWORD ?
	originY DWORD ?

	pTexture DWORD ?

	; // Info about where the sprite is in the source buffer. (If using spritesheet cell)
	cellX DWORD ?
	cellY DWORD ?
	cellW DWORD ?
	cellH DWORD ?

	; // *************************
	; // Booleans (Maybe later these can be compressed into flags to save space)
	; // *************************
	flipX DWORD ?
	flipY DWORD ? 
SpriteComponent ENDS

ENDIF
