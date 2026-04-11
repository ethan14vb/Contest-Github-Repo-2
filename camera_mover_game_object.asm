; // ==================================
; // camera_mover_game_object.asm
; // ----------------------------------
; // The camera mover is a subclass of GameObject designed
; // to move the camera left and right depending on keyboard input.
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE scene.inc
INCLUDE camera.inc
INCLUDE camera_mover_game_object.inc
INCLUDE heap_functions.inc
INCLUDE input_manager.inc

.data
CAMERA_MOVER_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET camera_mover_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_camera_mover_game_object
; // Initializes memory with the contents of a CameraMoverGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_camera_mover_game_object PROC PUBLIC USES esi ebx edx
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, CAMERA_MOVER_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET CAMERA_MOVER_GAMEOBJECT_VTABLE

	mov (CameraMoverGameObject PTR [ecx]).moveSpeed, 2
		
	ret
init_camera_mover_game_object ENDP

; // ----------------------------------
; // new_camera_mover_game_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_camera_mover_game_object PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF CameraMoverGameObject
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_camera_mover_game_object

	ret ; // Return with the address of the memory block in HeapAlloc
new_camera_mover_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // camera_mover_update
; // Moves the camera depending on the keys pressed
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
camera_mover_update PROC stdcall USES eax, deltaTime: REAL4
	local pThis : DWORD, xMov : SDWORD, yMov : SDWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	mov xMov, 0
	mov yMov, 0

	; // Check if any of the keys are pressed
	INVOKE isKeyPressed, VK_LEFT
	neg eax
	add xMov, eax

	INVOKE isKeyPressed, VK_RIGHT
	add xMov, eax

	INVOKE isKeyPressed, VK_UP
	neg eax
	add yMov, eax

	INVOKE isKeyPressed, VK_DOWN
	add yMov, eax

	; // Now move the camera
	mov ecx, (GameObject PTR [ecx]).pParentScene
	lea ecx, (Scene PTR [ecx]).camera

	mov eax, xMov
	add (Camera PTR [ecx]).x, eax
	mov eax, yMov
	add (Camera PTR [ecx]).y, eax

	mov ecx, pThis ; // Restore the THIS pointer
	ret
camera_mover_update ENDP

END 