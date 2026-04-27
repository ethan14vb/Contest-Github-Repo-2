; // ==================================
; // knight_game_object.asm
; // ----------------------------------
; // The knight is a subclass of GameObject designed
; // to handle all logic regarding knight units
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE heap_functions.inc
INCLUDE lane_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE transform_component.inc
INCLUDE sprite_component.inc

.data
KNIGHT_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET knight_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_knight_game_object
; // Initializes memory with the contents of a KnightGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_knight_game_object PROC PUBLIC USES esi ebx edx, team:DWORD, pTexture:DWORD
		local pThis
	mov pThis, ecx
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, KNIGHT_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET KNIGHT_GAMEOBJECT_VTABLE

	mov eax, team		; // Must be moved here first for it to compile
	mov (KnightGameObject PTR [ecx]).team, eax
	mov (KnightGameObject PTR [ecx]).MOVSP, 5
	mov (KnightGameObject PTR [ecx]).RANGE, 20

	mov eax, 0			; // Default x position for allies
	cmp team, ENEMY
	jne NotEnemy
	mov eax, 1800		; // Spawns on opposite end if this is an enemy
	NotEnemy:
	; // Gives Knight a transform
	INVOKE new_transform_component, eax, 500, 0
	INVOKE add_component, ecx, eax

	; // Gives Knight a sprite
	INVOKE new_sprite_component, 0, 0, pTexture
	.IF team == ENEMY	; // Enemies have their sprite flipped
		mov (SpriteComponent PTR [eax]).flipX, 1
	.ENDIF
	INVOKE add_component, ecx, eax
	
	mov eax, pThis
	ret
init_knight_game_object ENDP

; // ----------------------------------
; // new_knight_game_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_knight_game_object PROC PUBLIC USES ecx, team:DWORD, pTexture:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF KnightGameObject
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_knight_game_object, team, pTexture

	ret ; // Return with the address of the memory block in HeapAlloc
new_knight_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // knight_update
; // Moves the knight forward depending on team
; // Also checks for possible enemies to attack in front of it
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
knight_update PROC stdcall USES eax ebx ecx edx esi edi, deltaTime: REAL4
	local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	mov eax, (KnightGameObject PTR [ecx]).team
	INVOKE get_first_opposing_knight, eax

	; // Move the knight forward in its lane based on its movement speed
	mov ecx, pThis
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
	mov ebx, (KnightGameObject PTR [ecx]).MOVSP
	mov edx, (KnightGameObject PTR [ecx]).team
	.IF edx == ENEMY
		neg ebx			; // Enemy moves opposite direction
	.ENDIF
	add (TransformComponent PTR [eax]).x, ebx

	SkipMovement:
	mov ecx, pThis ; // Restore the THIS pointer
	ret
knight_update ENDP

; // ----------------------------------
; // get_first_opposing_knight
; // Returns in eax a pointer to the first opposing knight in this lane
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
get_first_opposing_knight PROC stdcall USES eax ecx edx, callerTeam:DWORD
	local pThis : DWORD
	mov pThis, ecx
	
	mov edx, (KnightGameObject PTR [ecx]).pLane
	mov eax, callerTeam
	.IF eax == ALLY
		mov eax, (LaneGameObject PTR [edx]).pFirstEnemy
	.ELSE
		mov eax, (LaneGameObject PTR [edx]).pFirstAlly
	.ENDIF

	mov ecx, pThis
	ret
get_first_opposing_knight ENDP

END 