; // ==================================
; // render_command.inc
; // ----------------------------------
; // A render command is meant to be compiled into
; // a list of commands and passed to the renderer
; // which will decide how exactly to render all of
; // the commands passed to it.
; // ==================================

IFNDEF RENDERER_COMMAND_INC
RENDERER_COMMAND_INC EQU 1

INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE sprite_component.inc

RenderCommand STRUCT
	; // Pointer to the transform that describes where the object should be rendered
	pTransform DWORD ?

	; // Pointer to the RenderableComponent subclass
	pRenderable DWORD ?
RenderCommand ENDS

; // Constructor methods
init_render_command PROTO pTransform : DWORD, pRenderable : DWORD
new_render_command PROTO pTransform: DWORD, pRenderable: DWORD
free_render_command PROTO

ENDIF
