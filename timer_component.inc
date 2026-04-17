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
TimerComponent ENDS

ENDIF