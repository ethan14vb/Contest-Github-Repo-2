; // ==================================
; // castle_game_object.asm
; // ----------------------------------
; // The castle is a subclass of GameObject
; // that handles all logic for both castles
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE heap_functions.inc
INCLUDE castle_game_object.inc
INCLUDE lane_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE transform_component.inc
INCLUDE sprite_component.inc
INCLUDE text_component.inc

EXTERNDEF pFontTex:DWORD

.data
CASTLE_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET castle_update, OFFSET game_object_exit, OFFSET free_game_object>
hpTextBuffer BYTE 16 DUP(0)

.code
int_to_string PROC USES eax ebx ecx edx esi edi, value:DWORD, pBuffer:DWORD
	mov eax, value
	mov edi, pBuffer
	mov ebx, 10
	mov ecx, 0

int_to_string_divide_loop:
	mov edx, 0
	div ebx
	push edx
	inc ecx
	cmp eax, 0
	jne int_to_string_divide_loop

int_to_string_pop_loop:
	pop edx
	add dl, '0'
	mov BYTE PTR [edi], dl
	inc edi
	dec ecx
	cmp ecx, 0
	jne int_to_string_pop_loop

	; // Add null terminator
	mov BYTE PTR [edi], 0
	
	ret
int_to_string ENDP


; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_castle_game_object
; // Initializes memory with the contents of a LaneGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_castle_game_object PROC PUBLIC USES esi edi ebx edx, team:DWORD, pTexture:DWORD
		local pThis
	mov pThis, ecx

	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, CASTLE_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET CASTLE_GAMEOBJECT_VTABLE

	; // For now castle HP is just 0
	mov (CastleGameObject PTR [ecx]).HP, 70
	mov eax, team
	mov (CastleGameObject PTR [ecx]).team, eax
	mov (CastleGameObject PTR [ecx]).exitNextFrame, 0

	; // Gives Castle a transform
	mov eax, 0			; // Default x position for allies
	cmp team, ENEMY
	jne NotEnemy
	mov eax, 1675		; // Spawns on opposite end if this is an enemy
	NotEnemy:
	INVOKE new_transform_component, eax, 425, 0
	INVOKE add_component, ecx, eax

	; // Gives Castle a sprite
	INVOKE new_sprite_component, 0, 0, pTexture
	.IF team == ENEMY	; // Enemies have their sprite flipped
		mov (SpriteComponent PTR [eax]).flipX, 1
	.ENDIF

	INVOKE add_component, ecx, eax

	; // Add the HP text
	mov ecx, pThis
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (TextComponent PTR [eax]).offsetX, -100
	mov (TextComponent PTR [eax]).offsetY, 100
	mov (RenderableComponent PTR [eax]).layer, 4
	INVOKE add_component, ecx, eax
	mov ecx, eax
	mov edi, pThis
	mov esi, (CastleGameObject PTR[edi]).HP
	INVOKE int_to_string, esi, OFFSET hpTextBuffer
	INVOKE set_text_component_text, OFFSET hpTextBuffer

	mov ecx, pThis
	mov eax, ecx
	ret
init_castle_game_object ENDP

; // ----------------------------------
; // new_castle_game_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_castle_game_object PROC PUBLIC USES ecx, team:DWORD, pTexture:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF CastleGameObject
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_castle_game_object, team, pTexture

	ret ; // Return with the address of the memory block in HeapAlloc
new_castle_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

castle_update PROC stdcall USES eax edx ebx esi edi, deltaTime: REAL4
		local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime ; // Use the deltaTime variable so MASM doesn't get angry and throw a compile time error

	mov eax, (CastleGameObject PTR [ecx]).exitNextFrame
	cmp eax, 1
	jne SkipEnd
		INVOKE Sleep, 5000
		INVOKE ExitProcess, 0

	SkipEnd:

	mov ecx, pThis ; // Restore the THIS pointer
	ret
castle_update ENDP

; // ----------------------------------
; // castle_receive_damage
; // The Castle takes damage and triggers end of game if necessary
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
castle_receive_damage PROC PUBLIC USES eax ebx ecx edx esi, damage:DWORD
		local pThis : DWORD
	mov pThis, ecx

	; // Substract damage and end game if HP <= 0
	mov eax, (CastleGameObject PTR [ecx]).HP
	sub eax, damage
	cmp eax, 0
	jg SkipGameEnd
		mov eax, (CastleGameObject PTR [ecx]).team
		mov ecx, (CastleGameObject PTR [ecx]).pLane
		.IF eax == ALLY
			INVOKE game_end, ENEMY
		.ELSE
			INVOKE game_end, ALLY
		.ENDIF
		mov ecx, pThis
		mov (CastleGameObject PTR [ecx]).exitNextFrame, 1

		SkipGameEnd:
	mov ecx, pThis
	mov (CastleGameObject PTR [ecx]).HP, eax
	mov edx, eax

	mov ecx, pThis
	INVOKE get_first_component_which_is_a, TEXT_COMPONENT_ID
	mov ecx, eax
	INVOKE int_to_string, edx, OFFSET hpTextBuffer
	INVOKE set_text_component_text, OFFSET hpTextBuffer

	ret
castle_receive_damage ENDP

END