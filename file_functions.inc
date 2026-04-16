; // ==================================
; // file_functions.inc
; // ----------------------------------
; // Provides functionality for file IO.
; // ==================================

IFNDEF FILE_FUNCTIONS_INC 
FILE_FUNCTIONS_INC EQU 1

; // ********************************
; // Protos
; // ********************************
; // from learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea
CreateFileA PROTO lpFileName:DWORD, dwDesiredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
CreateFile TEXTEQU <CreateFileA>

; // from learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-readfile
ReadFile PROTO hFile:DWORD, lpBuffer:DWORD, nNumberOfBytesToRead:DWORD, lpNumberOfBytesRead:DWORD, lpOverlapped:DWORD

; // from learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
CloseHandle PROTO hObject:DWORD

; // from learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfilesize
GetFileSize PROTO hFile:DWORD, lpFileSizeHigh:DWORD

; // from learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfilepointer
SetFilePointer PROTO hFile:DWORD, lDistanceToMove:SDWORD, lpDistanceToMoveHigh:DWORD, dwMoveMethod:DWORD

; // ********************************
; // Constants
; // ********************************
GENERIC_READ			= 80000000h
OPEN_EXISTING			= 3
FILE_ATTRIBUTE_NORMAL	= 80h

ENDIF