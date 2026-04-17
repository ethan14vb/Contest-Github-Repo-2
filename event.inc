; // ==================================
; // event.inc
; // ----------------------------------
; // Contains a list of function callbacks and calls them
; // with parameters when fired.
; // ==================================

IFNDEF EVENT_INC
EVENT_INC EQU 1

INCLUDE unordered_vector.inc

Connection STRUCT
    pInstance DWORD ?		; // This is either the "this" pointer of an instance or 0 for a global function
    pFunction DWORD ?		; // The pointer to the function
Connection ENDS

Event STRUCT
	connections UnorderedVector <>
Event ENDS

event_connect		PROTO		pInstance : DWORD, pFunction : DWORD
event_disconnect	PROTO		pConnection : DWORD
event_fire			PROTO 		pArgs : DWORD

ENDIF
