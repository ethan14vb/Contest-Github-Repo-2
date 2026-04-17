; // ==================================
; // event.asm
; // ----------------------------------
; // Contains a list of function callbacks and calls them
; // with parameters when fired.
; // ==================================

INCLUDE default_header.inc
INCLUDE event.inc
INCLUDE unordered_vector.inc
INCLUDE heap_functions.inc

.code
event_connect PROC pInstance : DWORD, pFunction : DWORD
	mov eax, pInstance
	mov eax, pFunction
	ret
event_connect ENDP

event_disconnect PROC pConnection : DWORD
	mov eax, pConnection
	ret
event_disconnect ENDP

event_fire PROC pArgs : DWORD
	mov eax, pArgs
	ret
event_fire ENDP

END