; // ==================================
; // timer_component.asm
; // ----------------------------------
; // The TimerComponent is a countdown timer and is the simplest 
; // way to handle time-based logic in the engine. When a timer 
; // reaches the end of its wait_time, it will emit the timeout 
; // signal.
; // ==================================

INCLUDE default_header.inc
INCLUDE timer_component.inc
INCLUDE heap_functions.inc

.code
init_timer PROC PUBLIC USES ebx ecx edx esi edi, wait_time : REAL4, one_shot : DWORD, autostart : DWORD
	mov eax, wait_time
	mov eax, one_shot
	mov eax, autostart

	ret
init_timer ENDP

; // ----------------------------------
; // new_timer
; // Allocates memory for a TimerComponent and then calls
; // the initializer method on it.
; // ----------------------------------
new_timer PROC PUBLIC USES ebx ecx edx esi edi, wait_time : REAL4, one_shot : DWORD, autostart : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TimerComponent
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_timer, wait_time, one_shot, autostart

	ret ; // Return with the address of the memory block in HeapAlloc
new_timer ENDP

END