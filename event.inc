; // ==================================
; // event.inc
; // ----------------------------------
; // Contains a list of function callbacks and calls them
; // with parameters when fired.
; // ==================================

IFNDEF EVENT_INC
EVENT_INC EQU 1

INCLUDE unordered_vector.inc

Event STRUCT
	connections UnorderedVector <>
Event ENDS

ENDIF
