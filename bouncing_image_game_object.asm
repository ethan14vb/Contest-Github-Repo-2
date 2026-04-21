; // ==================================
; // bouncing_image_game_object.asm
; // ----------------------------------
; // An image that bounces left and right, mainly used to test that events work.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE transform_component.inc
INCLUDE timer_component.inc
INCLUDE sprite_component.inc
INCLUDE bouncing_image_game_object.inc

.data
BOUNCING_IMAGE_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET bouncing_image_update, OFFSET game_object_exit, OFFSET free_bouncing_image>
TIMER_WAIT_TIME REAL4 2.0

.code
; // ********************************************
; // Callback Methods
; // ********************************************

; // ----------------------------------
; // bouncing_image_on_timeout
; // Event callback. Flips the direction
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
bouncing_image_on_timeout PROC PUBLIC USES eax ebx, pArgs:DWORD
	mov ebx, pArgs ; // we don't need any arguments, but use it so that Lord MASM will permit the code to compile

	mov eax, (BouncingImageGameObject PTR [ecx]).direction
	
	; // Flip the direction
	neg eax 
	
	mov (BouncingImageGameObject PTR [ecx]).direction, eax

	ret
bouncing_image_on_timeout ENDP

; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_bouncing_image_game_object
; // Initializes memory with the contents of a BouncingImageGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_bouncing_image_game_object PROC PUBLIC USES ebx ecx edx esi edi, pTexture : DWORD
	local pThis
	mov pThis, ecx

	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, BOUNCING_IMAGE_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET BOUNCING_IMAGE_GAMEOBJECT_VTABLE

	mov (BouncingImageGameObject PTR [ecx]).direction, 2

	INVOKE new_transform_component, 0, 0, 0
	INVOKE add_component, ecx, eax

	; // INVOKE new_sprite_component, 0, 0, pTexture
	; // INVOKE add_component, ecx, eax
	mov eax, pTexture

	; // Create the timer
	INVOKE new_timer, TIMER_WAIT_TIME, 0, 1
	push eax
	INVOKE add_component, ecx, eax
	pop eax

	; // Connect the event to the callback function
	lea ecx, (TimerComponent PTR [eax]).timeout
	INVOKE event_connect, pThis, OFFSET bouncing_image_on_timeout

	mov ebx, pThis
	mov (BouncingImageGameObject PTR [ebx]).pTimeoutConnection, eax

	mov eax, pThis

	ret
init_bouncing_image_game_object ENDP

; // ----------------------------------
; // new_bouncing_image_game_object
; // Allocates memory for a BouncingImageGameObject and then calls
; // the initializer method on it.
; // ----------------------------------
new_bouncing_image_game_object PROC PUBLIC USES ebx ecx edx esi edi, pTexture : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF BouncingImageGameObject
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_bouncing_image_game_object, pTexture

	ret ; // Return with the address of the memory block in HeapAlloc
new_bouncing_image_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // bouncing_image_update
; // Moves the camera depending on the keys pressed
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
bouncing_image_update PROC stdcall USES eax ebx ecx edx esi edi, deltaTime: REAL4
	local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID

	mov ebx, (BouncingImageGameObject PTR [ecx]).direction
	add (TransformComponent PTR [eax]).x, ebx

	mov ecx, pThis ; // Restore the THIS pointer
	ret
bouncing_image_update ENDP

; // ----------------------------------
; // free_bouncing_image
; // Disconnects the callbacks
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_bouncing_image PROC stdcall USES eax ebx ecx
	local pThis
	mov pThis, ecx

	mov ecx, pThis
	INVOKE get_first_component_which_is_a, TIMER_COMPONENT_ID
	
	; // Disconnect the event
	lea ecx, (TimerComponent PTR [eax]).timeout
		
	mov ebx, pThis
	mov ebx, (BouncingImageGameObject PTR [ebx]).pTimeoutConnection

	INVOKE event_disconnect, ebx

	; // Destroy myself
	mov ecx, pThis
	INVOKE free_game_object

	ret
free_bouncing_image ENDP

END