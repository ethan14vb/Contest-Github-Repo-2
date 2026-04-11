; // ==================================
; // camera_mover_game_object.inc
; // ----------------------------------
; // The camera mover is a subclass of GameObject designed
; // to move the camera left and right depending on keyboard input.
; // ==================================

IFNDEF CAMERA_MOVER_GAME_OBJECT_INC
CAMERA_MOVER_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

CameraMoverGameObject STRUCT
	baseGameObject GameObject<>
	moveSpeed DWORD ?
CameraMoverGameObject ENDS

init_camera_mover_game_object PROTO
new_camera_mover_game_object PROTO

ENDIF
