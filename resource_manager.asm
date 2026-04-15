; // ==================================
; // resource_manager.asm
; // ----------------------------------
; // Responsible for loading and unloading large
; // assets such as textures.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE file_functions.inc

; // Carriage return
CR = 13

.code
; // ----------------------------------
; // read_line
; // Reads the next line in the input and fills a buffer
; // This function is dangerous, please make sure there will always
; // be a guaranteed CR-LF newline after the start index pointed to
; // by esi.
; //
; // Input:
; //	esi - Pointer to the start of the string
; //	edi - Pointer to the start of the buffer
; // Registered changed:
; //	esi - Points at the next line
; // ----------------------------------
read_line PROC USES ebx ecx edx edi
read_line_loop:
	; // Get the current character
	mov al, BYTE PTR [esi]
	inc esi
	
	; // Check if we hit the CR in CRLF
	cmp al, CR
	je read_line_exit

	; // Store the current character into the destination buffer
	mov BYTE PTR [edi], al
	inc edi
	jmp read_line_loop

read_line_exit:
	; // Move past the LF and null terminate the string
	inc esi
	mov BYTE PTR [edi], 0
		
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
	local hFile			:DWORD
	local fileSize		:DWORD
	local pTempBuf		:DWORD
	local bytesRead		:DWORD
	local lineBuf[32]	:BYTE

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
	mov esi, pTempBuf
	lea edi, lineBuf
	INVOKE read_line
	INVOKE read_line
	INVOKE read_line

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