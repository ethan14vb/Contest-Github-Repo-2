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

.code
init_animator_component PROC PUBLIC USES ecx esi, pSprite:DWORD, pAnimations:DWORD, animCount:DWORD
	local pThis
	mov pThis, ecx
	; // Parent constructor
	INVOKE init_component
	mov (Component PTR [ecx]).componentType, ANIMATOR_COMPONENT_ID

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

new_animator_component PROC PUBLIC USES ecx esi, pSprite : DWORD, pAnimations : DWORD, animCount : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF AnimatorComponent
	mov ecx, eax; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_animator_component, pSprite, pAnimations, animCount

	ret; // Return with the address of the memory block in HeapAlloc
new_animator_component ENDP

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
	mov edi, (AnimatorComponent PTR [ecx]).animCount

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
		lea ecx, (AnimatorComponent PTR [esi]).pSprite
		lea edx, (Animation PTR [ebx + eax]).pFrames

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

END