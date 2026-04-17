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
event_connect PROC pInstance : DWORD, pFunction : DWORD
	mov eax, pInstance
	mov eax, pFunction
	ret
event_connect ENDP

; // ----------------------------------
; // event_disconnect
; // Removes the connection from the vector and frees its memory
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
event_disconnect PROC pConnection : DWORD
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
event_fire PROC pArgs : DWORD
	mov eax, pArgs
	ret
event_fire ENDP

END