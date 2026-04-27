; // ==================================
; // castle_game_object.inc
; // ----------------------------------
; // The castle is a subclass of GameObject
; // that handles all logic for both castles
; // ==================================

IFNDEF CASTLE_GAME_OBJECT_INC
CASTLE_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

CastleGameObject STRUCT
	baseGameObject GameObject<>
	HP DWORD ?
CastleGameObject ENDS

init_castle_game_object PROTO, team:DWORD, pTexture:DWORD
new_castle_game_object PROTO, team:DWORD, pTexture:DWORD

ENDIF
