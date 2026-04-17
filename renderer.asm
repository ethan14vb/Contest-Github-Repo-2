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
INCLUDE graph_wind.inc
INCLUDE texture.inc
INCLUDE heap_functions.inc

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

; // Used for getting the screen resolution
SM_CXSCREEN = 0
SM_CYSCREEN = 1
GetSystemMetrics PROTO nIndex : DWORD

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
destX DWORD ?
destY DWORD ?
destW DWORD ?
destH DWORD ?

pScreenBuffer DWORD ?

bmiHeader BITMAPINFOHEADER <40, GAME_WIDTH, -GAME_HEIGHT, 1, 32, 0, 0, 0, 0, 0, 0>

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
; // Renders an RGBA buffer to the screen using StretchDIBits
; // Intended to be used for frame by frame animation. 
; // 
; // Parameters: 
; //	pBuffer DWORD - pointer to the new frame buffer to render. MUST BE GAME_WIDTH * GAME_HEIGHT!!!
; //
; // ----------------------------------
displayBuffer PROC PUBLIC USES esi edi ecx ebx, pBuffer:DWORD, hWnd:HWND
	LOCAL hdc:DWORD
	INVOKE GetDC, hWnd
	mov hdc, eax

	INVOKE StretchDIBits,
		hdc,
		destX, destY,
		destW, destH,
		0, 0,
		GAME_WIDTH, GAME_HEIGHT,
		pBuffer,
		ADDR bmiHeader,
		0,
		SRCCOPY
	
	INVOKE ReleaseDC, hWnd, hdc

	mov eax, pBuffer
	ret
displayBuffer ENDP

; // ----------------------------------
; // calculateAspectRatio
; // Calculates the offset that the game window should be drawn at
; // ----------------------------------
calculateAspectRatio PROC USES ebx ecx edx esi
	local SCREEN_WIDTH : DWORD, SCREEN_HEIGHT : DWORD
	INVOKE GetSystemMetrics, SM_CXSCREEN
	mov SCREEN_WIDTH, eax
	INVOKE GetSystemMetrics, SM_CYSCREEN
	mov SCREEN_HEIGHT, eax

	; // Calculate SCREEN_WIDTH * GAME_HEIGHT
	mov eax, SCREEN_WIDTH
	mov ebx, GAME_HEIGHT
	mul ebx
	mov esi, eax

	; // Calculate SCREEN_HEIGHT * GAME_WIDTH
	mov eax, SCREEN_HEIGHT
	mov ebx, GAME_WIDTH
	mul ebx

	; // Determine if the screen should be displayed with letterboxing or pillarboxing.
	; // Letterboxing is when there are black bars on the top and bottom of the screen,
	; // and pillarboxing is when there are black bars on the right and left.
	cmp esi, eax
	ja pillarboxing

letterboxing:
	mov ecx, SCREEN_WIDTH
	mov destW, ecx
	; //	destH = (ScreenWidth * GameHeight) / GameWidth
	mov eax, esi
	xor edx, edx
	mov ebx, GAME_WIDTH
	div ebx
	mov destH, eax
	jmp calculateXYOffset
		
pillarboxing:
	mov ecx, SCREEN_HEIGHT
	mov destH, ecx
	; //	destW = (ScreenHeight * GameWidth) / GameHeight
	mov eax, SCREEN_HEIGHT
	mov ebx, GAME_WIDTH
	mul ebx
	xor edx, edx
	mov ebx, GAME_HEIGHT
	div ebx
	mov destW, eax

calculateXYOffset:
	; // destX = (ScreenWidth - destW) / 2
	mov eax, SCREEN_WIDTH
	sub eax, destW
	shr eax, 1
	mov destX, eax

	; // destY = (ScreenHeight - destH) / 2
	mov eax, SCREEN_HEIGHT
	sub eax, destH
	shr eax, 1
	mov destY, eax
	
	ret
calculateAspectRatio ENDP

; // ----------------------------------
; // initializeRenderer
; // Initializes the window for rendering by getting the screen resolution 
; // and allocates space for the screen buffer
; // ----------------------------------
initializeRenderer PROC PUBLIC USES eax
	INVOKE calculateAspectRatio

	; // Now initialize the screen buffer
	mov eax, GAME_WIDTH
    imul eax, GAME_HEIGHT
    shl eax, 2

	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS OR HEAP_ZERO_MEMORY, eax
    mov pScreenBuffer, eax

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
	; //	if it is, clamp it to GAME_WIDTH
check_x_end:
	cmp ecx, GAME_WIDTH
	jle set_x_bounds
	mov ecx, GAME_WIDTH

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
	; //	if it is, clamp it to GAME_HEIGHT
check_y_end:
	cmp edx, GAME_HEIGHT
	jle set_y_bounds
	mov edx, GAME_HEIGHT

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
	movzx eax, (RectComponent PTR [edi]).b
	movzx ebx, (RectComponent PTR [edi]).g
	shl ebx, 8
	or eax, ebx
	movzx ebx, (RectComponent PTR [edi]).r
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
	imul eax, GAME_WIDTH
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
; // Private helper. Draws a texture cell to the buffer.
; // Position is relative to camera (unless ignoreCamera set).
; // ----------------------------------
drawSprite PROC PRIVATE USES esi edi ebx ecx edx, pTrans:DWORD, pSprite:DWORD, pCamera:DWORD, pBuffer:DWORD
	local texW:DWORD, texH:DWORD, texPixels:DWORD		; // Texture data

	local sx : DWORD, sy : DWORD						; // buffer coords adjusted for clipping
	local rw : DWORD, rh : DWORD						; // size after clipping

	local srcX : DWORD, srcY : DWORD					; // base position in the texture
	local srcW : DWORD, srcH : DWORD					; // original size of the texture

	local startSrcX : DWORD, startSrcY : DWORD			; // position that the drawing starts from (adjusted for flipping)
	local curSrcX : DWORD, curSrcY : DWORD				; // current position in the source texture while drawing
	local dirX : DWORD, dirY : DWORD					; // direction of printing the texture (either 1 or -1)
	local xCounter:DWORD, endY:DWORD, srcRowBase:DWORD	; // local variables for the draw loop
	
	local clipLeft:DWORD, clipTop:DWORD

	; // Skip if not visible
	mov edi, pSprite
	mov eax, (RenderableComponent PTR [edi]).visible
	test eax, eax
	jz drawSprite_done

	; // Skip the rendering in case of a null pointer
	mov ebx, (SpriteComponent PTR [edi]).pTexture
	test ebx, ebx
	jz drawSprite_done

	mov eax, (Texture PTR [ebx]).w
	mov texW, eax
	mov eax, (Texture PTR [ebx]).h
	mov texH, eax
	mov eax, (Texture PTR [ebx]).pPixels
	mov texPixels, eax

	; // Get base dimensions and source coordinates
	mov eax, (SpriteComponent PTR [edi]).isCell

	.IF eax == 0
		; // Texture is a full image
		mov eax, texW
		mov srcW, eax
		mov rw, eax
	
		mov eax, (Texture PTR [ebx]).h
		mov srcH, eax
		mov rh, eax

		mov srcX, 0
		mov srcY, 0

	.ELSE
		; // Texture is a cell
		mov eax, (SpriteComponent PTR [edi]).cellW
		mov srcW, eax
		mov rw, eax

		mov eax, (SpriteComponent PTR [edi]).cellH
		mov srcH, eax
		mov rh, eax

		mov eax, (SpriteComponent PTR [edi]).cellX
		mov srcX, eax
		mov eax, (SpriteComponent PTR [edi]).cellY
		mov srcY, eax
	.ENDIF

	; // Check if the sprite is of zero height or width
	cmp rw, 0
	jle drawSprite_done
	cmp rh, 0
	jle drawSprite_done

	; // Adjust transform for origin pos
	mov ebx, pTrans
	mov eax, (TransformComponent PTR [ebx]).x
	sub eax, (SpriteComponent PTR [edi]).originX
	mov edx, (TransformComponent PTR [ebx]).y
	sub edx, (SpriteComponent PTR [edi]).originY

	; // Adjust transform for camera pos (if applicable)
	mov ebx, pTrans
	.IF [ebx].TransformComponent.ignoreCamera == 0
		mov esi, pCamera
		sub eax, (Camera PTR [esi]).x
		sub edx, (Camera PTR [esi]).y
	.ENDIF
		
	; // Put screen position
	mov sx, eax
	mov sy, edx

	; // clipping logic (set bounds)
	mov clipLeft, 0
	mov clipTop, 0

	; // Check X clipping
	mov eax, sx
	mov ecx, eax
	add ecx, rw

	cmp eax, 0
	jge check_x_end
	neg eax
	mov clipLeft, eax
	mov sx, 0
	mov eax, 0

check_x_end:
	; // Check rightmost bounds
	cmp ecx, GAME_WIDTH
	jle set_x_bounds
	mov ecx, GAME_WIDTH

set_x_bounds:
	cmp eax, ecx ; // Fail case for if the right and left of the sprite are flipped
	jge drawSprite_done

	sub ecx, eax
	mov rw, ecx

	; // Check y clipping
	mov esi, sy
	mov edx, sy
	add edx, rh

	cmp esi, 0
	jge check_y_end
	neg esi
	mov clipTop, esi
	mov sy, 0
	mov esi, 0

check_y_end:
	; // Check uppermost bounds
	cmp edx, GAME_HEIGHT
	jle set_y_bounds
	mov edx, GAME_HEIGHT

set_y_bounds:
	cmp esi, edx ; // Fail case for if the top and bottom of the sprite are flipped
	jge drawSprite_done

	sub edx, esi
	mov rh, edx

	; // calculate the actual start x position based on flipping
	mov eax, srcX
	mov esi, (SpriteComponent PTR [edi]).flipX
	.IF esi == 0
		mov dirX, 1
		add eax, clipLeft
		mov startSrcX, eax
	.ELSE
		mov dirX, -1
		add eax, srcW
		dec eax
		sub eax, clipLeft
		mov startSrcX, eax
	.ENDIF

	; // calculate the actual start y position based on flipping
	mov ebx, srcY
	mov esi, (SpriteComponent PTR [edi]).flipY
	.IF esi == 0
		mov dirY, 1
		add ebx, clipTop
		mov startSrcY, ebx
	.ELSE
		mov dirY, -1
		add ebx, srcH
		dec ebx
		sub ebx, clipTop
		mov startSrcY, ebx
	.ENDIF

	; // Now draw the sprite
	mov esi, sy
	mov eax, sy
	add eax, rh
	mov endY, eax

	mov eax, startSrcY
	mov curSrcY, eax

yloop_sprite:
	cmp esi, endY
	jge drawSprite_done

	; // Calculate screen buffer pointer
	mov eax, esi
	imul eax, GAME_WIDTH
	add eax, sx
	shl eax, 2
	add eax, pBuffer
	mov edi, eax

	; // Calculate row base
	mov eax, curSrcY
	imul eax, texW
	mov srcRowBase, eax

	mov eax, startSrcX
	mov curSrcX, eax

	mov ebx, rw
	mov xCounter, ebx

xloop_sprite:
	cmp xCounter, 0
	je end_xloop

	; // Get source pixel
	mov eax, srcRowBase
	add eax, curSrcX
	shl eax, 2
	add eax, texPixels
	mov eax, [eax]
	
	mov ebx, [edi]

	; // Blend the alpha value
	bswap eax ; // The bswap instruction was not learned in class. It is used here as an easy way of flipping the DWORD around.
	ror eax, 8

	INVOKE blendColor, eax, ebx

	mov [edi], eax
	add edi, 4

	; // Advance source X
	mov eax, dirX
	add curSrcX, eax

	dec xCounter
	jmp xloop_sprite

end_xloop:
	; // Advance source Y
	mov eax, dirY
	add curSrcY, eax
	
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
renderCommands PROC PUBLIC USES esi ecx edi ebx, pRenderCommands:DWORD, numCommands:DWORD, pCamera:DWORD, hWnd:DWORD
	local pBuffer:DWORD     ; // pointer to the screen pixel buffer
	local key_ptr:DWORD     ; // the RenderCommand pointer being placed during sort
	local key_layer:DWORD   ; // the layer value of key_ptr
	local sort_i:DWORD      ; // outer loop index  (insertion sort)
	local sort_j:DWORD      ; // inner loop index  (insertion sort)

	.IF rendererInitialized == 0 
		INVOKE initializeRenderer
		mov rendererInitialized, 0FFFFFFFFh
	.ENDIF

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
	mov edi, pScreenBuffer
	mov pBuffer, edi
	mov ecx, GAME_WIDTH * GAME_HEIGHT
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
	INVOKE displayBuffer, pBuffer, hWnd
	ret
renderCommands ENDP

END
