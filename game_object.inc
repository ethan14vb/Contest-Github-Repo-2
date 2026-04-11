; // ==================================
; // GameObject
; // ----------------------------------
; //	GameObjects are the core elements of a scene
; // that contain gameplay logic and anything the player
; // will see.
; //	This STRUCT is intended to be 'subclassed' by 
; // overriding the virtual function table.
; //	GameObjects contain a list of components that
; // define utility behavior such as sprites to render
; // or animation states. These componenets are updated
; // by the scene_update to keep their auxillary functionality
; // separate from main game logic.
; // ==================================

IFNDEF GAME_OBJECT_INC
GAME_OBJECT_INC EQU 1

INCLUDE game_object_ids.inc
INCLUDE unordered_vector.inc
INCLUDE component_ids.inc

ENUM_GAME_OBJECT_ID TYPEDEF DWORD

GameObject_vtable STRUCT
	pStart DWORD ? ; For game logic that should run just after the GameObjec is initialized
	pUpdate DWORD ? ; For game logic that will run every frame update
	pExit DWORD ? ; For game logic that should run just before the GameObject is freed
	pFree DWORD ? ; Destructor
GameObject_vtable ENDS

GameObject STRUCT
	gameObjectType ENUM_GAME_OBJECT_ID ?
	components UnorderedVector <>
	pVt DWORD ? ; Pointer to a virtual function table

	pParentScene DWORD ?

	; // Flags
	awaitingFree DWORD ? ; // Whether the object is awaiting removal from the scene. Zero if FALSE, nonzero if TRUE
GameObject ENDS

; // Static methods
add_component PROTO pGameObject: DWORD, pComponent: DWORD
check_rect_collision PROTO pRect1 : DWORD, pTrans1 : DWORD, pRect2 : DWORD, pTrans2 : DWORD

; // Constructors
init_game_object PROTO maxComponents : DWORD
new_game_object PROTO maxComponents : DWORD
free_game_object PROTO

; // Instance methods
get_first_component_which_is_a	PROTO componentType : ENUM_COMPONENT_ID
game_object_start_virtual		PROTO
game_object_free_virtual		PROTO
game_object_update_virtual		PROTO deltaTime : REAL4
game_object_exit				PROTO
game_object_start				PROTO
game_object_update				PROTO deltaTime: REAL4

ENDIF
