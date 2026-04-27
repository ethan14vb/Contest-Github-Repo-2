; // ==================================
; // knight_game_object.inc
; // ----------------------------------
; // The knight is a subclass of GameObject that
; // defines basic behavior for all knights
; // ==================================

IFNDEF KNIGHT_GAME_OBJECT_INC
KNIGHT_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

; // Constants for identifying teams
ALLY EQU 0
ENEMY EQU 1

KnightGameObject STRUCT
	baseGameObject GameObject<>
	pLane DWORD ?	; // Pointer to the lane it belongs to
	team DWORD ?

	state DWORD ?
	cooldown REAL4 ? ; // the amount of time waited after an attack finished

	HP DWORD ?
	ATK DWORD ?
	DEF DWORD ?
	ATKSP REAL4 ?	; // Cooldown time between attacks
	MOVSP DWORD ?	; // Speed at which unit moves in lane
	RANGE DWORD ?	; // Distance to next enemy to be able to attack
KnightGameObject ENDS

init_knight_game_object PROTO, team:DWORD, pTexture:DWORD
new_knight_game_object PROTO, team:DWORD, pTexture:DWORD
get_first_opposing_knight PROTO, callerTeam:DWORD
is_knight_in_range PROTO, pOpposingKnight:DWORD
attack PROTO, pOpposingKnight:DWORD
receive_damage PROTO, damage:DWORD

ENDIF
