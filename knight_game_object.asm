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
INCLUDE scene.inc

.data
KNIGHT_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET knight_update, OFFSET game_object_exit, OFFSET free_knight>

; // misc
MY_ATKSP REAL4 0.5

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
IDL_FRM_TM equ 0.1
idle_anim AnimationFrame	<512, 512, 256, 256, 0.1, 0>,		\
							<768, 512, 256, 256, 0.1, 0>,		\
							<1024, 512, 256, 256, 0.1, 0>,		\
							<1280, 512, 256, 256, 0.1, 0>,		\
							<0, 768, 256, 256, 0.1, 0>,			\
							<256, 768, 256, 256, IDL_FRM_TM, 0>,		\
							<512, 768, 256, 256, IDL_FRM_TM, 0>,		\
							<768, 768, 256, 256, IDL_FRM_TM, 0>,		\
							<1024, 768, 256, 256, IDL_FRM_TM, 0>,		\
							<1280, 768, 256, 256, IDL_FRM_TM, 0>,		\
							<0, 1024, 256, 256, IDL_FRM_TM, 0>
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
attack_anim AnimationFrame	<256, 1024, 256, 256, 0.02, 0>,		\
							<512, 1024, 256, 256, 0.5, 0>,		\
							<768, 1024, 256, 256, 0.06, ATTACK_EVENT_CODE>,		\
							<1024, 1024, 256, 256, 0.5, 0>,		\
							<1280, 1024, 256, 256, 0.02, 0>

; // Create the list of animations
knight_animations Animation \
<IDLE_ANIM, OFFSET idle_anim, 11, 1>, \
<WALK_ANIM, OFFSET walk_anim, 8, 1>, \
<ATTACK_ANIM, OFFSET attack_anim, 5, 0>

.code
; // ********************************************
; // Callback Methods
; // ********************************************

; // ----------------------------------
; // knight_on_frame_event
; // Callback triggered by the Animator when it hits a frame with an eventCode > 0
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
knight_on_frame_event PROC stdcall USES eax ecx edx, eventCode:DWORD
	; // If we are a zombie object, return immediately
	mov edx, (GameObject PTR [ecx]).awaitingFree
	.IF edx != 0
		jmp knight_on_frame_event_exit
	.ENDIF

	mov edx, eventCode
	.IF edx == ATTACK_EVENT_CODE
		; // We are attacking, deal damage
		INVOKE get_first_opposing_knight, (KnightGameObject PTR [ecx]).team
		.IF eax != 0
			push eax
			INVOKE is_knight_in_range, eax
			pop edx
			.IF eax == 1
				; // The enemy is in range, attack
				INVOKE attack, edx
			.ENDIF
		.ENDIF
	.ENDIF
knight_on_frame_event_exit:
	ret
knight_on_frame_event ENDP

knight_on_anim_finish_event PROC stdcall USES eax ebx ecx edx esi edi, animId:DWORD
	; // If we are a zombie object, return immediately
	mov edx, (GameObject PTR[ecx]).awaitingFree
	.IF edx != 0
		jmp knight_on_anim_finish_event_exit
	.ENDIF

	; // Disregard the args but use them so MASM doesn't complain
	mov eax, animId

	; // We only care if we just finished attacking
	mov eax, (KnightGameObject PTR [ecx]).state
	.IF eax == STATE_ATTACK
		; // Transition to the idle state
		mov (KnightGameObject PTR [ecx]).state, STATE_IDLE
		
		; // Load the attack cooldown
		fld (KnightGameObject PTR [ecx]).ATKSP 
		fstp (KnightGameObject PTR [ecx]).cooldown

		; // Play the idle animation
		INVOKE get_first_component_which_is_a, ANIMATOR_COMPONENT_ID
		mov ecx, eax
		INVOKE animator_play, IDLE_ANIM
	.ENDIF
knight_on_anim_finish_event_exit:
	ret
knight_on_anim_finish_event ENDP

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
	mov (KnightGameObject PTR [ecx]).HP, 11
	mov (KnightGameObject PTR [ecx]).ATK, 10
	mov (KnightGameObject PTR [ecx]).DEF, 5
	mov (KnightGameObject PTR [ecx]).MOVSP, 10
	mov (KnightGameObject PTR [ecx]).RANGE, 120
	mov esi, MY_ATKSP
	mov (KnightGameObject PTR [ecx]).ATKSP, esi

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

	; // Create the animator component
	pop eax
	INVOKE new_animator_component, eax, OFFSET knight_animations, 3
	INVOKE add_component, ecx, eax

	mov ecx, eax
	INVOKE animator_play, WALK_ANIM

	; // Connect the frame event
	push eax
	lea ecx, (AnimatorComponent PTR [eax]).frameEvent
	INVOKE event_connect, pThis, OFFSET knight_on_frame_event

	mov ecx, pThis
	mov (KnightGameObject PTR [ecx]).pFrameConnect, eax

	; // Connect the finish event
	pop eax
	lea ecx, (AnimatorComponent PTR [eax]).animFinishedEvent
	INVOKE event_connect, pThis, OFFSET knight_on_anim_finish_event

	mov ecx, pThis
	mov (KnightGameObject PTR [ecx]).pAnimFinishedConnect, eax
		
	; // Set initial state
	mov ecx, pThis
	mov (KnightGameObject PTR [ecx]).state, STATE_WALK
	
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
; // evaluate_knight_next_state
; // Called after a knight's IDLE state cooldown ends. Determines whether to attack or walk
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
evaluate_knight_next_state PROC stdcall USES eax ecx edx
	local pThis
	mov pThis, ecx

	INVOKE get_first_opposing_knight, (KnightGameObject PTR [ecx]).team
	.IF eax != 0
		push eax
		INVOKE is_knight_in_range, eax
		pop edx
		.IF eax == 1
			; // There is an enemy ahead, attack it
			mov ecx, pThis
			mov (KnightGameObject PTR [ecx]).state, STATE_ATTACK
			INVOKE get_first_component_which_is_a, ANIMATOR_COMPONENT_ID
			mov ecx, eax
			INVOKE animator_play, ATTACK_ANIM

			jmp evaluate_knight_next_state_exit
		.ENDIF
	.ENDIF

	; // No enemy in range. Go back to walking!
	mov ecx, pThis
	mov (KnightGameObject PTR [ecx]).state, STATE_WALK
	INVOKE get_first_component_which_is_a, ANIMATOR_COMPONENT_ID
	mov ecx, eax
	INVOKE animator_play, WALK_ANIM

evaluate_knight_next_state_exit:
	ret
evaluate_knight_next_state ENDP

; // ----------------------------------
; // knight_update
; // Updates the knight depending on its current state
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
knight_update PROC stdcall USES eax ebx ecx edx esi edi, deltaTime: REAL4
local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime

	; // Check current state
	mov eax, (KnightGameObject PTR [ecx]).state

	.IF eax == STATE_ATTACK
		; // Attack logic is handled by event callbacks, do nothing
		jmp SkipMovement
	.ELSEIF eax == STATE_IDLE
		; // Decrement the cooldown timer
		fld (KnightGameObject PTR [ecx]).cooldown
		fsub deltaTime
		fstp (KnightGameObject PTR [ecx]).cooldown

		fldz
		fld (KnightGameObject PTR [ecx]).cooldown
		fcomip st(0), st(1)
		fstp st(0)
		ja SkipMovement

		; // Determine whether to keep attacking or walk
		INVOKE evaluate_knight_next_state

		jmp SkipMovement
	.ELSEIF eax == STATE_WALK
		INVOKE get_first_opposing_knight, (KnightGameObject PTR [ecx]).team
		.IF eax != 0
			push eax
			INVOKE is_knight_in_range, eax
			pop edx
			.IF eax == 1
				; // Enemy is in range, attack
				mov ecx, pThis
				mov (KnightGameObject PTR [ecx]).state, STATE_ATTACK
				
				INVOKE get_first_component_which_is_a, ANIMATOR_COMPONENT_ID
				mov ecx, eax
				INVOKE animator_play, ATTACK_ANIM
				jmp SkipMovement
			.ENDIF
		.ENDIF

		; // No enemy in range. Keep walking forward.
		mov ecx, pThis
		INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
		mov ebx, (KnightGameObject PTR [ecx]).MOVSP
		mov edx, (KnightGameObject PTR [ecx]).team
		.IF edx == ENEMY
			neg ebx
		.ENDIF
		add (TransformComponent PTR [eax]).x, ebx
	.ENDIF

SkipMovement:
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
attack PROC stdcall USES eax ebx ecx edx esi, pOpposingKnight:DWORD
		local pThis : DWORD
	mov pThis, ecx

	; // Get the non-negative differnece between atk and def as damage
	mov eax, (KnightGameObject PTR [ecx]).ATK
	mov ecx, pOpposingKnight
	sub eax, (KnightGameObject PTR [ecx]).DEF
	.IF eax < 0
		mov eax, 0
	.ENDIF

	INVOKE receive_damage, eax
	ret
attack ENDP

; // ----------------------------------
; // receive_damage
; // The unit takes damage and frees itself if necessary
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
receive_damage PROC stdcall USES eax ebx ecx edx esi, damage:DWORD
		local pThis : DWORD
	mov pThis, ecx

	; // Substract damage and die if HP <= 0
	mov eax, (KnightGameObject PTR [ecx]).HP
	sub eax, damage
	cmp eax, 0
	jg SkipDeath
		mov ecx, (KnightGameObject PTR [ecx]).pLane
		mov eax, pThis
		INVOKE remove_knight, eax
		; // die
		mov ecx, pThis
		mov ecx, (GameObject PTR [ecx]).pParentScene
		INVOKE queue_free_game_object, pThis

SkipDeath:
	mov ecx, pThis
	mov (KnightGameObject PTR [ecx]).HP, eax

	ret
receive_damage ENDP

; // ----------------------------------
; // free_knight
; // Destructs and frees the knight
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_knight PROC
	local pThis
	mov pThis, ecx

	; // Disconnect the connections
	mov ebx, (KnightGameObject PTR [ecx]).pFrameConnect
	INVOKE event_disconnect, ebx

	mov ecx, pThis

	mov ebx, (KnightGameObject PTR [ecx]).pAnimFinishedConnect
	INVOKE event_disconnect, ebx
	
	; // Free myself
	mov ecx, pThis
	INVOKE free_game_object
	ret
free_knight ENDP

END 