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

.code
init_timer PROC PUBLIC USES ebx ecx edx esi edi, wait_time : REAL4, one_shot : DWORD, autostart : DWORD
	mov eax, wait_time
	mov eax, one_shot
	mov eax, autostart

	ret
init_timer ENDP

new_timer PROC PUBLIC USES ebx ecx edx esi edi, wait_time : REAL4, one_shot : DWORD, autostart : DWORD
	mov eax, wait_time
	mov eax, one_shot
	mov eax, autostart
	
	ret
new_timer ENDP

END