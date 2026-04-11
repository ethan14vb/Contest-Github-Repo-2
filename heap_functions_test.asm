; // ==================================
; // heap_functions_test.asm
; // ----------------------------------
; // For testing heap functionality
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc

ExitProcess PROTO : DWORD

.data
hHeap HANDLE ?
pMemory DWORD ?

.code
main PROC PUBLIC
	; // Get heap handle
	INVOKE GetProcessHeap
	
	.IF eax == NULL
		jmp quit
	.ELSE 
		mov hHeap, eax
	.ENDIF

	; // Allocate memory
	INVOKE HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1000
	.IF eax == NULL
		jmp quit
	.ELSE
		mov pMemory, eax
	.ENDIF

	; // Free memory
	INVOKE HeapFree, hHeap, 0, pMemory

	quit:
	INVOKE ExitProcess, 0
main ENDP

END main
