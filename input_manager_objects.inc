IFNDEF INPUT_BINDING_INC
INPUT_BINDING_INC EQU 1

InputBinding STRUCT
	actionID DWORD ?
	buttonCode DWORD ?
InputBinding ENDS

new_input_binding PROTO actionID:DWORD, buttonCode:DWORD
free_input_binding PROTO

VirtualController STRUCT
	deviceID DWORD ?
	bindings UnorderedVector <> 
VirtualController ENDS

new_virtual_controller PROTO deviceID:DWORD
free_virtual_controller PROTO

ENDIF