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

AnimatorComponent STRUCT
	baseComponent Component <>

	pSprite DWORD ?

	pAnimations DWORD ?
	animCount DWORD ?

	curAnimIndex DWORD ?
	curFrameIndex DWORD ?
	timeAccumulator REAL4 ?

	animFinishedEvent EVENT <>
AnimatorComponent ENDS

ENDIF