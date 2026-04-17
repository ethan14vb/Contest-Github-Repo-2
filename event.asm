; // ==================================
; // event.asm
; // ----------------------------------
; // Contains a list of function callbacks and calls them
; // with parameters when fired.
; // ==================================

INCLUDE default_header.inc
INCLUDE event.inc
INCLUDE unordered_vector.inc
INCLUDE heap_functions.inc

.code
; // ********************************************
; // Constructor Methods
; // ********************************************
init_event PROC
	ret
init_event ENDP

new_event PROC
	ret
new_event ENDP

free_event PROC
	ret
free_event ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // event_connect
; // Allocates a new connection and adds it to the vector
; // 
; // Returns:
; //	eax - A pointer to the new connection
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
event_connect PROC PUBLIC USES ebx ecx edx esi edi, pInstance : DWORD, pFunction : DWORD
	; // Create the connection
	push ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Connection
	pop ecx

    mov ebx, pInstance
    mov (Connection PTR [eax]).pInstance, ebx
    mov ebx, pFunction
    mov (Connection PTR [eax]).pFunction, ebx

	; // Add the connection to the vector (ecx points to the connections UnorderedVector)
    push eax
    INVOKE push_back, eax 
	pop eax

    ret
event_connect ENDP

; // ----------------------------------
; // event_disconnect
; // Removes the connection from the vector and frees its memory
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
event_disconnect PROC PUBLIC USES ebx ecx edx esi edi, pConnection : DWORD
	; // The UnorderedVector is at the same offset as the event, so
	; // ecx contains the UnorderedVector pointer
	INVOKE remove_element, pConnection

	; // Free the connection
	INVOKE HeapFree, hHeap, 0, pConnection

	ret
event_disconnect ENDP

; // ----------------------------------
; // event_fire
; // Loops through all connections and calls their functions
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
event_fire PROC PUBLIC USES ebx ecx edx esi edi, pArgs : DWORD
	local pEvent:DWORD
	mov pEvent, ecx

	; // Get the vector data and count
    mov esi, (UnorderedVector PTR [ecx]).pData
    mov edi, (UnorderedVector PTR [ecx]).count

	test edi, edi
	jz event_fire_exit

	; // Iterate backwards through the vector
fire_loop:
    dec edi

	mov ecx, pEvent
    mov esi, (UnorderedVector PTR [ecx]).pData

	; // Get the next element
	mov ebx, [esi + edi * 4]

	; // Push the arguments
	mov eax, pArgs
    push eax

	; // If the listener is an instance, move the "This" pointer into ecx
	mov eax, (Connection PTR [ebx]).pInstance
	.IF eax != 0
		mov ecx, eax
	.ENDIF

	; // Call the function
	mov eax, (Connection PTR [ebx]).pFunction
	call eax

	; // Advanced the loop
	test edi, edi
    jg fire_loop

event_fire_exit:
	ret
event_fire ENDP

END