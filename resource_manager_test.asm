; // ==================================
; // resource_manager_test.asm
; // ----------------------------------
; // Tests whether the resource_manager properly loads files into memory
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE resource_manager.inc

ExitProcess PROTO STDCALL : DWORD

.data
testFile BYTE "test_drawing.pam", 0

.code
main PROC PUBLIC
	INVOKE initialize_heap
	INVOKE load_texture, OFFSET testFile
	INVOKE unload_texture, eax

	INVOKE ExitProcess, 0
	ret
main ENDP

END main