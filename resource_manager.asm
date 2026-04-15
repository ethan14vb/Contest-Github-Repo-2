; // ==================================
; // resource_manager.asm
; // ----------------------------------
; // Responsible for loading and unloading large
; // assets such as textures.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE file_functions.inc

.code
; // ----------------------------------
; // read_line
; // Reads the next line in the input and fills a buffer
; //
; // Input:
; //	esi - Pointer to the start of the string
; //	edi - Pointer to the start of the buffer
; // Registered changed:
; //	esi - Points at the next line
; // ----------------------------------
read_line PROC USES ebx ecx edx edi
	ret
read_line ENDP

; // ----------------------------------
; // load_texture
; // Takes in the name of a file and then loads that file into memory.
; //
; // Returns:
; //	A pointer to the texture created
; // ----------------------------------
load_texture PROC USES ebx ecx edx esi edi, pFilename:DWORD
	local hFile		:DWORD
	local fileSize	:DWORD
	local pTempBuf	:DWORD
	local bytesRead	:DWORD

	; // Load the file into a temporary spot on the heap
	INVOKE CreateFile, pFilename, GENERIC_READ, 1, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov hFile, eax

	INVOKE GetFileSize, hFile, 0
	mov fileSize, eax
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, eax

	INVOKE ReadFile, hFile, pTempBuf, fileSize, ADDR bytesRead, 0
    INVOKE CloseHandle, hFile

	; // Next, parse the .PAM header
	; // More info about .PAM files can be found at netpbm.sourceforge.net/doc/pam.html

	ret
load_texture ENDP

; // ----------------------------------
; // unload_texture
; // Takes a pointer to the texture to unload and destorys it.
; // ----------------------------------
unload_texture PROC, pTexture:DWORD
	mov eax, pTexture
	ret
unload_texture ENDP

END