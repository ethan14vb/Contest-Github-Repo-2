; // ==================================
; // renderer_test.asm
; // ----------------------------------
; // Tests the pixel buffer to ASCII rendering capability by calling the displayBuffer
; // function on a buffer with a solid color. 
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc
INCLUDE renderer.inc
INCLUDE engine_types.inc

ExitProcess PROTO STDCALL : DWORD

.data
screenBuffer Pixel SCREEN_WIDTH * SCREEN_HEIGHT DUP(<0, 128, 128, 255>)

.code
main PROC PUBLIC
	; // Simple barebones test that displays screenBuffer using displayBuffer
	INVOKE initializeRenderer
	INVOKE displayBuffer, OFFSET screenBuffer

	INVOKE ExitProcess, 0
main ENDP

END main
