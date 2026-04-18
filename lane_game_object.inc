; // ==================================
; // lane_game_object.inc
; // ----------------------------------
; // The lane is a subclass of GameObject
; // that handles all logic for game lanes
; // ==================================

IFNDEF LANE_GAME_OBJECT_INC
LANE_GAME_OBJECT_INC EQU 1

INCLUDE lane_game_object.inc

LaneGameObject STRUCT
	baseGameObject GameObject<>
LaneGameObject ENDS

ENDIF
