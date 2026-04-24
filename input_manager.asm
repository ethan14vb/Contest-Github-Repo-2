; // ==================================
; // input_manager.asm
; // ----------------------------------
; // The input manager is responsible for determining
; // which keys are currently pressed and providing
; // a convenient method for other files to determine
; // the currently pressed keys. This should be
; // updated on a by-frame basis by a scene.
; // ==================================

INCLUDE default_header.inc
INCLUDE input_manager.inc

; // This is a Win32 API function that was added to the program out of need, 
; // although we did not learn about it in class. The reason this function is present
; // is because it allows for a "real-time" input system where the hardware is polled
; // at the instant the frame is updated to determine what keys are currently being
; // pressed. Because the function is asynchronous, we can call it at any time and it
; // will reliably spit out the exact keys being pressed.
; // Documentation used: learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getasynckeystate
GetAsyncKeyState PROTO vk_code : DWORD
	
.data
; // Holds the data for the current and previous virtual key inputs
curInputBuffer		BYTE 256 DUP(0)
prevInputBuffer		BYTE 256 DUP(0)

; // Holds the data for the current and previous xbox gamepad states
curGamepadStates	XINPUT_STATE 4 DUP(<>)
prevGamepadStates	XINPUT_STATE 4 DUP(<>)

.code
; // ----------------------------------
; // updateInput
; // This should be called every frame by Scene. Updates the 
; // current and previous buffers.
; // ----------------------------------
updateInput PROC PUBLIC USES ebx ecx edx esi edi
	; // Copy the current buffer to the previous
	cld
    mov esi, OFFSET curInputBuffer
    mov edi, OFFSET prevInputBuffer
    mov ecx, 256
    rep movsb

	; // Get the current input state for all 256 key codes
	mov ebx, 0
	.WHILE ebx <= 0FFh
		INVOKE GetAsyncKeyState, ebx
		test ah, 80h
		jz keyUp

	keyDown:
		mov curInputBuffer[ebx], 80h ; // Set the most significant bit
		jmp endLoop
	keyUp:
		mov curInputBuffer[ebx], 0 ; // Clear the most significant bit
	endLoop:
		inc ebx
	.ENDW

	; // Copy current xbox input to previous
	lea esi, curGamepadStates
	lea edi, prevGamepadStates
	mov ecx, SIZEOF curGamepadStates
	shr ecx, 2
	cld
	rep movsd

	; // Get current xbox states
	lea esi, curGamepadStates[0 * SIZEOF XINPUT_STATE]
	INVOKE XInputGetState, 0, esi
	lea esi, curGamepadStates[1 * SIZEOF XINPUT_STATE]
	INVOKE XInputGetState, 1, esi
	lea esi, curGamepadStates[2 * SIZEOF XINPUT_STATE]
	INVOKE XInputGetState, 2, esi
	lea esi, curGamepadStates[3 * SIZEOF XINPUT_STATE]
	INVOKE XInputGetState, 3, esi

	ret
updateInput ENDP

; // ----------------------------------
; // isKeyPressed
; // Returns 1 if a key is currently pressed and 0 if a key
; // is not currently pressed this frame.
; // ----------------------------------
isKeyPressed PROC PUBLIC USES ebx, vkCode: VK_CODE
	movzx ebx, vkCode
	mov al, curInputBuffer[ebx]
	test al, 80h ; // Test the high bit
	jz keyNotPressed

	; // Key is pressed, return 1
	mov eax, 1
	jmp exitIsKeyPressed

keyNotPressed:
	mov eax, 0

exitIsKeyPressed:
	ret
isKeyPressed ENDP

; // ----------------------------------
; // isKeyJustPressed
; // Returns 1 if a key is just pressed this frame and 0 if the key
; // was not just pressed this frame.
; // ----------------------------------
isKeyJustPressed PROC PUBLIC USES ebx, vkCode: VK_CODE
	mov al, curInputBuffer[vkCode]
	mov bl, prevInputBuffer[vkCode]

	test al, 80h ; // Test the high bit
	jz keyNotJustPressed
	
	; // Test if the key was also pressed last frame
	test bl, 80h
	jnz keyNotJustPressed

	; // Key was just pressed, return 1
	mov eax, 1
	jmp exitIsKeyJustPressed
		
keyNotJustPressed:
	mov eax, 0
exitIsKeyJustPressed:
	ret
isKeyJustPressed ENDP

; // ----------------------------------
; // isActionPressed
; // Returns 1 if an action binding is currently pressed and 0 if not
; // ----------------------------------
isActionPressed PROC PUBLIC USES ebx ecx edx esi edi, pController: DWORD, actionID: DWORD
	mov ecx, pController
	lea ecx, (VirtualController PTR [ecx]).bindings
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, 0

isActionPressedSearch_loop:
    cmp edx, ebx
    jge isActionPressedSearch_loopEnd

    ; // esi = bindings[i]
    mov esi, [eax + edx * 4]

    ; // Check if this binding has the correct action
    mov edi, (InputBinding PTR [esi]).actionID
    cmp edi, actionID
    jne isActionPressed_nextBinding

    mov edi, pController
    mov edi, (VirtualController PTR [edi]).deviceID

	; // Binding found, check for the hardware key press
	.IF edi == DEVICE_KEYBOARD
        mov ecx, (InputBinding PTR [esi]).buttonCode
        
        lea edi, curInputBuffer
        movzx eax, BYTE PTR [edi + ecx]
        
        and eax, 80h 
		.IF eax != 0
			mov eax, 1
			jmp isActionPressed_exit
		.ENDIF
	.ELSE
		; // The device is one of the GAMEPADS
        imul edi, SIZEOF XINPUT_STATE
        lea ecx, curGamepadStates
        add ecx, edi

        mov edi, (InputBinding PTR [esi]).buttonCode

		lea eax, (XINPUT_STATE PTR [ecx]).Gamepad
        movzx eax, (XINPUT_GAMEPAD PTR [eax]).wButtons
        and eax, edi

        .IF eax != 0
            mov eax, 1
			jmp isActionPressed_exit
        .ENDIF
	.ENDIF

isActionPressed_nextBinding:
	inc edx
    jmp isActionPressedSearch_loop

isActionPressedSearch_loopEnd:
	mov eax, 0

isActionPressed_exit:
	ret
isActionPressed ENDP

; // ----------------------------------
; // isActionJustPressed
; // Returns 1 if an action binding is just pressed this frame and 0 if not
; // ----------------------------------
isActionJustPressed PROC PUBLIC USES ebx ecx edx esi edi, pController: DWORD, actionID: DWORD
	mov ecx, pController
	lea ecx, (VirtualController PTR [ecx]).bindings
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, 0

isActionJustPressedSearch_loop:
    cmp edx, ebx
    jge isActionJustPressedSearch_loopEnd

    ; // esi = bindings[i]
    mov esi, [eax + edx * 4]

    ; // Check if this binding has the correct action
    mov edi, (InputBinding PTR [esi]).actionID
    cmp edi, actionID
    jne isActionJustPressed_nextBinding

    mov edi, pController
    mov edi, (VirtualController PTR [edi]).deviceID

	; // Binding found, check for the hardware key press
	.IF edi == DEVICE_KEYBOARD
        mov ecx, (InputBinding PTR [esi]).buttonCode
        
        lea edi, curInputBuffer
        movzx eax, BYTE PTR [edi + ecx]
        and eax, 80h 
        jz isActionJustPressedSearch_loopEnd

        lea edi, prevInputBuffer
        movzx eax, BYTE PTR [edi + ecx]
        and eax, 80h
        jnz isActionJustPressedSearch_loopEnd

        mov eax, 1
		jmp isActionJustPressed_exit
	.ELSE
		; // The device is one of the GAMEPADS
        dec edi ; // Adjust to 0-based index for the gamepad array
        imul edi, SIZEOF XINPUT_STATE

        mov ebx, (InputBinding PTR [esi]).buttonCode

        ; // Check current state
        lea ecx, curGamepadStates
        add ecx, edi
        lea eax, (XINPUT_STATE PTR [ecx]).Gamepad
        movzx eax, (XINPUT_GAMEPAD PTR [eax]).wButtons
        and eax, ebx
        jz isActionJustPressedSearch_loopEnd

        ; // Check previous state
        lea ecx, prevGamepadStates
        add ecx, edi

		lea eax, (XINPUT_STATE PTR [ecx]).Gamepad
        movzx eax, (XINPUT_GAMEPAD PTR [eax]).wButtons
        and eax, ebx
        jnz isActionJustPressedSearch_loopEnd

        mov eax, 1
		jmp isActionJustPressed_exit
	.ENDIF

isActionJustPressed_nextBinding:
	inc edx
    jmp isActionJustPressedSearch_loop

isActionJustPressedSearch_loopEnd:
	mov eax, 0

isActionJustPressed_exit:
	ret
isActionJustPressed ENDP

END
