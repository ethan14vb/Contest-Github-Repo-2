; // ==================================
; // lane_game_object.inc
; // ----------------------------------
; // The lane is a subclass of GameObject
; // that handles all logic for game lanes
; // ==================================

IFNDEF LANE_GAME_OBJECT_INC
LANE_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

; // Maximum number of knights of each team per lane
MAX_LANE_KNIGHTS EQU 10

LaneGameObject STRUCT
	baseGameObject GameObject<>
	pAllyCastle DWORD ?
	pEnemyCastle DWORD ?
	pFirstAlly DWORD 0	; // Pointers to each team's respective first knight
	pFirstEnemy DWORD 0	; // If the pointer == 0, there is no first knight
	allyKnights UnorderedVector<>
	enemyKnights UnorderedVector<>
LaneGameObject ENDS

init_lane_game_object PROTO
new_lane_game_object PROTO
lane_update PROTO, deltaTime:REAL4
scan_firsts PROTO
assign_knight PROTO, pKnight:DWORD
remove_knight PROTO, pKnight:DWORD

ENDIF
