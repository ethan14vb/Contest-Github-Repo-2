; // ==================================
; // unordered_vector_test.asm
; // ----------------------------------
; // Tests if UnorderedVectors can be created, properly used, and freed
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE unordered_vector.inc

ExitProcess PROTO STDCALL : DWORD

.code
main PROC PUBLIC
	local pUnorderedVector

	INVOKE initialize_heap

	INVOKE new_unordered_vector, 5
	mov pUnorderedVector, eax

	mov ecx, pUnorderedVector
	mov edx, 10
	.WHILE edx > 0
		INVOKE push_back, edx
		dec edx
	.ENDW

	INVOKE push_back, 6 ; // Test if the element can be removed if there are multiple

	mov edx, 0

	INVOKE remove_element, 5
	INVOKE remove_element, 6

	INVOKE free_unordered_vector

	INVOKE ExitProcess, 0
	ret
main ENDP

END main