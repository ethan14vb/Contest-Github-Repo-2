; // ==================================
; // include_everything_test.asm
; // ----------------------------------
; // Tests the header guards in the include files and makes sure there are no collisions
; // with names or nested includes.
; //
; // Usage: 
; //	Exclude main.asm from the project and instead include this file, then build,
; // run, and feel free to debug and test.
; // ==================================

INCLUDE default_header.inc ; // Should always be at the top of a program

INCLUDE camera.inc
INCLUDE engine_types.inc
INCLUDE game_object.inc
INCLUDE rect_component.inc
INCLUDE scene.inc
INCLUDE sprite_component.inc
INCLUDE transform_component.inc
INCLUDE render_command.inc
INCLUDE renderer.inc

ExitProcess PROTO STDCALL : DWORD

.code
main PROC PUBLIC
	; // Exit immediately, only test if the includes have collisions.
	INVOKE ExitProcess, 0
main ENDP

END main
