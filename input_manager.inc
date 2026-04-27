; // ==================================
; // input_manager.inc
; // ----------------------------------
; // The input manager is responsible for determining
; // which keys are currently pressed and providing
; // a convenient method for other files to determine
; // the currently pressed keys. This should be
; // updated on a by-frame basis by a scene.
; // ==================================

IFNDEF INPUT_MANAGER_INC
INPUT_MANAGER_INC EQU 1

INCLUDELIB XInput.lib
INCLUDE unordered_vector.inc
INCLUDE input_manager_objects.inc

; // From learn.microsoft.com/en-us/windows/win32/api/xinput/nf-xinput-xinputgetstate
XInputGetState PROTO dwUserIndex:DWORD, pState:DWORD

; // From learn.microsoft.com/en-us/windows/win32/api/xinput/ns-xinput-xinput_gamepad
XINPUT_GAMEPAD STRUCT
	wButtons      WORD ?
	bLeftTrigger  BYTE ?
	bRightTrigger BYTE ?
	sThumbLX      SWORD ?
	sThumbLY      SWORD ?
	sThumbRX      SWORD ?
	sThumbRY      SWORD ?
XINPUT_GAMEPAD ENDS

; // From learn.microsoft.com/en-us/windows/win32/api/xinput/ns-xinput-xinput_state
XINPUT_STATE STRUCT
	dwPacketNumber DWORD ?
	Gamepad        XINPUT_GAMEPAD <>
XINPUT_STATE ENDS

VK_CODE typedef BYTE 

; // Win32 virtual key codes taken from learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
VK_LEFT		=	025h
VK_UP		=	026h
VK_RIGHT	=	027h
VK_DOWN		=	028h

VK_GAMEPAD_DPAD_UP		= 0CBh
VK_GAMEPAD_DPAD_DOWN	= 0CCh

VK_GAMEPAD_LEFT_THUMBSTICK_UP	= 0D3h	
VK_GAMEPAD_LEFT_THUMBSTICK_DOWN = 0D4h

DEVICE_GAMEPAD_0		= 0
DEVICE_GAMEPAD_1		= 1
DEVICE_GAMEPAD_2		= 2
DEVICE_GAMEPAD_3		= 3
DEVICE_KEYBOARD			= 4

updateInput PROTO
isKeyPressed PROTO vkCode: VK_CODE
isKeyJustPressed PROTO vkCode: VK_CODE

ENDIF
