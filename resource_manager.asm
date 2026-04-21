; // ==================================
; // resource_manager.asm
; // ----------------------------------
; // Responsible for loading and unloading large
; // assets such as textures.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE file_functions.inc
INCLUDE texture.inc

; // Line feed
LF = 10

.code
; // ----------------------------------
; // read_line
; // Reads the next line in the input and fills a buffer
; // This function is dangerous, please make sure there will always
; // be a guaranteed LF newline after the start index pointed to
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
	local hFile				:DWORD
	local bytesRead			:DWORD
	local lineBuf[256]		:BYTE
	local headerBuf[512]	:BYTE
	local pHeaderBuf		:DWORD
	local headerSize		:DWORD
	local texWidth			:DWORD
	local texHeight			:DWORD
	local pTex				:DWORD
	local pPixels			:DWORD
	local remainingSize		:DWORD

	; // Load the file into a temporary spot on the heap
	INVOKE CreateFile, pFilename, GENERIC_READ, 1, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov hFile, eax

	; // Read only enough to get the header, 512 bytes is arbitrary but should be enough
	lea eax, headerBuf
	mov pHeaderBuf, eax
	INVOKE ReadFile, hFile, pHeaderBuf, 512, ADDR bytesRead, 0

	; // Next, parse the .PAM header
	; // More info about .PAM files can be found at netpbm.sourceforge.net/doc/pam.html
	lea esi, headerBuf
	lea edi, lineBuf

	INVOKE read_line ; // Pass over the P7
	lea edi, lineBuf
	INVOKE read_line ; // Pass over the GIMP tag
	lea edi, lineBuf

	; // Get the width
	INVOKE read_line
	INVOKE parse_EOL_number 
	mov texWidth, eax
	lea edi, lineBuf

	; // Get the height
	INVOKE read_line
	INVOKE parse_EOL_number 
	mov texHeight, eax
	lea edi, lineBuf

	INVOKE read_line ; // Pass over the depth
	lea edi, lineBuf
	INVOKE read_line ; // Pass over the MAXVAL
	lea edi, lineBuf
	INVOKE read_line ; // Pass over the TUPLTYPE
	lea edi, lineBuf
	INVOKE read_line ; // Pass over the ENDHDR

	; // Store the size of the header
	lea eax, headerBuf
	sub esi, eax
	mov headerSize, esi

	INVOKE new_texture, texWidth, texHeight, 0
	mov pTex, eax

	; // Allocate the permanent home for the texture in memory
	mov eax, texWidth ; // Get the total size (width * height * 4)
    mov ebx, texHeight
    mul ebx
    shl eax, 2

	push eax ; // Store the file size

	INVOKE VirtualAlloc, 0, eax, MEM_COMMIT OR MEM_RESERVE, PAGE_READWRITE
	mov pPixels, eax
	mov ecx, pTex
	mov (Texture PTR [ecx]).pPixels, eax ; // Store the address of the new pixel buffer into the texture header

	; // Read the rest of the file data into the pPixels buffer
	INVOKE SetFilePointer, hFile, headerSize, 0, 0

	pop eax
	mov remainingSize, eax
	INVOKE ReadFile, hFile, pPixels, remainingSize, ADDR bytesRead, 0

	; // Convert from RGBA to BGRA
	mov ecx, remainingSize
	shr ecx, 2
	mov edi, pPixels

load_texture_conversion_loop:
	mov eax, [edi]
	bswap eax
	ror eax, 8
	mov [edi], eax

	add edi, 4
	dec ecx
	jnz load_texture_conversion_loop

	; // Cleanup
	INVOKE CloseHandle, hFile
	mov eax, pTex

	ret
load_texture ENDP

; // ----------------------------------
; // unload_texture
; // Takes a pointer to the texture to unload and destorys it.
; // ----------------------------------
unload_texture PROC PUBLIC, pTexture:DWORD
	mov ecx, pTexture
	mov eax, (Texture PTR [ecx]).pPixels
	INVOKE VirtualFree, eax, 0, MEM_RELEASE
		
	mov ecx, pTexture
	INVOKE free_texture

	ret
unload_texture ENDP

END