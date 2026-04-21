; // ==================================
; // scene.asm
; // ----------------------------------
; // Scenes are classes that hold a single section of a game. A scene contains a
; // pointer to a list of GameObjects that is updated by the scene_update function.
; // The scene also updates simulations and any game logic that isn't handled directly
; // by GameObjects or their components. At the end of every update, the scene will
; // call the renderer module to render its contents.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE scene.inc
INCLUDE game_object.inc
INCLUDE game_object_ids.inc
INCLUDE renderer.inc
INCLUDE timer_component.inc
INCLUDE render_command.inc
INCLUDE camera.inc
INCLUDE input_manager.inc

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_scene
; // Initializes memory with the contents of a Scene
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_scene PROC PUBLIC USES esi, maxGameObjects : DWORD
	mov esi, ecx ; // Save off my THIS pointer in esi

	lea ecx, (Scene PTR [esi]).camera
	INVOKE init_camera, 0, 0

	lea ecx, (Scene PTR [esi]).gameObjects
	INVOKE init_unordered_vector, maxGameObjects

	lea ecx, (Scene PTR [esi]).startQueue
	INVOKE init_unordered_vector, maxGameObjects

	lea ecx, (Scene PTR [esi]).freeQueue
	INVOKE init_unordered_vector, maxGameObjects
	
	lea ecx, (Scene PTR [esi]).renderCommands
	INVOKE init_unordered_vector, maxGameObjects

	mov ecx, esi ; // Restore my THIS pointer
		
	ret
init_scene ENDP

; // ----------------------------------
; // new_scene
; // Reserves heap space for the scene with parameters and calls the initializer method
; // ----------------------------------
new_scene PROC PUBLIC USES ecx, maxGameObjects : DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Scene
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_scene, maxGameObjects
	mov eax, ecx ; // Now return the THIS pointer

	ret ; // Return with the address of the memory block in HeapAlloc
new_scene ENDP

; // ----------------------------------
; // free_scene
; // Convenient method for freeing a Scene
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_scene PROC PUBLIC
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_scene ENDP


; // ********************************************
; // Class methods
; // ********************************************

; // ----------------------------------
; // instantiate_game_object
; // Adds a game object to the scene's start queue
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
instantiate_game_object PROC PUBLIC USES esi, pGameObject: DWORD
	mov esi, ecx ; // Store the THIS pointer in ecx

	lea ecx, (Scene PTR[ecx]).startQueue
	INVOKE push_back, pGameObject
	
	mov ecx, pGameObject
	mov (GameObject PTR [ecx]).pParentScene, esi ; // Set the parent of the GameObject to THIS Scene
		
	mov ecx, esi ; // Restore the THIS pointer

	ret
instantiate_game_object ENDP

; // ----------------------------------
; // get_first_game_object_which_is_a
; // Returns a pointer to the first GameObject in the scene's gameObjects
; // vector that is the type specified, or NULL if it doesn't exist.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
get_first_game_object_which_is_a PROC PUBLIC USES ecx ebx edx esi, gameObjectType: ENUM_GAME_OBJECT_ID
	local pThis
	mov pThis, ecx

	lea ecx, (Scene PTR [ecx]).gameObjects
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov edx, 0 ; // int i = 0

	; // Iterate through the GameObjects
	.WHILE edx < ebx
		; // esi = gameObjects[i]
		mov esi, [eax + edx * 4]

		mov ecx, (GameObject PTR [esi]).gameObjectType
		.IF ecx == gameObjectType
			mov eax, esi ; // return the pointer to the GameObject
			jmp exit_get_first_game_object_which_is_a
		.ENDIF

		inc edx
	.ENDW

	mov eax, 0 ; // Return NULL if nothing was found
	exit_get_first_game_object_which_is_a:
	ret
get_first_game_object_which_is_a ENDP


; // ----------------------------------
; // queue_free_game_object
; // Queues a GameObject for removal
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
queue_free_game_object PROC PUBLIC USES esi, pGameObject: DWORD
	mov esi, ecx ; // Store the THIS pointer in ecx

	lea ecx, (Scene PTR[ecx]).freeQueue
	INVOKE push_back, pGameObject
	
	mov ecx, pGameObject
	mov (GameObject PTR [ecx]).awaitingFree, 0FFFFFFFFh
		
	mov ecx, esi ; // Restore the THIS pointer
	
	ret
queue_free_game_object ENDP

; // ----------------------------------
; // scene_process_start_queue
; // Moves the GameObjects from the startQueue to the gameObjects vector 
; // and then calls their start() methods.
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
scene_process_start_queue PROC PRIVATE USES eax ebx ecx edx esi edi
	local pThis
	mov pThis, ecx ; // Save the THIS pointer just in case
	mov edx, 0 ; // int i = 0

	lea ecx, (Scene PTR [ecx]).startQueue
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	
	; // Iterate through the Game Objects and add them to the gameObjects vector, then call their start methods
	.WHILE edx < ebx
		mov ecx, pThis
		lea ecx, (Scene PTR[ecx]).startQueue
		mov ebx, (UnorderedVector PTR [ecx]).count
		mov eax, (UnorderedVector PTR [ecx]).pData
		
		; // esi = startQueue[i]
		mov esi, [eax + edx * 4]
		
		; // push the game object startQueue[i] into GameObjects
		mov ecx, pThis
		lea ecx, (Scene PTR [ECX]).gameObjects
		INVOKE push_back, esi
	
		; // call the start() method in the GameObject startQueue[i]
		mov ecx, esi
		INVOKE game_object_start_virtual
		inc edx
	.ENDW

	; // Set the length of startQueue to be 0, effectively clearing it
	mov ecx, pThis
	lea ecx, (Scene PTR [ecx]).startQueue
	mov (UnorderedVector PTR [ecx]).count, 0

	mov ecx, pThis
	ret
scene_process_start_queue ENDP

; // ----------------------------------
; // scene_update_time_sensitive_components
; // Calls the update method on all of the time sensitive components (TimerComponents and TweenComponents)
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
scene_update_time_sensitive_components PROC PRIVATE USES eax ebx ecx edx esi edi, deltaTime: REAL4
	local pThis
	mov pThis, ecx ; // Save the THIS pointer just in case

	mov edx, 0 ; // int i = 0

time_sensitive_components_game_object_loop:
	mov ecx, pThis
	lea ecx, (Scene PTR [ecx]).gameObjects

	mov ebx, (UnorderedVector PTR [ecx]).count

	cmp ebx, 0
	je time_sensitive_components_game_object_loop_exit

	mov eax, (UnorderedVector PTR [ecx]).pData

	; // esi = gameObjects[i]
	mov esi, [eax + edx * 4]

	; // Check if the GameObject is dead
	mov eax, (GameObject PTR [esi]).awaitingFree
	.IF eax != 0
		push ebx
		push edx

		jmp time_sensitive_components_components_loop_exit
	.ENDIF

	push ebx
	push edx

	mov edx, 0		
	
	; // Now loop through the components
time_sensitive_components_components_loop:
	lea ecx, (GameObject PTR [esi]).components
	mov ebx, (UnorderedVector PTR [ecx]).count
	cmp ebx, 0
	je time_sensitive_components_components_loop_exit

	mov eax, (UnorderedVector PTR [ecx]).pData
	; // esi = components[i]
	mov edi, [eax + edx * 4]
	mov ecx, (Component PTR [edi]).componentType

	.IF ecx == TIMER_COMPONENT_ID
		mov ecx, edi
		push eax
		INVOKE timer_update, deltaTime
		pop eax
	.ENDIF

	inc edx
	cmp edx, ebx
	jb time_sensitive_components_components_loop
time_sensitive_components_components_loop_exit:

	; // End of game objects loop
	pop edx
	pop ebx

	inc edx
	cmp edx, ebx
	jb time_sensitive_components_game_object_loop

time_sensitive_components_game_object_loop_exit:
	; // Restore the THIS pointer
	mov ecx, pThis

	ret
scene_update_time_sensitive_components ENDP

; // ----------------------------------
; // scene_update_game_objects
; // Calls the update method of all of the GameObjects in gameObjects
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
scene_update_game_objects PROC PRIVATE USES eax ebx ecx edx esi edi, deltaTime: REAL4
	local pThis
	mov pThis, ecx ; // Save the THIS pointer just in case

	mov edx, 0 ; // int i = 0
	lea ecx, (Scene PTR [ecx]).gameObjects
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	
	; // Iterate through the Game Objects and call their update methods if they are still alive
	.WHILE edx < ebx
		mov ecx, pThis
		lea ecx, (Scene PTR [ecx]).gameObjects
		mov ebx, (UnorderedVector PTR [ecx]).count
		mov eax, (UnorderedVector PTR [ecx]).pData

		; // esi = gameObjects[i]
		mov esi, [eax + edx * 4]

		push eax
		push ebx
		push edx

		; // If the GameObject is pending free, don't update it
		mov eax, (GameObject PTR [esi]).awaitingFree
		.IF eax != 0
			jmp scene_update_game_objects_loop_exit
		.ENDIF

		; // call the update() method in the GameObject gameObjects[i]

		mov ecx, esi
		INVOKE game_object_update_virtual, deltaTime

	scene_update_game_objects_loop_exit:
		pop edx
		pop ebx
		pop eax

		inc edx
	.ENDW

	mov ecx, pThis
	ret
scene_update_game_objects ENDP

; // ----------------------------------
; // scene_free_game_objects
; // Frees the game objects in the freeQueue and removes them from the gameObjects vector
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
scene_free_game_objects PROC PRIVATE USES eax ebx ecx edx esi edi
	local pThis
	mov pThis, ecx ; // Save the THIS pointer just in case

	mov edx, 0 ; // int i = 0

	lea ecx, (Scene PTR [ecx]).freeQueue
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	
	; // Iterate through the freeQueue vector
	; // Remove the element from gameObjects and free it
	.WHILE edx < ebx
		mov ecx, pThis
		lea ecx, (Scene PTR [ecx]).freeQueue
		mov ebx, (UnorderedVector PTR [ecx]).count
		mov eax, (UnorderedVector PTR [ecx]).pData

		; // esi = freeQueue[i]
		mov esi, [eax + edx * 4]

		push eax
		push ebx
		push edx

		; // Remove the element pointer from gameObjects
		mov ecx, pThis
		lea ecx, (Scene PTR [ecx]).gameObjects
		INVOKE remove_element, esi

		; // call the free() method on the GameObject
		mov ecx, esi
		INVOKE game_object_free_virtual

		pop edx
		pop ebx
		pop eax

		inc edx
	.ENDW

	; // Set the length of freeQueue to be 0, effectively clearing it
	mov ecx, pThis
	lea ecx, (Scene PTR [ecx]).freeQueue
	mov (UnorderedVector PTR [ecx]).count, 0

	mov ecx, pThis
	ret
scene_free_game_objects ENDP

; // ----------------------------------
; // scene_render_frame
; // Build the RenderCommand list and pass it to the renderer
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
scene_render_frame PROC PRIVATE USES eax ebx edx esi edi, hWnd:DWORD
	local pThis
	mov pThis, ecx

	; // First clear the render list
	; // Free the render commands
	lea ecx, (Scene PTR [ecx]).renderCommands

	mov eax, (UnorderedVector PTR [ecx]).pData
	mov ebx, (UnorderedVector PTR [ecx]).count

	mov ecx, 0 ; // Loop counter (int i = 0)
	.WHILE ecx < ebx
		mov edx, [eax + ecx * 4] ; // edx = renderCommands[i]

		; // renderCommands[i]->free()
		push ecx
		push ebx
		push eax
		mov ecx, edx
		INVOKE free_render_command
		pop eax
		pop ebx
		pop ecx

		inc ecx ; // i++
	.ENDW

	; // Now set the size to 0
	mov ecx, pThis
	lea ecx, (Scene PTR [ecx]).renderCommands
	mov (UnorderedVector PTR [ecx]).count, 0

	; // Build render list
	mov ecx, pThis
	lea ecx, (Scene PTR [ecx]).gameObjects
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, 0 ; // int i = 0
	
	; // Iterate through the Game Objects
	.WHILE edx < ebx
		mov ecx, pThis
		lea ecx, (Scene PTR [ecx]).gameObjects
		mov ebx, (UnorderedVector PTR [ecx]).count
		mov eax, (UnorderedVector PTR [ecx]).pData

		; // esi = gameObjects[i]
		mov esi, [eax + edx * 4]

		push eax
		push ebx
		push edx

		; // If the object is pending free, skip it
		mov ecx, (GameObject PTR [esi]).awaitingFree
		.IF ecx != 0
			jmp scene_render_frame_loop_exit
		.ENDIF

		; // If it has a SpriteComponent or a RectComponent, add the render command
		; // ----------------------------------------------------------------------
		; // First check if there's a RectComponent
		mov ecx, esi
		INVOKE get_first_component_which_is_a, RECT_COMPONENT_ID
		
		.IF eax != 0
			; // Create the new RenderCommand
			push ebx
			mov ebx, eax

			mov ecx, esi
			INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID ; // Get the transform pointer from the GameObject
			INVOKE new_render_command, eax, ebx

			pop ebx

			; // Add the render command to the RenderCommands list
			mov ecx, pThis
			lea ecx, (Scene PTR [ecx]).renderCommands
			INVOKE push_back, eax 

			jmp scene_render_frame_loop_exit
		.ENDIF

		; // Now check if there's a SpriteComponent
		mov ecx, esi
		INVOKE get_first_component_which_is_a, SPRITE_COMPONENT_ID
		
		.IF eax != 0
			; // Create the new RenderCommand
			push ebx
			mov ecx, esi

			mov ebx, eax
			INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID ; // Get the transform pointer from the GameObject
			INVOKE new_render_command, eax, ebx

			pop ebx

			; // Add the render command to the RenderCommands list
			mov ecx, pThis
			lea ecx, (Scene PTR [ecx]).renderCommands
			INVOKE push_back, eax 

			jmp scene_render_frame_loop_exit
		.ENDIF

		; // Now check if there's a TextComponent
		mov ecx, esi
		INVOKE get_first_component_which_is_a, TEXT_COMPONENT_ID
		
		.IF eax != 0
			; // Create the new RenderCommand
			push ebx
			mov ecx, esi

			mov ebx, eax
			INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID ; // Get the transform pointer from the GameObject
			INVOKE new_render_command, eax, ebx

			pop ebx

			; // Add the render command to the RenderCommands list
			mov ecx, pThis
			lea ecx, (Scene PTR [ecx]).renderCommands
			INVOKE push_back, eax 
				
			jmp scene_render_frame_loop_exit
		.ENDIF

		scene_render_frame_loop_exit:
		; // Restore the pointer to pData and continue
		pop edx
		pop ebx
		pop eax

		inc edx ; // i++
	.ENDW

	mov ecx, pThis
	lea esi, (Scene PTR [ecx]).camera
	lea ecx, (Scene PTR [ecx]).renderCommands
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov edx, 0 ; // int i = 0

	; // Pass render list to renderer
	INVOKE renderCommands, eax, ebx, esi, hWnd
	ret
scene_render_frame ENDP

; // ----------------------------------
; // scene_update
; // Responsible for updating the game objects and simulations every frame.
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
scene_update PROC PUBLIC USES eax ebx ecx edx esi edi, deltaTime: REAL4, hWnd: DWORD
	; // Take Input
	INVOKE updateInput

	; // Process start queue
	INVOKE scene_process_start_queue

	; // Update time sensitive components such as timers and tweens (Tweens are NYI)
	INVOKE scene_update_time_sensitive_components, deltaTime

	; // Update all of the GameObject logic
	INVOKE scene_update_game_objects, deltaTime

	; // NYI Update animator components 

	; // Free any GameObjects that were queued to be freed by gameplay logic
	INVOKE scene_free_game_objects

	; // Render the scene
	INVOKE scene_render_frame, hWnd
	
	ret
scene_update ENDP

END
