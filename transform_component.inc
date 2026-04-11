; // ==================================
; // TransformComponent
; // ----------------------------------
; // Defines where in space a GameObject should be
; // represented.
; // ==================================

IFNDEF TRANSFORM_COMPONENT_INC
TRANSFORM_COMPONENT_INC EQU 1

INCLUDE component.inc

TransformComponent STRUCT
	baseComponent Component <>

	x SDWORD ?
	y SDWORD ?

	; // Whether to ignore the camera offset when rendering.
	; // Used for drawing UI items
	ignoreCamera DWORD ?

	; // Out of scope for this project
	; // rotation DWORD ?
	; // scaleX DWORD ?
	; // scaleY DWORD ?
TransformComponent ENDS

; // Constructor methods
init_transform_component PROTO x: DWORD, y : DWORD, ignoreCamera : DWORD
new_transform_component PROTO x: DWORD, y: DWORD, ignoreCamera: DWORD
free_transform_component PROTO

ENDIF
