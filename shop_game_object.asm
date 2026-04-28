; // ==================================
; // shop_game_object.asm
; // ----------------------------------
; // The shop is a subclass of GameObject
; // that handles all logic for both player shops
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE heap_functions.inc
INCLUDE shop_game_object.inc
INCLUDE castle_game_object.inc
INCLUDE lane_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE transform_component.inc
INCLUDE sprite_component.inc

.data
SHOP_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET shop_update, OFFSET game_object_exit, OFFSET free_game_object>
timeSinceLastSec REAL4 0.0

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_shop_game_object
; // Initializes memory with the contents of a ShopGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_shop_game_object PROC PUBLIC USES esi ebx edx
		local pThis
	mov pThis, ecx

	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, SHOP_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET SHOP_GAMEOBJECT_VTABLE

	mov (ShopGameObject PTR [ecx]).allyCash, baseCash
	mov (ShopGameObject PTR [ecx]).enemyCash, baseCash
	mov (ShopGameObject PTR [ecx]).allyCash, baseIncome
	mov (ShopGameObject PTR [ecx]).enemyIncome, baseIncome

	mov ecx, pThis
	mov eax, ecx
	ret
init_shop_game_object ENDP

; // ----------------------------------
; // new_shop_game_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_shop_game_object PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF ShopGameObject
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_shop_game_object

	ret ; // Return with the address of the memory block in HeapAlloc
new_shop_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // shop_update
; // Updates the shop cash values
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
shop_update PROC stdcall USES eax ebx ecx edx esi edi, deltaTime: REAL4
local pThis : DWORD
	mov pThis, ecx
	mov eax, deltaTime
	
	; // Count up to a second
	FLD timeSinceLastSec
	FADD deltaTime
	FSTP timeSinceLastSec

	FLD1
	FLD timeSinceLastSec
	FCOMPP
	FNSTSW ax	; // get floating point comparison into flags
	SAHF
	jb SkipIncome

	; // Remove second from the counter and keep decimal
	FLD timeSinceLastSec
	FLD1
	FSUB
	FST timeSinceLastSec
	
	; // Add respective incomes
	mov eax, (ShopGameObject PTR [ecx]).allyIncome
	add (ShopGameObject PTR [ecx]).allyCash, eax
	mov eax, (ShopGameObject PTR [ecx]).enemyIncome
	add (ShopGameObject PTR [ecx]).enemyCash, eax

	SkipIncome:
	ret
shop_update ENDP
END