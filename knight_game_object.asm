; // ==================================
; // knight_game_object.asm
; // ----------------------------------
; // The knight is a subclass of GameObject designed
; // to handle all logic regarding knight units
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE heap_functions.inc
INCLUDE knight_game_object.inc
INCLUDE transform_component.inc
INCLUDE sprite_component.inc

.data
KNIGHT_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET game_object_update, OFFSET game_object_exit, OFFSET free_game_object>

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

	mov eax, team		; // must be moved here first for it to compile
	mov (KnightGameObject PTR [ecx]).team, eax
	mov (KnightGameObject PTR [ecx]).MOVSP, 50

	; // Gives Knight a transform
	INVOKE new_transform_component, 0, 200, 0
	INVOKE add_component, ecx, eax

	; // Gives Knight a sprite
	INVOKE new_sprite_component, 0, 0, pTexture
	INVOKE add_component, ecx, eax
	
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

END 