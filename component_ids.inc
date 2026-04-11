; // ==================================
; // component_ids.inc
; // ----------------------------------
; // A set of "enum" style macros that identify component types 
; // for the data definition and parsing of a scene's data.
; // ==================================

IFNDEF COMPONENT_IDS_INC
COMPONENT_IDS_INC EQU 1

; // A helper function to make defining a bunch of enums smoother
enumId = 0
DEF_ENUM MACRO enum_name
	enum_name = enumId
	enumId = enumId + 1
ENDM

ENUM_COMPONENT_ID TYPEDEF DWORD

; // List of component identifiers
DEF_ENUM DEFAULT_COMPONENT_ID
DEF_ENUM RECT_COMPONENT_ID
DEF_ENUM SPRITE_COMPONENT_ID
DEF_ENUM TRANSFORM_COMPONENT_ID
DEF_ENUM RENDERABLE_COMPONENT_ID

ENDIF