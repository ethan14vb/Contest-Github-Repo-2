; // ==================================
; // knight.inc
; // ----------------------------------
; // The knight is a subclass of GameObject that
; // defines basic behavior for all knights
; // ==================================

IFNDEF KNIGHT_INC
KNIGHT_INC EQU 1

INCLUDE game_object.inc

; // Identifiers for the stat offsets
HP EQU 0
ATK EQU 1
DEF EQU 2
ATKSP EQU 3
MOVSP EQU 4
RANGE EQU 5

KnightGameObject STRUCT
	baseGameObject GameObject<>
	stats DWORD 6 DUP(?)
KnightGameObject ENDS

ENDIF
