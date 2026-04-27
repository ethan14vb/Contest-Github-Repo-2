INCLUDE default_header.inc
INCLUDE input_manager_objects.inc
.code
new_input_binding PROC PUBLIC USES ecx, actionID : DWORD, buttonCode : DWORD
	mov eax, actionID
	mov eax, buttonCode
	ret
new_input_binding ENDP

free_input_binding PROC PUBLIC
	ret
free_input_binding ENDP

new_virtual_controller PROC PUBLIC USES ecx, deviceID : DWORD
	mov eax, deviceID
	ret
new_virtual_controller ENDP

free_virtual_controller PROC PUBLIC
	ret
free_virtual_controller ENDP
END