; // ==================================
; // rectangle_test_scene.asm
; // ----------------------------------
; // Initializes a scene to have two rectangles to test the rendering
; // capabilities for RectComponents.
; // ==================================

INCLUDE default_header.inc
INCLUDE rectangle_test_scene.inc
INCLUDE camera_mover_game_object.inc
INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE game_object.inc
INCLUDE scene.inc

.code
; // ----------------------------------
; // populate_rectangle_test_scene
; // Call this method on an empty Scene to fill it
; // with the rectangle test scene contents.
; // ----------------------------------
populate_rectangle_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	; // Red Rectangle
	INVOKE new_game_object, 2
	mov ecx, eax

	INVOKE new_transform_component, 0, 0, 0
	INVOKE add_component, ecx, eax

	INVOKE new_rect_component, 4, 4, 0, 255, 128, 255
	INVOKE add_component, ecx, eax

	mov esi, ecx
	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	; // Blue Rectangle
	INVOKE new_game_object, 2
	mov ecx, eax

	INVOKE new_transform_component, 50, 48, 0
	INVOKE add_component, ecx, eax

	INVOKE new_rect_component, 6, 200, 5, 0, 255, 255
	INVOKE add_component, ecx, eax

	mov esi, ecx
	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	; // Camera mover game object
	INVOKE new_camera_mover_game_object
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	ret
populate_rectangle_test_scene ENDP

END
