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
INCLUDE sprite_test_scene.inc
INCLUDE text_component.inc

.data
SHOP_GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET shop_update, OFFSET game_object_exit, OFFSET free_game_object>
timeSinceLastSec REAL4 0.0
iPriceMult REAL4 incomePriceMult

; // ********************************************
; // Text data
; // ********************************************
EXTERNDEF pFontTex : DWORD

P1_MONEY_TEXT_ID EQU 12345
P2_MONEY_TEXT_ID EQU 54321

P1_INCOME_TEXT_ID EQU 11111
P2_INCOME_TEXT_ID EQU 22222

p1CashBuffer BYTE 16 DUP(0)
p2CashBuffer BYTE 16 DUP(0)

p1IncomeBuffer BYTE 16 DUP(0)
p2IncomeBuffer BYTE 16 DUP(0)


testText BYTE "test", 0

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

	mov (ShopGameObject PTR [ecx]).allyCash, 30
	mov (ShopGameObject PTR [ecx]).enemyCash, 30
	mov (ShopGameObject PTR [ecx]).allyIncome, baseIncome
	mov (ShopGameObject PTR [ecx]).enemyIncome, baseIncome
	mov (ShopGameObject PTR [ecx]).allyIncomePrice, baseIncomePrice
	mov (ShopGameObject PTR [ecx]).enemyIncomePrice, baseIncomePrice

	INVOKE new_transform_component, 0, 0, 0FFFFFFFFh
	mov ecx, pThis
	INVOKE add_component, ecx, eax

	; // Create the P1 money text
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (TextComponent PTR [eax]).offsetX, -10
	mov (TextComponent PTR [eax]).offsetY, -900
	mov (Component PTR [eax]).userId, P1_MONEY_TEXT_ID
	mov ecx, pThis
	INVOKE add_component, ecx, eax
	mov ecx, eax
	INVOKE set_text_component_text, OFFSET testText

	; // Create the P2 money text
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (TextComponent PTR [eax]).offsetX, -1830
	mov (TextComponent PTR [eax]).offsetY, -900
	mov (Component PTR [eax]).userId, P2_MONEY_TEXT_ID
	mov ecx, pThis
	INVOKE add_component, ecx, eax
	mov ecx, eax
	INVOKE set_text_component_text, OFFSET testText

	; // Create the P1 income text
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (TextComponent PTR [eax]).offsetX, -10
	mov (TextComponent PTR [eax]).offsetY, -950
	mov (Component PTR [eax]).userId, P1_INCOME_TEXT_ID
	mov ecx, pThis
	INVOKE add_component, ecx, eax
	mov ecx, eax
	INVOKE set_text_component_text, OFFSET testText

	; // Create the P2 income text
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (TextComponent PTR [eax]).offsetX, -1830
	mov (TextComponent PTR [eax]).offsetY, -950
	mov (Component PTR [eax]).userId, P2_INCOME_TEXT_ID
	mov ecx, pThis
	INVOKE add_component, ecx, eax
	mov ecx, eax
	INVOKE set_text_component_text, OFFSET testText

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

int_to_cash_string PROC USES eax ebx ecx edx esi edi, value:DWORD, pBuffer:DWORD, prefixChar:BYTE
	mov eax, value
	mov edi, pBuffer
	mov ebx, 10
	mov ecx, 0

int_to_cash_string_divide_loop:
	mov edx, 0
	div ebx
	push edx
	inc ecx
	cmp eax, 0
	jne int_to_cash_string_divide_loop

	; // Write a prefix symbol
	push eax
	mov al, prefixChar
	mov BYTE PTR [edi], al
	inc edi
	pop eax

int_to_cash_string_pop_loop:
	pop edx
	add dl, '0'
	mov BYTE PTR [edi], dl
	inc edi
	dec ecx
	cmp ecx, 0
	jne int_to_cash_string_pop_loop

	; // Add null terminator
	mov BYTE PTR [edi], 0
	
	ret
int_to_cash_string ENDP

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

	; // Update the money displays
	mov ecx, pThis
	INVOKE get_first_component_with_id, P1_MONEY_TEXT_ID
	mov ecx, eax
	mov esi, pThis
	mov eax, (ShopGameObject PTR [esi]).allyCash
	INVOKE int_to_cash_string, eax, OFFSET p1CashBuffer, '$'
	INVOKE set_text_component_text, OFFSET p1CashBuffer

	mov ecx, pThis
	INVOKE get_first_component_with_id, P2_MONEY_TEXT_ID
	mov ecx, eax
	mov esi, pThis
	mov eax, (ShopGameObject PTR [esi]).enemyCash
	INVOKE int_to_cash_string, eax, OFFSET p2CashBuffer, '$'
	INVOKE set_text_component_text, OFFSET p2CashBuffer

	; // Update the income displays
	mov ecx, pThis
	INVOKE get_first_component_with_id, P1_INCOME_TEXT_ID
	mov ecx, eax
	mov esi, pThis
	mov eax, (ShopGameObject PTR [esi]).allyIncome
	INVOKE int_to_cash_string, eax, OFFSET p1IncomeBuffer, '+'
	INVOKE set_text_component_text, OFFSET p1IncomeBuffer

	mov ecx, pThis
	INVOKE get_first_component_with_id, P2_INCOME_TEXT_ID
	mov ecx, eax
	mov esi, pThis
	mov eax, (ShopGameObject PTR [esi]).enemyIncome
	INVOKE int_to_cash_string, eax, OFFSET p2IncomeBuffer, '+'
	INVOKE set_text_component_text, OFFSET p2IncomeBuffer

	ret
shop_update ENDP

; // ----------------------------------
; // buy_knight
; // Spawns specified knight for given team if enough money is held
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
buy_knight PROC PUBLIC USES eax ebx ecx edx esi edi, knightIndex:DWORD, team:DWORD
		local pThis : DWORD
	mov pThis, ecx

	; // Get knight's cost and current cash
	mov eax, knightIndex
	mov eax, knightCosts[4 * eax]
	.IF team == ALLY
		mov edx, (ShopGameObject PTR [ecx]).allyCash
	.ELSE
		mov edx, (ShopGameObject PTR [ecx]).enemyCash
	.ENDIF

	; // If can afford it, spawn the knight
	.IF edx >= eax
		INVOKE spawn_knight, knightIndex, team
		sub edx, eax

		; // Take away cash used
		.IF team == ALLY
			mov (ShopGameObject PTR [ecx]).allyCash, edx
		.ELSE
			mov (ShopGameObject PTR [ecx]).enemyCash, edx
		.ENDIF
	.ENDIF
		
	ret
buy_knight ENDP

; // ----------------------------------
; // buy_income
; // Increases income for a team if enough money is held
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
buy_income PROC PUBLIC USES ebx ecx edx esi edi, team:DWORD
	; // Get upgrades's cost and current cash
	.IF team == ALLY
		mov eax, (ShopGameObject PTR [ecx]).allyIncomePrice
		mov edx, (ShopGameObject PTR [ecx]).allyCash
	.ELSE
		mov eax, (ShopGameObject PTR [ecx]).enemyIncomePrice
		mov edx, (ShopGameObject PTR [ecx]).enemyCash
	.ENDIF

	; // If can afford it, apply upgrade
	.IF edx >= eax
		sub edx, eax
		.IF team == ALLY
			; // Increases price of future upgrades
			FILD (ShopGameObject PTR [ecx]).allyIncomePrice
			FMUL iPriceMult
			FISTP (ShopGameObject PTR [ecx]).allyIncomePrice

			; // Increases income and substracts cash used
			add (ShopGameObject PTR [ecx]).allyIncome, 3
			mov (ShopGameObject PTR [ecx]).allyCash, edx

			; // Return the new cost
			mov eax, (ShopGameObject PTR[ecx]).allyIncomePrice
		.ELSE
			; // Increases price of future upgrades
			FILD (ShopGameObject PTR [ecx]).enemyIncomePrice
			FMUL iPriceMult
			FISTP (ShopGameObject PTR [ecx]).enemyIncomePrice

			; // Increases income and substracts cash used
			add (ShopGameObject PTR [ecx]).enemyIncome, 3
			mov (ShopGameObject PTR [ecx]).enemyCash, edx

			; // Return the new cost
			mov eax, (ShopGameObject PTR[ecx]).enemyIncomePrice
		.ENDIF
	.ELSE
		; // Return 0 (do not update)
		mov eax, 0
	.ENDIF

	ret
buy_income ENDP

END