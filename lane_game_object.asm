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
lane_update PROC stdcall USES eax edx ebx esi edi, deltaTime: REAL4
		local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	; // Iterate over ally knights to find the one in front
	lea ecx, (LaneGameObject PTR [ecx]).allyKnights
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, 0
	.WHILE edx < ebx
		mov ecx, pThis
		push ecx

		push (LaneGameObject PTR [ecx]).pFirstAlly
		lea ecx, (LaneGameObject PTR [ecx]).allyKnights
		mov ebx, (UnorderedVector PTR [ecx]).count
		mov eax, (UnorderedVector PTR [ecx]).pData

		; // esi = allyKnights[i]
		mov esi, [eax + edx * 4]
		
		; // Get the transform of the current first ally
		pop ecx
		INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
		mov edi, (TransformComponent PTR [eax]).x
		
		mov ecx, esi
		INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
		mov eax, (TransformComponent PTR [eax]).x

		; // Assign new firstAlly if further ahead in lane
		pop ecx
		.IF eax > edi
			mov (LaneGameObject PTR [ecx]).pFirstAlly, esi
		.ENDIF

		inc edx
	.ENDW

	mov ecx, pThis
	; // Iterate over enemy knights to find the one in front
	lea ecx, (LaneGameObject PTR [ecx]).enemyKnights
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, 0
	.WHILE edx < ebx
		mov ecx, pThis
		push ecx

		push (LaneGameObject PTR [ecx]).pFirstEnemy
		lea ecx, (LaneGameObject PTR [ecx]).enemyKnights
		mov ebx, (UnorderedVector PTR [ecx]).count
		mov eax, (UnorderedVector PTR [ecx]).pData

		; // esi = enemyKnights[i]
		mov esi, [eax + edx * 4]
		
		; // Get the transform of the current first enemy
		pop ecx
		INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
		mov edi, (TransformComponent PTR [eax]).x
		
		mov ecx, esi
		INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
		mov eax, (TransformComponent PTR [eax]).x

		; // Assign new firstEnemy if further ahead in lane
		pop ecx
		.IF eax < edi	; // Comparison is flipped since enemies move left
			mov (LaneGameObject PTR [ecx]).pFirstEnemy, esi
		.ENDIF

		inc edx
	.ENDW

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

	; // Choose vector depending on knight's assigned team
	mov eax, (KnightGameObject PTR [pKnight]).team
	.IF eax == ALLY
		; // Makes this knight the first ally if there are no other knights
		lea ebx, (LaneGameObject PTR [ecx]).allyKnights
		mov ebx, (UnorderedVector PTR [ebx]).count
		.IF ebx == 0
			mov ebx, pKnight
			mov (LaneGameObject PTR [ecx]).pFirstAlly, ebx
		.ENDIF

		lea ecx, (LaneGameObject PTR [ecx]).allyKnights
	
	.ELSE
		; // Makes this knight the first enemy if there are no other knights
		lea ebx, (LaneGameObject PTR [ecx]).enemyKnights
		mov ebx, (UnorderedVector PTR [ebx]).count
		.IF ebx == 0
			mov ebx, pKnight
			mov (LaneGameObject PTR [ecx]).pFirstEnemy, ebx
		.ENDIF

		lea ecx, (LaneGameObject PTR [ecx]).enemyKnights
	.ENDIF

	mov eax, pKnight
	INVOKE push_back, eax

	mov ecx, pThis
	mov eax, pKnight
	mov (KnightGameObject PTR [eax]).pLane, ecx	; // Knight has pointer to this lane
	ret
assign_knight ENDP

END