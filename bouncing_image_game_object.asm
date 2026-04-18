; // ==================================
; // bouncing_image_game_object.asm
; // ----------------------------------
; // An image that bounces left and right, mainly used to test that events work.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE bouncing_image_game_object.inc

.data
BOUNCING_IMAGE_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET game_object_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
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
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, BOUNCING_IMAGE_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET BOUNCING_IMAGE_GAMEOBJECT_VTABLE

	mov eax, pTexture

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

END