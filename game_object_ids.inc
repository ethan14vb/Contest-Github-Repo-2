; // ==================================
; // game_object_ids.inc
; // ----------------------------------
; // A set of "enum" style macros that identify GameObject types 
; // for the data definition and parsing of a scene's data.
; //
; // This is necessary because GameObjects are designed to be
; // subclassed into new unique types of GameObjects defined
; // by the user of this engine.
; // ==================================

IFNDEF GAME_OBJECT_IDS_INC
GAME_OBJECT_IDS_INC EQU 1

; // A helper function to make defining a bunch of enums smoother
enumId = 0
DEF_ENUM MACRO enum_name
	enum_name = enumId
	enumId = enumId + 1
ENDM

ENUM_GAME_OBJECT_ID TYPEDEF DWORD

; // List of GameObject identifiers
DEF_ENUM DEFAULT_GAME_OBJECT_ID
DEF_ENUM CAMERA_MOVER_GAME_OBJECT_ID
DEF_ENUM NEON_SQUARE_PLAYER_GAME_OBJECT_ID
DEF_ENUM WALL_OBSTACLE_GAME_OBJECT_ID
DEF_ENUM NEON_GAME_MANAGER_GAME_OBJECT_ID
DEF_ENUM EXPLOSION_GAME_OBJECT_ID
DEF_ENUM BACKGROUND_RECT_GAME_OBJECT_ID

ENDIF