; // ==================================
; // heap_functions.asm
; // ----------------------------------
; // Responsible for initializing the heap
; // variables so other modules can use them.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc

.data
hHeap HANDLE ?

.code
initialize_heap PROC
	INVOKE GetProcessHeap
	mov hHeap, eax
	ret
initialize_heap ENDP

END
