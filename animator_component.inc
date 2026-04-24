; // ==================================
; // AnimatorComponent
; // ----------------------------------
; // Connects to a sprite component and changes the sprite's visible
; // cell based on internal animations.
; // ==================================

IFNDEF ANIMATOR_COMPONENT_INC
ANIMATOR_COMPONENT_INC EQU 1

INCLUDE component.inc
INCLUDE event.inc

; // Data struct for storing an individual frame of an animation
AnimationFrame STRUCT
	cellX       DWORD ?
	cellY       DWORD ?
	cellW		DWORD ?
	cellH		DWORD ?
	duration    REAL4 ?
	eventCode   DWORD ?
AnimationFrame ENDS

; // An animation that can be played back by an AnimatorComponent
Animation STRUCT
	animID      DWORD ?
	pFrames     DWORD ?
	frameCount  DWORD ?
	looping     DWORD ?
Animation ENDS

AnimatorComponent STRUCT
	baseComponent		Component <>

	; // Connected sprite
	pSprite				DWORD ?

	; // Animation data
	pAnimations			DWORD ?
	animCount			DWORD ?

	; // Playback state data
	curAnimIndex		DWORD ?
	curFrameIndex		DWORD ?
	timeAccumulator		REAL4 ?

	; // Events
	animFinishedEvent	Event <>
AnimatorComponent ENDS

ENDIF