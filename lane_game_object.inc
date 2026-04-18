; // ==================================
; // lane_game_object.inc
; // ----------------------------------
; // The lane is a subclass of GameObject
; // that handles all logic for game lanes
; // ==================================

IFNDEF LANE_GAME_OBJECT_INC
LANE_GAME_OBJECT_INC EQU 1

INCLUDE lane_game_object.inc

; // Maximum number of knights of each team per lane
MAX_LANE_KNIGHTS EQU 10

LaneGameObject STRUCT
	baseGameObject GameObject<>
	pFirstAlly DWORD ?	; // Pointers to each team's respective first knight
	pFirstEnemy DWORD ?
	pAllyKnights DWORD MAX_LANE_KNIGHTS DUP(?)
	pEnemyKnights DWORD MAX_LANE_KNIGHTS DUP (?)
LaneGameObject ENDS

init_lane_game_object PROTO
new_lane_game_object PROTO

ENDIF
