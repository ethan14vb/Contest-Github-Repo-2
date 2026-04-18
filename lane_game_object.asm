; // ==================================
; // lane_game_object.asm
; // ----------------------------------
; // The lane is a subclass of GameObject
; // that handles all logic for game lanes
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE heap_functions.inc
INCLUDE lane_game_object.inc

.data
LANE_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET game_object_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_lane_game_object
; // Initializes memory with the contents of a LaneGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_lane_game_object PROC PUBLIC USES esi ebx edx
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, LANE_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET LANE_GAMEOBJECT_VTABLE
		
	ret
init_lane_game_object ENDP

; // ----------------------------------
; // new_lane_game_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_lane_game_object PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF LaneGameObject
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_lane_game_object

	ret ; // Return with the address of the memory block in HeapAlloc
new_lane_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

END