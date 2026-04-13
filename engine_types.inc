; // ==================================
; // engine_types.inc
; // ----------------------------------
; // Misc types used throughout the engine. This file is old and
; // nonspecific and will be replaced by more specific header
; // files in the future. 
; // ==================================

IFNDEF ENGINE_TYPES_INC
ENGINE_TYPES_INC EQU 1

GAME_WIDTH = 80
GAME_HEIGHT = 50

Pixel STRUCT
    r BYTE ?
    g BYTE ?
    b BYTE ?
    a BYTE ?
Pixel ENDS

ENDIF
