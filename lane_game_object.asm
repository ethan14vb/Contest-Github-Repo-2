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
INCLUDE knight_game_object.inc
INCLUDE transform_component.inc

.data
LANE_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET lane_update, OFFSET game_object_exit, OFFSET free_game_object>

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
		local pThis
	mov pThis, ecx

	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, LANE_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET LANE_GAMEOBJECT_VTABLE

	; // Set up knight uvectors
	mov eax, MAX_LANE_KNIGHTS
	lea ecx, (LaneGameObject PTR [ecx]).allyKnights
	INVOKE init_unordered_vector, eax

	mov ecx, pThis
	lea ecx, (LaneGameObject PTR [ecx]).enemyKnights
	INVOKE init_unordered_vector, MAX_LANE_KNIGHTS
	
	mov ecx, pThis ; // restores ecx after its changed earlier
	; // Gives Lane a transform
	INVOKE new_transform_component, 0, 0, 0
	INVOKE add_component, ecx, eax

	mov ecx, pThis
	mov eax, ecx
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

; // ----------------------------------
; // lane_update
; // Assigns new firstKnight depending on position
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
lane_update PROC stdcall USES eax, deltaTime: REAL4
		local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	mov ecx, pThis ; // Restore the THIS pointer
	ret
lane_update ENDP

; // ----------------------------------
; // assign_knight
; // Adds a knight pointer to the lane's list in either team
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
assign_knight PROC PUBLIC USES eax ebx ecx esi edi, pKnight:DWORD
		local pThis
	mov pThis, ecx
	mov eax, (KnightGameObject PTR [pKnight]).team
	.IF eax == ALLY
		lea ecx, (LaneGameObject PTR [ecx]).allyKnights
	.ELSE
		lea ecx, (LaneGameObject PTR [ecx]).enemyKnights
	.ENDIF

	mov eax, pKnight
	INVOKE push_back, eax

	mov ecx, pThis
	ret
assign_knight ENDP

END