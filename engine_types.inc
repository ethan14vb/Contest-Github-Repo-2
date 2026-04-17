; // ==================================
; // engine_types.inc
; // ----------------------------------
; // Misc types used throughout the engine. This file is old and
; // nonspecific and will be replaced by more specific header
; // files in the future. 
; // ==================================

IFNDEF ENGINE_TYPES_INC
ENGINE_TYPES_INC EQU 1

GAME_WIDTH = 1920
GAME_HEIGHT = 1080

Pixel STRUCT
    r BYTE ?
    g BYTE ?
    b BYTE ?
    a BYTE ?
Pixel ENDS

ENDIF
