; // ==================================
; // bouncing_image_game_object.inc
; // ----------------------------------
; // An image that bounces left and right, mainly used to test that events work.
; // ==================================

IFNDEF BOUNCING_IMAGE_GAME_OBJECT_INC
BOUNCING_IMAGE_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc
INCLUDE event.inc

BouncingImageGameObject STRUCT
	baseGameObject		GameObject<>
	pTimeoutConnection	DWORD ?
	direction			DWORD ?
BouncingImageGameObject ENDS

init_bouncing_image_game_object PROTO pTexture : DWORD
new_bouncing_image_game_object PROTO pTexture : DWORD

ENDIF