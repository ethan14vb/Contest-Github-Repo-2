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
INCLUDE event.inc

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_timer
; // Initializes memory with the contents of a TimerComponent
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_timer PROC PUBLIC USES ebx ecx edx esi edi, wait_time : REAL4, one_shot : DWORD, autostart : DWORD
	local pThis
	mov pThis, ecx

	; // Parent constructor
	INVOKE init_component
	mov (Component PTR [ecx]).componentType, TIMER_COMPONENT_ID

	mov esi, wait_time
	mov (TimerComponent PTR [ecx]).wait_time, esi
	mov (TimerComponent PTR [ecx]).time_left, esi ; // time_left should start equal to wait_time
	mov esi, one_shot
	mov (TimerComponent PTR [ecx]).one_shot, esi

	; // Autostart logic
	mov (TimerComponent PTR [ecx]).autostart, 0 ; // Always set autostart to 0
	mov ebx, autostart

	.IF ebx != 0
		mov (TimerComponent PTR [ecx]).paused, 0 ; // Immediately start the timer
	.ELSE
		mov (TimerComponent PTR [ecx]).paused, 0FFFFFFFFh ; // Pause the timer
	.ENDIF

	lea ecx, (TimerComponent PTR [ecx]).timeout
	INVOKE init_event

	mov ecx, pThis
	mov eax, ecx ; // Return the "this" pointer

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

; // ********************************************
; // Instance Methods
; // ********************************************

; // ----------------------------------
; // timer_update
; // Updates the timer and fires the timeout event if ready.
; // This function is meant to be called by the engine, do not
; // call it with GameObjects.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
timer_update PROC PUBLIC USES ebx ecx edx esi edi, deltaTime : REAL4
	local pThis
	mov pThis, ecx

	mov ebx, (TimerComponent PTR [ecx]).paused
	cmp ebx, 0
	jnz timer_update_exit

	; // Update the time_left
	fld (TimerComponent PTR [ecx]).time_left
	fsub deltaTime
	fst (TimerComponent PTR [ecx]).time_left

	; // Find whether the time_left is less than or equal to zero
	fldz
	fcomip st(0), st(1) ; // This is a .686 architecture instruction, it skips the middleman of getting the floating point flags
	fstp st(0)

	jb timer_update_exit

	; // Fire timeout!
	lea ecx, (TimerComponent PTR [ecx]).timeout
	INVOKE event_fire, 0
	
	; // Restart the timer if applicable
	mov ecx, pThis
	mov ebx, (TimerComponent PTR [ecx]).one_shot
	.IF ebx == 0
		; // Restart the timer
		fld (TimerComponent PTR [ecx]).time_left
		fadd (TimerComponent PTR [ecx]).wait_time
		fstp (TimerComponent PTR [ecx]).time_left
		
	.ELSE
		; // Pause the timer
		mov (TimerComponent PTR [ecx]).paused, 0FFFFFFFFh
	.ENDIF

timer_update_exit:
	ret
timer_update ENDP

END