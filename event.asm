; // ==================================
; // event.asm
; // ----------------------------------
; // Contains a list of function callbacks and calls them
; // with parameters when fired.
; // ==================================

INCLUDE default_header.inc

.code
event_connect PROC pInstance : DWORD, pFunction : DWORD
	mov eax, pInstance
	mov eax, pFunction
	ret
event_connect ENDP

END