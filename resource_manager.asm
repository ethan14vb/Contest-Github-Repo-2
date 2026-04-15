; // ==================================
; // resource_manager.asm
; // ----------------------------------
; // Responsible for loading and unloading large
; // assets such as textures.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE file_functions.inc

; // Line feed
LF = 10

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
; //	edi - the end of the target buffer
; // ----------------------------------
read_line PROC USES ebx ecx edx
read_line_loop:
	; // Get the current character
	mov al, BYTE PTR [esi]
	inc esi
	
	; // Check if we hit the LF
	cmp al, LF
	je read_line_exit

	; // Store the current character into the destination buffer
	mov BYTE PTR [edi], al
	inc edi
	jmp read_line_loop

read_line_exit:
	mov BYTE PTR [edi], 0
		
	ret
read_line ENDP

; // ----------------------------------
; // parse_EOL_number
; // Returns the number at the end of a string.
; //
; // Input:
; //	edi - Pointer to the null terminator of the string
; // Returns:
; //	The number value of the string at the end of the line
; // ----------------------------------
parse_EOL_number PROC USES esi ecx ebx edx edi
	xor edx, edx ; // edx = total
	mov ebx, 1 ; // ebx = multiplier
parse_num_loop:
	; // Get the next character
	dec edi
	movzx ecx, BYTE PTR [edi]

	; // Check if the character is a valid number
	cmp cl, '0'
	jl parse_EOL_number_exit
	cmp cl, '9'
	jg parse_EOL_number_exit

	; // It's a valid digit, add the multiplied value to edx
	sub cl, '0'
	mov eax, ecx
	imul eax, ebx
	add edx, eax

	; // Increase the multiplier
	imul ebx, 10
	jmp parse_num_loop

parse_EOL_number_exit:
	mov eax, edx
	ret
parse_EOL_number ENDP

; // ----------------------------------
; // load_texture
; // Takes in the name of a file and then loads that file into memory.
; //
; // Returns:
; //	A pointer to the texture created
; // ----------------------------------
load_texture PROC PUBLIC USES ebx ecx edx esi edi, pFilename:DWORD
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
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, fileSize
	mov pTempBuf, eax

	INVOKE ReadFile, hFile, pTempBuf, fileSize, ADDR bytesRead, 0
    INVOKE CloseHandle, hFile

	; // Next, parse the .PAM header
	; // More info about .PAM files can be found at netpbm.sourceforge.net/doc/pam.html
	mov esi, pTempBuf
	lea edi, lineBuf

	INVOKE read_line ; // Read the P7
	lea edi, lineBuf
	INVOKE read_line ; // Read the GIMP tag
	lea edi, lineBuf

	; // Get the width
	INVOKE read_line
	INVOKE parse_EOL_number 
	lea edi, lineBuf

	ret
load_texture ENDP

; // ----------------------------------
; // unload_texture
; // Takes a pointer to the texture to unload and destorys it.
; // ----------------------------------
unload_texture PROC PUBLIC, pTexture:DWORD
	mov eax, pTexture
	ret
unload_texture ENDP

END