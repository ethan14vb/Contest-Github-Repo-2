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
INCLUDE animator_component.inc

.data
KNIGHT_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET knight_update, OFFSET game_object_exit, OFFSET free_game_object>

; // ********************************************
; // State Data
; // ********************************************

STATE_WALK   EQU 0
STATE_ATTACK EQU 1
STATE_IDLE   EQU 2

; // ********************************************
; // Animation Data
; // ********************************************

; // Define animation ID constants
IDLE_ANIM		EQU 1
WALK_ANIM		EQU 2
ATTACK_ANIM		EQU 3

; // Create the animation frames
idle_anim AnimationFrame	<512, 512, 256, 256, 0.5, 0>,		\
							<768, 512, 256, 256, 0.5, 0>,		\
							<1024, 512, 256, 256, 0.5, 0>,		\
							<1280, 512, 256, 256, 0.5, 0>,		\
							<0, 768, 256, 256, 0.5, 0>,			\
							<256, 768, 256, 256, 0.5, 0>,		\
							<512, 768, 256, 256, 0.5, 0>,		\
							<768, 768, 256, 256, 0.5, 0>,		\
							<1024, 768, 256, 256, 0.5, 0>,		\
							<1280, 768, 256, 256, 0.5, 0>,		\
							<0, 1024, 256, 256, 0.5, 0>
WLK_FRM_TM equ 0.1
walk_anim AnimationFrame	<768, 0, 256, 256, 0.1, 0>,\
							<1024, 0, 256, 256, WLK_FRM_TM, 0>,\
							<1280, 0, 256, 256, WLK_FRM_TM, 0>,\
							<0, 256, 256, 256, WLK_FRM_TM, 0>,	\
							<256, 256, 256, 256, WLK_FRM_TM, 0>,\
							<512, 256, 256, 256, WLK_FRM_TM, 0>,\
							<768, 256, 256, 256, WLK_FRM_TM, 0>,\
							<1024, 256, 256, 256, WLK_FRM_TM, 0>,\
							<1280, 256, 256, 256, WLK_FRM_TM, 0>,\
							<0, 512, 256, 256, WLK_FRM_TM, 0>,\
							<256, 512, 256, 256, WLK_FRM_TM, 0>
	
ATTACK_EVENT_CODE equ 99
attack_anim AnimationFrame	<256, 1024, 256, 256, 0.5, 0>,		\
							<512, 1024, 256, 256, 0.5, 0>,		\
							<768, 1024, 256, 256, 0.5, ATTACK_EVENT_CODE>,		\
							<1024, 1024, 256, 256, 0.5, 0>,		\
							<1280, 1024, 256, 256, 0.5, 0>

; // Create the list of animations
knight_animations Animation \
<IDLE_ANIM, OFFSET idle_anim, 11, 1>, \
<WALK_ANIM, OFFSET walk_anim, 8, 1>, \
<ATTACK_ANIM, OFFSET attack_anim, 5, 0>

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
	mov (KnightGameObject PTR [ecx]).MOVSP, 10
	mov (KnightGameObject PTR [ecx]).RANGE, 120

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

	mov (SpriteComponent PTR [eax]).isCell, 0FFFFFFFFh
	push eax
	INVOKE add_component, ecx, eax

	pop eax
	INVOKE new_animator_component, eax, OFFSET knight_animations, 3
	INVOKE add_component, ecx, eax

	mov ecx, eax
	INVOKE animator_play, WALK_ANIM
	
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
	local pFirstOpposingKnight : DWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	; // Obtain the x position of the first opposing knight in lane
	mov eax, (KnightGameObject PTR [ecx]).team
	INVOKE get_first_opposing_knight, eax
	cmp eax, 0
	je SkipAttackCheck		; // If there is no opposing knights, does not check for attack
	mov pFirstOpposingKnight, eax

	; // If the opposing knight is in range, attacks it
	INVOKE is_knight_in_range, pFirstOpposingKnight
	.IF eax == 1
		INVOKE attack, pFirstOpposingKnight
		jmp SkipMovement
	.ENDIF


	SkipAttackCheck:
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
get_first_opposing_knight PROC stdcall USES ebx ecx edx, callerTeam:DWORD
	local pThis : DWORD
	mov pThis, ecx
	
	; // Get number of opposing knights in eax
	mov edx, (KnightGameObject PTR [ecx]).pLane
	mov eax, callerTeam
	mov ebx, 0
	.IF eax == ALLY
		lea ebx, (LaneGameObject PTR [edx]).enemyKnights
		mov eax, (UnorderedVector PTR [ebx]).count
	.ELSE
		lea ebx, (LaneGameObject PTR [edx]).allyKnights
		mov eax, (UnorderedVector PTR [ebx]).count
	.ENDIF

	; // If no opposing knights, return 0
	cmp eax, 0
	je SkipGetPointer

	; // Otherwise, getting corresponding opposing first knight
	mov edx, (KnightGameObject PTR [ecx]).pLane
	mov eax, callerTeam
	.IF eax == ALLY
		mov eax, (LaneGameObject PTR [edx]).pFirstEnemy
	.ELSE
		mov eax, (LaneGameObject PTR [edx]).pFirstAlly
	.ENDIF

	SkipGetPointer:
	mov ecx, pThis
	ret
get_first_opposing_knight ENDP

; // ----------------------------------
; // is_knight_in_range
; // Returns in eax 1 if the given knight is in range for the calling knight
; // Returns in eax 0 if the given knight is not in range for the calling knight
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
is_knight_in_range PROC stdcall USES ebx ecx edx esi, pOpposingKnight:DWORD
	local pThis : DWORD
	mov pThis, ecx

	; // Obtain caller's team, range, pos and opponent's pos
	mov ebx, (KnightGameObject PTR [ecx]).team
	mov edx, (KnightGameObject PTR [ecx]).RANGE
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
	mov esi, (TransformComponent PTR [eax]).x
	mov ecx, pOpposingKnight
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
	mov eax, (TransformComponent PTR [eax]).x
	
	; // ebx = caller's team, edx = caller's range
	; // esi = caller's xpos, eax = opposin's xpos
	; // If the unit's are past each other in the lane, return false
	.IF ebx == ALLY
		.IF esi > eax
			jmp ReturnFalse
		.ENDIF
	.ELSE
		.IF esi < eax
			jmp ReturnFalse
		.ENDIF
	.ENDIF

	; // Obtain the absolute value of the difference in unit positions in eax
	sub eax, esi
	cmp eax, 0
	jge SkipNegate
	neg eax
	SkipNegate:

	.IF eax < edx
		jmp ReturnTrue
	.ENDIF

	; // Returns corresponding result, ecx is restored by USES
	ReturnFalse:
	mov eax, 0
	ret

	ReturnTrue:
	mov eax, 1
	ret
is_knight_in_range ENDP

; // ----------------------------------
; // attack
; // Sends an attack to the opposing knight witht their receive damage method
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
attack PROC stdcall USES ebx ecx edx esi, pOpposingKnight:DWORD
	mov ecx, pOpposingKnight
	INVOKE receive_damage, 5
	ret
attack ENDP

; // ----------------------------------
; // receive_damage
; // The unit takes damage and frees itself if necessary
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
receive_damage PROC stdcall USES ebx ecx edx esi, damage:DWORD
	mov eax, damage
	ret
receive_damage ENDP
END 