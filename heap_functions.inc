; // ==================================
; // heap_functions.inc
; // ----------------------------------
; // Functions used for dynamic memory management. This file was
; // added before we learned about heap memory management in class
; // so we could have easy memory management. My resource for this 
; // was the windows API reference and the class ch11 slides.
; // ==================================

IFNDEF HEAP_FUNCTIONS_INC
HEAP_FUNCTIONS_INC EQU 1

; // Constants
HEAP_ZERO_MEMORY          equ 00000008h
HEAP_GENERATE_EXCEPTIONS  equ 00000004h
HEAP_NO_SERIALIZE         equ 00000001h

NULL   EQU 0

; // Types
HANDLE TYPEDEF DWORD

; // Protos
GetProcessHeap	PROTO
HeapAlloc		PROTO,	hHeap:DWORD, dwFlags:DWORD, dwBytes:DWORD
HeapFree		PROTO,	hHeap:DWORD, dwFlags:DWORD, lpMem:DWORD
HeapReAlloc		PROTO,	hHeap:DWORD, dwFlags:DWORD, lpMem:DWORD,	dwBytes:DWORD

initialize_heap PROTO ; // This function is from heap_functions.asm. It gets the handle to the process heap and stores in hHeap

; // Data
EXTERNDEF hHeap:HANDLE ; // the heap handle is defined in heap_functions.asm

ENDIF
