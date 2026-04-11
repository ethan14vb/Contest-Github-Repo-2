; // ==================================
; // unordered_vector.asm
; // ----------------------------------
; // unordered_vector are dynamic arrays of DWORDs
; // whose contents are not guaranteed to be in the same
; // order after a removal. They are typically used for 
; // pools of GameObject pointers whose order doesn't matter.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE unordered_vector.inc

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_unordered_vector
; // Initializes memory with the contents of an UnorderedVector
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_unordered_vector PROC PUBLIC USES esi, capacity : DWORD
	; // Allocate space for the data
	mov eax, capacity
	shl eax, 2 ; // multiply capacity by 4, SIZEOF DWORD

	push ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, eax
	pop ecx

	mov (UnorderedVector PTR [ecx]).pData, eax

	; // Initialize other member data
	mov (UnorderedVector PTR [ecx]).count, 0
	mov esi, capacity
	mov (UnorderedVector PTR [ecx]).capacity, esi

	mov eax, ecx ; // Return the this pointer
	ret
init_unordered_vector ENDP

; // ----------------------------------
; // new_unordered_vector
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_unordered_vector PROC PUBLIC USES ecx, capacity: DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF UnorderedVector
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_unordered_vector, capacity

	ret
new_unordered_vector ENDP

; // ----------------------------------
; // free_unordered_vector
; // Convenient method for freeing an UnorderedVector
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_unordered_vector PROC PUBLIC USES esi
	; // Free the data list
	mov esi, (UnorderedVector PTR [ecx]).pData
	push ecx
	INVOKE HeapFree, hHeap, 0, esi
	pop ecx

	ret
free_unordered_vector ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // push_back
; // Adds an element to the end of the vector
; // and resizes the vector if necessary.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
push_back PROC PUBLIC USES eax ebx edx edi, element: DWORD
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, (UnorderedVector PTR [ecx]).capacity

	; // Check if the vector needs to be resized first
	.IF ebx == edx
		.IF edx == 0
			mov edx, 1 ; // Avoid a 0 * 2 = 0 situation
		.ENDIF
		; // Double the capacity
		shl edx, 1 
		mov (UnorderedVector PTR [ecx]).capacity, edx
		shl edx, 2 ; // multiply edx by SIZEOF DWORD (multiply by 4)

		; // ReAlloc the data
		push ebx
		push ecx
		push edx
		INVOKE HeapReAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, (UnorderedVector PTR [ecx]).pData, edx
		pop edx
		pop ecx
		pop ebx
		mov (UnorderedVector PTR [ecx]).pData, eax

	.ENDIF

	; // Insert the data
	mov edi, (UnorderedVector PTR [ecx]).pData
	mov eax, (UnorderedVector PTR [ecx]).count
	mov ebx, element

	mov [edi + eax * 4], ebx 
	inc (UnorderedVector PTR [ecx]).count

	ret
push_back ENDP

; // ----------------------------------
; // remove_element
; // O(n) search for the element specified in the
; // unordered_vector and then swaps it with the 
; // element at the end of the vector and then 
; // pops the element at the end.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
remove_element PROC PUBLIC USES edi ebx ecx edx, element: DWORD
	local success
	mov success, 1 ; // Failure return code

	mov edi, ecx ; // Move the THIS pointer to edi

	mov eax, (UnorderedVector PTR [edi]).pData
	mov ebx, (UnorderedVector PTR [edi]).count

	mov ecx, 0
	.WHILE ecx < ebx
		mov edx, [eax + ecx * 4] ; // edx = pData[i]
		
		.IF edx == element
			; // Found the elemnt, swap and pop it
			dec (UnorderedVector PTR [edi]).count ; // "pop" the last element

			mov ebx, (UnorderedVector PTR [edi]).count
			mov edx, [eax + ebx * 4] ; // edx = pData[count - 1]

			mov [eax + ecx * 4], edx ; // Swap the current position with the end position

			mov success, 0 ; // Success return code
		.ELSE
			inc ecx ; // Move to the next index if the element was not found
		.ENDIF
	.ENDW

	mov eax, success

	ret
remove_element ENDP

END