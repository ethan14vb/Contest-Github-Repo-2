; // ==================================
; // input_manager_objects.asm
; // ----------------------------------
; // Utility objects used by the input_manager.asm
; // ==================================

INCLUDE default_header.inc
INCLUDE input_manager_objects.inc
INCLUDE heap_functions.inc

.code
init_input_binding PROC USES ecx esi, actionID : DWORD, buttonCode : DWORD
	mov esi, actionID
	mov (InputBinding PTR [ecx]).actionID, esi

	mov esi, buttonCode
	mov (InputBinding PTR [ecx]).buttonCode, esi

	mov eax, ecx
	ret
init_input_binding ENDP

new_input_binding PROC PUBLIC USES ecx, actionID : DWORD, buttonCode : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF InputBinding
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_input_binding, actionID, buttonCode

	ret ; // Return with the address of the memory block in HeapAlloc
new_input_binding ENDP

free_input_binding PROC PUBLIC
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_input_binding ENDP

init_virtual_controller PROC USES ecx esi, deviceID : DWORD
	local pThis : DWORD
	mov pThis, ecx

	mov esi, deviceID 
	mov (VirtualController PTR [ecx]).deviceID, esi

	lea ecx, (VirtualController PTR [ecx]).bindings
	INVOKE init_unordered_vector, 10
	
	mov eax, pThis
	ret
init_virtual_controller ENDP

new_virtual_controller PROC PUBLIC USES ecx, deviceID : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF VirtualController
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_virtual_controller, deviceID

	ret ; // Return with the address of the memory block in HeapAlloc
new_virtual_controller ENDP

free_virtual_controller PROC PUBLIC
	local pThis : DWORD
	mov pThis, ecx

	lea ecx, (VirtualController PTR [ecx]).bindings
	INVOKE free_unordered_vector
	
	INVOKE HeapFree, hHeap, 0, pThis
	ret
free_virtual_controller ENDP

END