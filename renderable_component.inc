; // ==================================
; // renderable_component.inc
; // ----------------------------------
; // A subclass of component that provides
; // fields for the RenderableComponents which
; // are RectComponents and SpriteComponents
; // ==================================

IFNDEF RENDERABLE_COMPONENT_INC
RENDERABLE_COMPONENT_INC EQU 1

INCLUDE component.inc

RenderableComponent STRUCT
	baseComponent Component <>

	visible DWORD ?
	layer DWORD ?
RenderableComponent ENDS

; // Constructor protos
init_renderable_component PROTO visible : DWORD, layer : DWORD

ENDIF