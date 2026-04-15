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

ExitProcess PROTO STDCALL : DWORD

.code
main PROC PUBLIC
	ret
main ENDP

END main