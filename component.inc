; // ==================================
; // component.inc
; // ----------------------------------
; //	Components are utility helpers to GameObjects that
; // allow for easy adding of features and a composition
; // structure for them (HasA vs IsA). 
; //	Some examples of components are SpriteComponents
; // that describe what a GameObject should look like or
; // TransformComponents that describe where a GameObject
; // is located spatially. 
; //	This is the generic component STRUCT that
; // all components inherit from.
; // ==================================

IFNDEF COMPONENT_INC
COMPONENT_INC EQU 1

INCLUDE component_ids.inc

Component_vtable STRUCT
	pFree DWORD ?
Component_vtable ENDS

Component STRUCT
	componentType ENUM_COMPONENT_ID DEFAULT_COMPONENT_ID
	pVt DWORD ?
Component ENDS

; // Constructor protos
init_component PROTO
new_component PROTO
free_component PROTO
free_component_virtual PROTO

ENDIF