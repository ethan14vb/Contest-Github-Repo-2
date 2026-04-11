; // ==================================
; // renderer.asm
; // ----------------------------------
; // Responsible for determining how graphics should be displayed
; // and then displaying them to the terminal or other interface
; // that supports pixelated images.
; // ==================================

INCLUDE default_header.inc
INCLUDE engine_types.inc
INCLUDE renderer.inc
INCLUDE camera.inc
INCLUDE render_command.inc

; // ********************************************
; // Windows function prototypes
; // ********************************************
SetConsoleOutputCP PROTO STDCALL : DWORD ; // Used to change the output format to UTF-8

; // Used to enable virtual terminal processing for full RGB support
GetConsoleMode     PROTO STDCALL : DWORD, : DWORD
SetConsoleMode     PROTO STDCALL : DWORD, : DWORD

; // ConsoleCursorInfo STRUCT used by the GetConsoleCursorInfo and SetConsoleCursorInfo functions
CONSOLE_CURSOR_INFO STRUCT
	dwSize      DWORD ?
	bVisible    DWORD ?
CONSOLE_CURSOR_INFO ENDS

; // Used to disable the blinking cursor
GetConsoleCursorInfo PROTO STDCALL : DWORD, : DWORD
SetConsoleCursorInfo PROTO STDCALL : DWORD, : DWORD

; // Windows functions for displaying the text buffer of RGB data.
; //	WriteConsoleA was chosen instead of the Irvine library functions because of its
; //	support for things like virtual terminal processing and greater flexibility.
GetStdHandle       PROTO STDCALL : DWORD
WriteConsoleA      PROTO STDCALL : DWORD, : DWORD, : DWORD, : DWORD, : DWORD
SetConsoleCursorPosition PROTO STDCALL : DWORD, : DWORD

.data
rendererInitialized DWORD 0; // True / False whether the renderer has been initialized where 0 = False

; // Windows function data
STD_OUTPUT_HANDLE = -11
ENABLE_VIRTUAL_TERMINAL_PROCESSING = 4

ConsoleMode DD ?
hConsoleOutput DD ?
bytesWritten DD 0

consoleCursorInfo CONSOLE_CURSOR_INFO <>

; // Constants
CR = 13 ; // Carriage return
LF = 10 ; // Line feed
ESCP = 1Bh ; // ESC character

; // Renderer buffers
screenBuffer Pixel SCREEN_WIDTH * SCREEN_HEIGHT DUP(<0, 0, 0, 255>)
outputTextBuffer DB 100000 DUP(0); // Used for the displayBuffer PROC

.code
; // ----------------------------------
; // writeByteInDecimal
; // Writes a single byte's decimal representation using ASCII characters into a buffer. 
; // 
; // Parameters: 
; //	AL - byte to print
; //    EDI - pointer to the buffer to write text to
; //
; // Registers changed:
; //	EDI - will be adjusted after prints. Does not add null terminator.
; // ----------------------------------
writeByteInDecimal PROC USES ebx
	; // divide by 100
	xor ah, ah
	mov bl, 100
	div bl

	cmp al, 0
	je print_tens

	; // print result (100s place)
	add al, '0' ; // Add 0x30 to display correct ASCII number representation
	mov [edi], al
	inc edi

print_tens:
	mov al, ah
	xor ah, ah

	mov bl, 10
	div bl

	cmp al, 0
	je print_ones

	; // print result (10s place)
	add al, '0'
	mov [edi], al
	inc edi

print_ones:
	; // print remainder (1s place)
	add ah, '0'
	mov[edi], ah	
	inc edi
	ret
writeByteInDecimal ENDP

; // ----------------------------------
; // displayBuffer
; // Renders an RGBA buffer to the screen using ASCII characters.
; // Intended to be used for frame by frame animation. 
; // 
; // Parameters: 
; //	pBuffer DWORD - pointer to the new frame buffer to render. MUST BE SCREEN_WIDTH * SCREEN_HEIGHT!!!
; //
; // ----------------------------------
displayBuffer PROC PUBLIC USES esi edi ecx ebx, pBuffer:DWORD
	mov edi, OFFSET outputTextBuffer ; // move destination text buffer to edi

	INVOKE SetConsoleCursorPosition, hConsoleOutput, 0

	xor ebx, ebx ; // y_index = 0

y_loop:
	cmp ebx, SCREEN_HEIGHT
	jge done

	xor ecx, ecx ; // x_index = 0
x_loop:
	cmp ecx, SCREEN_WIDTH
	jge row_end

	; // Get top pixel
	; // ((y_index * SCREENWIDTH) + x_index) * 2
	mov eax, ebx
	imul eax, SCREEN_WIDTH
	add eax, ecx 
	shl eax, 2
	mov edx, pBuffer
	add edx, eax ; // edx is now the top pixel

	push edx

	; // Get bottom pixel
	; // (((y_index + 1) * SCREENWIDTH) + x_index) * 2
	mov eax, ebx
	inc eax 
	imul eax, SCREEN_WIDTH
	add eax, ecx
	shl eax, 2
	mov edx, pBuffer
	add edx, eax 

	mov eax, edx ; // eax is now the bottom pixel

	pop edx ; // restore the top pixel

	; // Write foreground ANSI prefix (ESC[38;2;RRR;GGG;BBB;m)
	mov BYTE PTR[edi], ESCP
	inc edi
	mov BYTE PTR[edi], '['
	inc edi
	mov BYTE PTR[edi], '3'
	inc edi
	mov BYTE PTR[edi], '8'
	inc edi
	mov BYTE PTR[edi], ';'
	inc edi
	mov BYTE PTR[edi], '2'
	inc edi
	mov BYTE PTR[edi], ';'
	inc edi

	push edx ; // push edx so we can use it
	mov edx, eax

	mov al, [edx]
	call writeByteInDecimal ; // Bottom RRR
	mov BYTE PTR[edi], ';'
	inc edi
	mov al, [edx + 1]
	call writeByteInDecimal ; // Bottom GGG
	mov BYTE PTR[edi], ';'
	inc edi
	mov al, [edx + 2]
	call writeByteInDecimal ; // Bottom BBB
	mov BYTE PTR[edi], 'm'
	inc edi

	pop edx ; // restore edx

	; // Write background ANSI prefix (ESC[48;2;RRR;GGG;BBB;m)
	mov BYTE PTR[edi], ESCP
	inc edi
	mov BYTE PTR[edi], '['
	inc edi
	mov BYTE PTR[edi], '4'
	inc edi
	mov BYTE PTR[edi], '8'
	inc edi
	mov BYTE PTR[edi], ';'
	inc edi
	mov BYTE PTR[edi], '2'
	inc edi
	mov BYTE PTR[edi], ';'
	inc edi
	mov al, [edx]
	call writeByteInDecimal; // Top RRR
	mov BYTE PTR[edi], ';'
	inc edi
	mov al, [edx + 1]
	call writeByteInDecimal; // Top GGG
	mov BYTE PTR[edi], ';'
	inc edi
	mov al, [edx + 2]
	call writeByteInDecimal; // Top BBB
	mov BYTE PTR[edi], 'm'
	inc edi

	; // Write half block
	mov BYTE PTR[edi], 0E2h
	inc edi
	mov BYTE PTR[edi], 096h
	inc edi
	mov BYTE PTR[edi], 084h
	inc edi

	inc ecx
	jmp x_loop

row_end:
	; // Add newline
	mov BYTE PTR[edi], CR
	inc edi
	mov BYTE PTR[edi], LF
	inc edi

	add ebx, 2 ; // y += 2

	jmp y_loop


done: 
	; // Clear RGB formatting
	mov BYTE PTR[edi], ESCP
	inc edi
	mov BYTE PTR[edi], '['
	inc edi
	mov BYTE PTR[edi], '0'
	inc edi
	mov BYTE PTR[edi], 'm'
	inc edi

	; // Call WriteConsoleA to display the frame here
	mov ebx, edi
	sub ebx, OFFSET outputTextBuffer

	INVOKE WriteConsoleA,
		hConsoleOutput,
		OFFSET outputTextBuffer,
		ebx, ; // msgLen
		OFFSET bytesWritten,
		0

	ret

displayBuffer ENDP

; // ----------------------------------
; // initializeRenderer
; // Initializes the console for rendering by switching to UTF-8 format and 
; // enabling virtual terminal processing for full RGB support.
; // 
; // ----------------------------------
initializeRenderer PROC PUBLIC USES eax
	; // Force output to be UTF-8
	INVOKE SetConsoleOutputCP, 65001

	; // Enable virutal terminal processing (Required for RGB functionality)
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov hConsoleOutput, eax

	; // Get the current terminal mode and OR it with ENABLE_VIRTUAL_TERMINAL_PROCESSING
	INVOKE GetConsoleMode, hConsoleOutput, OFFSET ConsoleMode
	or ConsoleMode, ENABLE_VIRTUAL_TERMINAL_PROCESSING
	INVOKE SetConsoleMode, hConsoleOutput, ConsoleMode

	; // Disable the blinking cursor
	INVOKE GetConsoleCursorInfo, hConsoleOutput, OFFSET consoleCursorInfo
	mov consoleCursorInfo.bVisible, 0
	INVOKE SetConsoleCursorInfo, hConsoleOutput, OFFSET consoleCursorInfo

	ret
initializeRenderer ENDP

; // ----------------------------------
; // blendColor
; // Private helper. Blends two colors together based on the alpha value of the foreground.
; // ----------------------------------
blendColor PROC USES ebx ecx edx esi edi, fgColor : DWORD, bgColor : DWORD
local finalColor : DWORD, fgAlpha : DWORD
	mov esi, fgColor
	shr esi, 24 ; // Shift eax right 3 bytes to get alpha by itself

	; // If the fgColor is opaque, return the fgColor
	.IF eax == 0FFh
		mov eax, fgColor
		jmp blendColor_exit
	.ENDIF

	; // If the fgColor is fully transparent, return the bgColor
	.IF eax == 0
		mov eax, bgColor
		jmp blendColor_exit
	.ENDIF

	; // None of the jump conditions apply, so we must do the blending logic
	; // The formula is (fgColor * fgAlpha + bgColor * (255 - fgAlpha)) / 255
	mov fgAlpha, esi
	mov edi, 255
	sub edi, esi ; // 255 - fgAlpha

	mov edx, 0

	; // Red
	mov eax, fgColor
	and eax, 0FFh
	imul eax, esi

	mov ebx, bgColor
	and ebx, 0FFh
	imul ebx, edi ; // Multiply the background color by 255 - fgAlpha

	add eax, ebx
	shr eax, 8  ; // Divide by 256 instead of 255 for speed
	or edx, eax

	; // Green
	mov eax, fgColor
	shr eax, 8 ; // Move 1 byte over
	and eax, 0FFh
	imul eax, esi

	mov ebx, bgColor
	shr ebx, 8
	and ebx, 0FFh
	imul ebx, edi ; // Multiply the background color by 255 - fgAlpha

	add eax, ebx
	shr eax, 8  ; // Divide by 256 instead of 255 for speed
	shl eax, 8
	or edx, eax

	; // Blue
	mov eax, fgColor
	shr eax, 16 ; // Move 2 byte over
	and eax, 0FFh
	imul eax, esi

	mov ebx, bgColor
	shr ebx, 16
	and ebx, 0FFh
	imul ebx, edi ; // Multiply the background color by 255 - fgAlpha

	add eax, ebx
	shr eax, 8  ; // Divide by 256 instead of 255 for speed
	shl eax, 16
	or edx, eax

	; // Set alpha to FFh 
	mov eax, 0FF000000h
	or eax, edx
	
blendColor_exit:
	ret
blendColor ENDP

; // ----------------------------------
; // drawRect
; // Private helper. Draws a filled rectangle to the buffer.
; // Position is relative to camera (unless ignoreCamera set).
; // ----------------------------------
drawRect PROC PRIVATE USES esi edi ebx ecx edx, pTrans:DWORD, pRect:DWORD, pCamera:DWORD, pBuffer:DWORD
	local sx:DWORD, sy:DWORD, rw:DWORD, rh:DWORD, color:DWORD

	; // skip if not visible
	mov edi, pRect
	mov eax, (RenderableComponent PTR [edi]).visible
	test eax, eax
	jz drawRect_done

	; // check w > 0 and h > 0
	mov eax, (RectComponent PTR [edi]).w
	cmp eax, 0
	jle drawRect_done
	mov rw, eax

	mov eax, (RectComponent PTR [edi]).h
	cmp eax, 0
	jle drawRect_done
	mov rh, eax

	; // screen position
	mov ebx, pTrans
	mov eax, (TransformComponent PTR [ebx]).x
	mov edx, (TransformComponent PTR [ebx]).y

	mov ebx, pTrans
	.IF [ebx].TransformComponent.ignoreCamera == 0
		mov esi, pCamera
		sub eax, (Camera PTR [esi]).x
		sub edx, (Camera PTR [esi]).y
	.ENDIF

	mov sx, eax
	mov sy, edx

	; // clipping logic (set bounds)

	; // check that left edge isn't past the left of the screen
	; //	if it is, clamp it to 0
	mov eax, sx
	mov ecx, sx
	add ecx, rw

	cmp eax, 0
	jge check_x_end
	mov eax, 0

	; // check that right edge isn't past the right of the screen
	; //	if it is, clamp it to SCREEN_WIDTH
check_x_end:
	cmp ecx, SCREEN_WIDTH
	jle set_x_bounds
	mov ecx, SCREEN_WIDTH

	; // Check if the left is offscreen
	; //	if it is, don't draw the Rect
set_x_bounds:
	cmp eax, ecx
	jge drawRect_done

	; // Clamp X bounds
	sub ecx, eax
	mov sx, eax
	mov rw, ecx

	; // check that top edge isn't before the bottom of the screen
	; //	if it is, clamp it to 0
	mov esi, sy
	mov edx, sy
	add edx, rh

	cmp esi, 0
	jge check_y_end
	mov esi, 0

	; // check that bottom edge isn't past the bottom of the screen
	; //	if it is, clamp it to SCREEN_HEIGHT
check_y_end:
	cmp edx, SCREEN_HEIGHT
	jle set_y_bounds
	mov edx, SCREEN_HEIGHT

	; // Check if the top is offscreen
	; //	if it is, don't draw the Rect
set_y_bounds:
	cmp esi, edx
	jge drawRect_done
	
	; // Clamp Y bounds
	sub edx, esi
	mov sy, esi
	mov rh, edx

	; // build pixel dword (r g b a)
	movzx eax, (RectComponent PTR [edi]).r
	movzx ebx, (RectComponent PTR [edi]).g
	shl ebx, 8
	or eax, ebx
	movzx ebx, (RectComponent PTR [edi]).b
	shl ebx, 16
	or eax, ebx
	movzx ebx, (RectComponent PTR [edi]).a
	shl ebx, 24
	or eax, ebx
	mov color, eax

	; // draw loops
	mov esi, sy
	mov edx, sy
	add edx, rh
yloop_rect:
	cmp esi, edx
	jge drawRect_done
	mov eax, esi
	imul eax, SCREEN_WIDTH
	add eax, sx
	shl eax, 2
	add eax, pBuffer
	mov edi, eax
	mov ecx, rw
xloop_rect:
	mov eax, color
	mov ebx, [edi] ; // Grab the color underneath

	INVOKE blendColor, eax, ebx

	mov [edi], eax
	add edi, 4
	dec ecx
	jnz xloop_rect
	inc esi
	jmp yloop_rect

drawRect_done:
	ret
drawRect ENDP

; // ----------------------------------
; // drawSprite
; // Private helper. Blits sprite to the buffer.
; // Position is relative to camera (unless ignoreCamera set).
; // Anchor point (originX/originY) is placed at transform position.
; // pTexture must point to a cellW*cellH Pixel buffer.
; // No flipping, no spritesheet stride, no clipping.
; // ----------------------------------
drawSprite PROC PRIVATE USES esi edi ebx ecx edx, pTrans:DWORD, pSprite:DWORD, pCamera:DWORD, pBuffer:DWORD
	local sx:DWORD, sy:DWORD, sw:DWORD, sh:DWORD, pTex:DWORD

	; // skip if not visible
	mov edx, pSprite
	mov eax, (RenderableComponent PTR [edx]).visible
	test eax, eax
	jz drawSprite_done

	; // screen position
	mov ebx, pTrans
	mov eax, (TransformComponent PTR [ebx]).x
	mov edx, (TransformComponent PTR [ebx]).y

	.IF [ebx].TransformComponent.ignoreCamera == 0
		sub eax, (Camera PTR [pCamera]).x
		sub edx, (Camera PTR [pCamera]).y
	.ENDIF
	; // anchor at transform
	sub eax, (SpriteComponent PTR [pSprite]).originX
	sub edx, (SpriteComponent PTR [pSprite]).originY
	mov sx, eax
	mov sy, edx

	; // cell size
	mov eax, (SpriteComponent PTR [pSprite]).cellW
	mov sw, eax
	mov eax, (SpriteComponent PTR [pSprite]).cellH
	mov sh, eax

	; // texture pointer
	mov eax, (SpriteComponent PTR [pSprite]).pTexture
	mov pTex, eax

	; // draw loops
	mov esi, sy
	mov edx, sy
	add edx, sh
yloop_sprite:
	cmp esi, edx
	jge drawSprite_done
	mov eax, esi
	imul eax, SCREEN_WIDTH
	add eax, sx
	shl eax, 2
	add eax, pBuffer
	mov edi, eax
	; // source row in texture
	mov ebx, esi
	sub ebx, sy
	mov eax, sw
	imul ebx, eax
	shl ebx, 2
	add ebx, pTex
	mov ecx, sw
xloop_sprite:
	mov eax, [ebx]
	mov [edi], eax
	add ebx, 4
	add edi, 4
	dec ecx
	jnz xloop_sprite
	inc esi
	jmp yloop_sprite

drawSprite_done:
	ret
drawSprite ENDP

; // ----------------------------------
; // renderCommands
; // Takes the render commands list and camera position,
; // sorts the command pointers by layer (lowest first) using insertion sort,
; // clears the RGB buffer to black, then draws every renderable in
; // sorted order so that lower-layer objects appear behind higher-layer ones.
; //
; // Parameters:
; //	pRenderCommands DWORD - pointer to an array of DWORD pointers,
; //	                        each pointing to a RenderCommand struct.
; //	numCommands     DWORD - number of entries in the array.
; //	pCamera         DWORD - pointer to the active Camera struct.
; // ----------------------------------
renderCommands PROC PUBLIC USES esi ecx edi ebx, pRenderCommands:DWORD, numCommands:DWORD, pCamera:DWORD
	local pBuffer:DWORD     ; // pointer to the screen pixel buffer
	local key_ptr:DWORD     ; // the RenderCommand pointer being placed during sort
	local key_layer:DWORD   ; // the layer value of key_ptr
	local sort_i:DWORD      ; // outer loop index  (insertion sort)
	local sort_j:DWORD      ; // inner loop index  (insertion sort)

	; // ----------------------------------------------------------------
	; // INSERTION SORT
	; // Sort pRenderCommands[0..numCommands-1] in ascending layer order.
	; // Algorithm: for each element i starting at 1, shift all elements
	; // to its left that have a larger layer value one slot to the right,
	; // then insert element i into the gap.
	; // ----------------------------------------------------------------

	; // Nothing to sort when there are fewer than 2 commands
	mov eax, numCommands
	cmp eax, 2
	jl sort_done

	mov sort_i, 1           ; // outer index starts at element 1

sort_outer_loop:
	; // Loop condition: while sort_i < numCommands
	mov eax, sort_i
	cmp eax, numCommands
	jge sort_done

	; // key_ptr = pRenderCommands[sort_i]
	; //   esi = address of pRenderCommands[sort_i]
	; //   eax = the RenderCommand pointer stored there
	mov esi, pRenderCommands
	mov eax, sort_i
	shl eax, 2              ; // byte offset = sort_i * sizeof(DWORD)
	add esi, eax            ; // esi = &pRenderCommands[sort_i]
	mov eax, [esi]          ; // eax = RenderCommand pointer at index sort_i
	mov key_ptr, eax

	; // key_layer = key_ptr->pRenderable->layer
	mov ecx, (RenderCommand PTR [eax]).pRenderable
	mov eax, (RenderableComponent PTR [ecx]).layer
	mov key_layer, eax

	; // sort_j = sort_i - 1  (start scanning leftward from the element before key)
	mov eax, sort_i
	dec eax
	mov sort_j, eax

sort_inner_loop:
	; // Loop condition: while sort_j >= 0
	; // Note: sort_j is a DWORD local. When it wraps below 0 it becomes
	; //       0FFFFFFFFh, which is negative when interpreted as a signed
	; //       value, so the signed "jl" correctly detects the underflow.
	mov eax, sort_j
	cmp eax, 0
	jl sort_insert          ; // j < 0: we've reached the front of the array

	; // Load pRenderCommands[sort_j] and read its layer
	; //   esi = address of pRenderCommands[sort_j]
	; //   ecx = the RenderCommand pointer stored there
	; //   edx = layer value of that command
	mov esi, pRenderCommands
	mov eax, sort_j
	shl eax, 2
	add esi, eax            ; // esi = &pRenderCommands[sort_j]
	mov ecx, [esi]          ; // ecx = RenderCommand pointer at [sort_j]
	mov edx, (RenderCommand PTR [ecx]).pRenderable
	mov edx, (RenderableComponent PTR [edx]).layer

	; // If [sort_j].layer <= key_layer: the key belongs here, stop shifting
	cmp edx, key_layer
	jle sort_insert

	; // [sort_j].layer > key_layer: shift [sort_j] one slot to the right
	; //   pRenderCommands[sort_j + 1] = pRenderCommands[sort_j]
	; //   esi is still &pRenderCommands[sort_j], so esi+4 is [sort_j+1]
	mov eax, [esi]          ; // value at [sort_j]
	mov edi, esi
	add edi, 4              ; // edi = &pRenderCommands[sort_j + 1]
	mov [edi], eax          ; // write shifted value one slot right

	dec sort_j
	jmp sort_inner_loop

sort_insert:
	; // Write key_ptr into pRenderCommands[sort_j + 1]
	; // When sort_j wrapped below 0 (i.e., 0FFFFFFFFh), inc brings it to 0,
	; // which correctly targets index 0 (the very front of the array).
	mov esi, pRenderCommands
	mov eax, sort_j
	inc eax                 ; // sort_j + 1
	shl eax, 2              ; // byte offset
	add esi, eax            ; // esi = &pRenderCommands[sort_j + 1]
	mov eax, key_ptr
	mov [esi], eax          ; // insert key at its sorted position

	inc sort_i
	jmp sort_outer_loop

sort_done:
	; // ----------------------------------------------------------------
	; // CLEAR BUFFER
	; // Fill the screen pixel buffer with solid black (r=0,g=0,b=0,a=255).
	; // ----------------------------------------------------------------
	mov pBuffer, OFFSET screenBuffer
	mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
	mov edi, pBuffer
	mov eax, 0FF000000h
	rep stosd

	; // ----------------------------------------------------------------
	; // RENDER LOOP
	; // Walk the now-sorted pointer array and dispatch each command to
	; // the correct drawing helper (drawRect or drawSprite).
	; // Lower-layer objects were sorted to the front of the array and are
	; // therefore drawn first (background). Higher-layer objects are drawn
	; // last (foreground), painting over earlier layers as expected.
	; // ----------------------------------------------------------------
	mov esi, pRenderCommands
	mov ebx, numCommands

cmd_loop:
	cmp ebx, 0
	je render_done
	dec ebx

	mov eax, [esi]
	mov edx, (RenderCommand PTR [eax]).pRenderable
	mov edx, (Component PTR [edx]).componentType

	.IF edx == RECT_COMPONENT_ID
		INVOKE drawRect, (RenderCommand PTR [eax]).pTransform, (RenderCommand PTR [eax]).pRenderable, pCamera, pBuffer
	.ELSEIF edx == SPRITE_COMPONENT_ID
		INVOKE drawSprite, (RenderCommand PTR [eax]).pTransform, (RenderCommand PTR [eax]).pRenderable, pCamera, pBuffer
	.ENDIF

	add esi, TYPE DWORD
	jmp cmd_loop

render_done:
	.IF rendererInitialized == 0 
		INVOKE initializeRenderer
		mov rendererInitialized, 0FFFFFFFFh
	.ENDIF

	INVOKE displayBuffer, pBuffer
	ret
renderCommands ENDP

END
