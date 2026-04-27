; // ==================================
; // AnimatorComponent
; // ----------------------------------
; // Connects to a sprite component and changes the sprite's visible
; // cell based on internal animations.
; // ==================================

INCLUDE default_header.inc
INCLUDE animator_component.inc
INCLUDE sprite_component.inc
INCLUDE heap_functions.inc

.data
ANIMATORCOMPONENT_VTABLE Component_vtable <OFFSET free_animator_component>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_animator_component
; // Initializes memory with the contents of an AnimatorComponent
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_animator_component PROC PUBLIC USES ecx esi, pSprite:DWORD, pAnimations:DWORD, animCount:DWORD
	local pThis
	mov pThis, ecx
	; // Parent constructor
	INVOKE init_component
	mov (Component PTR [ecx]).componentType, ANIMATOR_COMPONENT_ID
	mov (Component PTR [ecx]).pVt, OFFSET ANIMATORCOMPONENT_VTABLE

	; // Given data
	mov esi, pSprite
	mov (AnimatorComponent PTR [ecx]).pSprite, esi
	mov esi, pAnimations
	mov (AnimatorComponent PTR [ecx]).pAnimations, esi
	mov esi, animCount
	mov (AnimatorComponent PTR [ecx]).animCount, esi

	; // internal setup
	mov (AnimatorComponent PTR [ecx]).curAnimIndex, 0
	mov (AnimatorComponent PTR [ecx]).curFrameIndex, 0
	mov (AnimatorComponent PTR [ecx]).timeAccumulator, 0

	lea ecx, (AnimatorComponent PTR [ecx]).animFinishedEvent
	INVOKE init_event

	mov ecx, pThis
	lea ecx, (AnimatorComponent PTR [ecx]).frameEvent
	INVOKE init_event

	mov ecx, pThis
	mov eax, ecx

	ret
init_animator_component ENDP

; // ----------------------------------
; // new_animator_component
; // Allocates memory for an AnimatorComponent and then calls
; // the initializer method on it.
; // ----------------------------------
new_animator_component PROC PUBLIC USES ecx esi, pSprite : DWORD, pAnimations : DWORD, animCount : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF AnimatorComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_animator_component, pSprite, pAnimations, animCount

	ret; // Return with the address of the memory block in HeapAlloc
new_animator_component ENDP

; // ----------------------------------
; // free_animator_component
; // Destructs and frees the AnimatorComponent.
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_animator_component PROC PUBLIC USES ecx edx
	local pThis
	mov pThis, ecx

	; // Free events
	lea ecx, (AnimatorComponent PTR [ecx]).frameEvent
	INVOKE free_event

	mov ecx, pThis
	lea ecx, (AnimatorComponent PTR [ecx]).animFinishedEvent
	INVOKE free_event

	; // Free myself
	INVOKE HeapFree, hHeap, 0, pThis

	ret
free_animator_component ENDP

; // ********************************************
; // Instance Methods
; // ********************************************

; // ----------------------------------
; // animator_play
; //	Switches the currently active animation to the targetAnimID
; // and displays the first frame of the animation in the SpriteComponent.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
animator_play PROC PUBLIC USES eax ebx ecx edx esi edi, targetAnimID : DWORD
	local pThis
	mov pThis, ecx

	mov eax, (AnimatorComponent PTR [ecx]).curAnimIndex

	; // Load the current animation
	mov ebx, (AnimatorComponent PTR [ecx]).pAnimations
	imul eax, SIZEOF Animation
	mov edx, (Animation PTR [ebx + eax]).animID

	.IF edx == targetAnimID
		jmp animator_play_exit ; // The current animation is the target animation, immediately exit
	.ENDIF

	; // Search for the targetAnimID in the pAnimations array
	mov esi, ecx
	mov ecx, 0 ; // i = 0
	mov edi, (AnimatorComponent PTR [esi]).animCount

animator_play_search_loop:
	; // Check if we've gone through all animations and not found it
	cmp ecx, edi
	jge animator_play_exit

	; // animations[i]
	mov eax, ecx
	imul eax, SIZEOF Animation
	mov edx, (Animation PTR [ebx + eax]).animID

	.IF edx == targetAnimID
		mov (AnimatorComponent PTR [esi]).curAnimIndex, ecx
		mov (AnimatorComponent PTR [esi]).curFrameIndex, 0
		
		; // Reset timeAccumulator to 0.0
		fldz
		fstp (AnimatorComponent PTR [esi]).timeAccumulator
		
		; // Update SpriteComponent
		mov ecx, (AnimatorComponent PTR [esi]).pSprite
		mov edx, (Animation PTR [ebx + eax]).pFrames

		mov eax, (AnimationFrame PTR [edx]).cellX
		mov (SpriteComponent PTR [ecx]).cellX, eax
		mov eax, (AnimationFrame PTR [edx]).cellY
		mov (SpriteComponent PTR [ecx]).cellY, eax
		mov eax, (AnimationFrame PTR [edx]).cellW
		mov (SpriteComponent PTR [ecx]).cellW, eax
		mov eax, (AnimationFrame PTR [edx]).cellH
		mov (SpriteComponent PTR [ecx]).cellH, eax
			
		jmp animator_play_exit
	.ENDIF

	inc ecx
	jmp animator_play_search_loop

animator_play_exit:
	ret
animator_play ENDP

; // ----------------------------------
; // animator_update
; //	Updates the currently running animation based on deltaTime. This will
; // update the current frame, alter the SpriteComponent's cell values,
; // fire the animation ended event, and fire animation frame events.
; //
; //	If enough time has passed for multiple frames to pass, this function
; // will skip frames to account for lag. Events from skipped frames will
; // still fire.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
animator_update PROC USES eax ebx ecx edx esi edi, deltaTime:REAL4
	local pThis
	mov pThis, ecx

	; // Update time accumulator
	fld (AnimatorComponent PTR [ecx]).timeAccumulator
	fadd deltaTime
	fstp (AnimatorComponent PTR [ecx]).timeAccumulator

animator_update_state:
	; // Evaluate the current animation playback state and whether to draw the current frame or transition to a new frame
	mov ecx, pThis
	; // Get current animation
	mov eax, (AnimatorComponent PTR [ecx]).curAnimIndex
	imul eax, SIZEOF Animation
	mov ebx, (AnimatorComponent PTR [ecx]).pAnimations
	lea edi, [ebx + eax]

	; // Get current frame
	mov eax, (AnimatorComponent PTR [ecx]).curFrameIndex
	imul eax, SIZEOF AnimationFrame
	mov ebx, (Animation PTR [edi]).pFrames
	lea ebx, [ebx + eax]

	; // Check for frame advance
	fld (AnimationFrame PTR [ebx]).duration
	fld (AnimatorComponent PTR [ecx]).timeAccumulator
	fcomip st(0), st(1) 
	fstp st(0)          

	jb animator_update_apply_frame; // If no frame updates, display the current frame

	; // Advancing to a new frame, adjust time
	fld (AnimatorComponent PTR [ecx]).timeAccumulator
	fsub (AnimationFrame PTR [ebx]).duration
	fstp (AnimatorComponent PTR [ecx]).timeAccumulator

	mov eax, (AnimatorComponent PTR [ecx]).curFrameIndex
	inc eax

	mov esi, (Animation PTR [edi]).frameCount
	.IF eax >= esi
		mov edx, (Animation PTR [edi]).looping
		.IF edx == 1
			; // If the animation is looped, reset it
			mov (AnimatorComponent PTR [ecx]).curFrameIndex, 0
			jmp animator_update_state
		.ELSE
			; // If the animation is not looped

			dec esi ; // Stay on this frame
			mov (AnimatorComponent PTR [ecx]).curFrameIndex, esi

			; // Fire animation finished event
			push ecx
			lea ecx, (AnimatorComponent PTR [ecx]).animFinishedEvent
			INVOKE event_fire, 0
			pop ecx
			
			; // Re-evaluate the state just in case the event changed the currently running animation
			jmp animator_update_state
		.ENDIF
	.ENDIF

	mov (AnimatorComponent PTR [ecx]).curFrameIndex, eax

	; // Reload current frame
	imul eax, SIZEOF AnimationFrame
	mov edx, (Animation PTR [edi]).pFrames
	lea ebx, [edx + eax]

	mov eax, (AnimationFrame PTR [ebx]).eventCode
	.IF eax != 0
		mov ecx, pThis
		lea ecx, (AnimatorComponent PTR [ecx]).frameEvent
		INVOKE event_fire, eax ; // Pass the event code as an argument
		
		; // Re-evaluate the state just in case the event changed the currently running animation
		jmp animator_update_state
	.ENDIF

	; // Loop in case of a weird situation where the frame duration is smaller than deltaTime
	jmp animator_update_state

animator_update_apply_frame:
	mov edx, (AnimatorComponent PTR [ecx]).pSprite
	
	mov eax, (AnimationFrame PTR [ebx]).cellX
	mov (SpriteComponent PTR [edx]).cellX, eax
	mov eax, (AnimationFrame PTR [ebx]).cellY
	mov (SpriteComponent PTR [edx]).cellY, eax
	mov eax, (AnimationFrame PTR [ebx]).cellW
	mov (SpriteComponent PTR [edx]).cellW, eax
	mov eax, (AnimationFrame PTR [ebx]).cellH
	mov (SpriteComponent PTR [edx]).cellH, eax

	ret
animator_update ENDP

END