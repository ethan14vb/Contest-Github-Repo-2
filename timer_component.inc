; // ==================================
; // timer_component.inc
; // ----------------------------------
; // The TimerComponent is a countdown timer and is the simplest 
; // way to handle time-based logic in the engine. When a timer 
; // reaches the end of its wait_time, it will emit the timeout 
; // signal.
; // ==================================

IFNDEF TIMER_COMPONENT_INC
TIMER_COMPONENT_INC EQU 1

INCLUDE component.inc

TimerComponent STRUCT
	baseComponent Component <>

	; // Booleans
	autostart	DWORD ?
	one_shot	DWORD ?
	paused		DWORD ?

	; // Members
	wait_time	REAL4 ?
	time_left	REAL4 ?
	timeout		Event <>

TimerComponent ENDS

; // Instance methods
timer_start PROTO
timer_stop PROTO
timer_resume PROTO

timer_update PROTO deltaTime : REAL4 ; // Called by the engine, not for use by GameObjects

; // Constructors
new_timer PROTO wait_time:REAL4, one_shot:DWORD, autostart:DWORD
init_timer PROTO wait_time:REAL4, one_shot:DWORD, autostart:DWORD

ENDIF