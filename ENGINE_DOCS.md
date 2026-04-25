# Working in the engine
This engine provides tools for game development in X86. The engine uses an object-oriented paradigm where classes are structs that have an init method, a free method, and a new method.

Let's say we want to design constructor methods for a class called "MyObject" that inherits from "MyObjectParent" with a struct defined like this:
```asm
MyObject STRUCT
  baseObject MyObjectParent <>  ; // By making a "MyObjectParent" be embedded into the MyObject struct, we inherit all of its fields
  field1 DWORD ?                ; // A template field that is unique to the MyObject class and is not part of the parent
  field2 DWORD ?                ; // Another template field
MyObject ENDS
```

Our parent class, MyObjectParent, will look like this:
```asm
MyObjectParent STRUCT
  parentField  DWORD ? ; // A template parent field. This will be inheritted by all subclasses of MyObjectParent
  pVt          DWORD ? ; // A pointer to the virtual function table override this pointer to override the parent's functions!
MyObjectParent ENDS

; // Virtual function table struct
MyObjectParent_vtable STRUCT
  pDoSomething  DWORD ?    ; // Pointer to the "doSomething" method. If the parent has a pointer to a virtual function table of a subclass, then this method can be overriden
  pFree         DWORD ?    ; // Pointer to a free method that can be overriden in case subclasses need custom destructors.
MyObjectParent_vtable ENDS
```

init methods follow the pattern:
```asm
.data
; // Define our virtual function table for the child. we will replace the parent's pVt with a pointer to this table
MY_OBJECT_VTABLE MyObjectParent_vtable <OFFSET doSomething, OFFSET free_my_object>

.code
; // ----------------------------------
; // init_my_object
; // Initializes memory with the contents of a MyObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_my_object PROC PUBLIC USES ebx ecx edx esi edi, parameter1:DWORD, parameter2:DWORD
  ; // Call parent constructor
  INVOKE init_my_object_parent, 0

  ; // To override functions from our parent class, change the pVt field like this.
  mov (MyObjectParent PTR [ecx]).pVt, OFFSET MY_OBJECT_VTABLE

  ; // The pVt field is a pointer to a virtual function table. This table contains pointers
  ; // to all necessary functions for the class. In our case, the virtual table includes a pointer
  ; // to a doSomething function and a free function.
  ; //
  ; // We replace the pVt field with a pointer to the virtual function table for a MyObject
  ; // defined in the .data section.
  

  ; // Initialize myself (class members, internal data)
  mov esi, parameter1                   ; // Fetch the parameter
  mov (MyObject PTR [ecx]).field1, esi  ; // Store the parameter. Remember that the "This" pointer is stored in ecx

  mov esi, parameter2                   ; // Fetch the parameter
  mov (MyObject PTR [ecx]).field2, esi  ; // Store the parameter
  
  ; // Return the pointer to myself in eax
  mov eax, ecx
  ret
init_my_object ENDP
```

New methods are a wrapper that allocate heap memory for the object and then call the init method, returning the pointer to the address in memory in eax.
```asm
; // ----------------------------------
; // new_my_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_my_object PROC PUBLIC USES ecx, parameter1:DWORD, parameter2:DWORD
  INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF MyObject
  mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
  INVOKE init_my_object, parameter1, parameter2
  
  ret ; // Return with the address of the memory block in HeapAlloc
new_my_object ENDP
```

free methods destruct (if necessary) and then free the object. A free method for MyObject does not need any destruction, so its free method would look like this
```asm
; // ----------------------------------
; // free_my_object
; // Convenient method for freeing a MyObject
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_my_object PROC PUBLIC 
  INVOKE HeapFree, hHeap, 0, ecx
  ret
free_my_object ENDP
```

# VS Project structure overview
The project is structured into Visual Studio filters like this:
<img width="332" height="352" alt="Visual Studio project filter overview" src="https://github.com/user-attachments/assets/d1c2a40b-c8ea-47f5-8c8e-f0e016f22b36" />

- Engine: A filter containing all files that allow the engine to function as well as the main.asm entry point that loads the first scene.
- Engine/Components: Contains the different types of components that can be attached to GameObjects to provide class composition capabilities. Also contains component_ids.inc which has a list of constant unique identifiers for the different types of components.
- Engine/CoreObjects: Contains the core objects used internally within the engine, and also provides core objects that are available to the user such as Event, Texture, Scene, and UnorderedVector.
- Engine/CoreSystems: Core engine functionality including input management, sound systems, rendering, and resource management
- Engine/GameObjectFramework: Contains the GameObject class that all user-defined GameObjects inherit from and also includes game_object_ids.inc. Like component_ids.inc, this file contains a list of unique identifiers for the GameObject types that are crucial for the engine to be able to distinguish them from one another. When adding a new GameObject, be sure to edit this file and give it a unique identifier.
- Engine/Win32Api: Contains code and header files related to Win32. Heap functions, graphical functions, and file functions are defined in these headers.
- Engine/main.asm: The entry point of the project. Creates a window, a blank scene, populates that scene with the user's chosen scene (specified in main.asm), and then updates that frame at 60 FPS.
- GameObjects: Contains the user's custom-made GameObjects.
- Scenes: Contains the user's custom-made Scenes.

# Scenes and the game loop
A Scene is the master container of all GameObjects instantiated in your game. It has a SceneUpdate function that is called by main.asm at a fixed 60 heartbeats per second. SceneUpdate will call the Update method on all GameObjects in the scene and then, at the end of the frame, it will dispatch a list of RenderCommands to the renderer that will display all the GameObjects in the scene if they have visible components.

To create a new scene, use
```asm
new_scene	PROTO gameObjectCapacity : DWORD
```
Because Scenes store their GameObjects in an unordered_vector, their maximum amount of GameObjects is almost unlimited and will be resized if there are more than the initial capacity.

Scenes have a few helper methods used for working with GameObjects. Namely:
```asm
; // REMINDER: Scenes are objects, so to use their instance methods, there is an implied "THIS" pointer to be passed in ecx

get_first_game_object_which_is_a PROTO gameObjectType: ENUM_GAME_OBJECT_ID   ; // A function with a very long name. Pass a GameObjectId and the scene will return the first instance of a GameObject with that Id that is instantiated in the scene
instantiate_game_object PROTO pGameObject: DWORD                             ; // Adds a GameObject to the scene's start queue. The next frame, the GameObject's Start method will be called and it will be added to the main scene GameObject list.
queue_free_game_object PROTO pGameObject: DWORD                              ; // Sets the awaitingFree field of the GameObject to true and then frees the GameObject at the end of the frame.
```

# Adding a new GameObject
To add a new GameObject, create a new .inc and .asm file for the GameObject in the directory. For example:
<img width="334" height="72" alt="Adding a new GameObject" src="https://github.com/user-attachments/assets/214d8de9-ecb5-4b0a-bc31-7f8e10d2bb6a" />

Define the GameObject's STRUCT inside of the .inc file as well as its PUBLIC proto functions 
Define the GameObject's constructors, instance methods, event callbacks, and helper functions inside of its .asm file

Next, the GameObject will need a unique identifier. Go into the Engine/GameObjectFramework directory and find the identifier file
<img width="278" height="90" alt="The GameObjectFramework directory" src="https://github.com/user-attachments/assets/3b56dda4-d5ab-4e1b-8e4a-147afc8e1896" />

Then, add your new game object id to the list
<img width="358" height="52" alt="Adding a new game object id" src="https://github.com/user-attachments/assets/03e3f0b0-3262-4a70-82a1-ac1efd65907d" />

Now you are free to create your initializer method such as in the example at the top of this document with MyObject. Be sure to replace the gameObjectType field with your new game object id and to replace the virtual function table with your new game object's methods
<img width="677" height="352" alt="Using your new game object id" src="https://github.com/user-attachments/assets/da4472cf-0066-4caf-a6b9-9e7df408d05e" />

# Components
Components can be used to suplement classes with extra functionality. You can add them with the add_component static method of a GameObject
```
add_component PROTO pGameObject: DWORD, pComponent: DWORD
```

Here is a library of the available components:
- TransformComponent: Describes where the GameObject's position is in a scene. Has an X field, a Y field, and an ignoreCamera field. ignoreCamera is used for UI elements that shouldn't be panned when the camera moves.
- RectComponent: Describes the color and positions of a rectangle for a GameObject. Requires the GameObject to have a TransformComponent to be rendered in the correct position.
- SpriteComponent: Describes the look of a sprite based on a texture and, if "isCell" is set, can describe the position of the cell in a spriteSheet texture. Also has flipX and flipY fields. Requires the GameObject to have a TransformComponent to be rendered in the correct position.
- TextComponent: Similar to a SpriteComponent. Requires a texture for the font, but also has a pText field for describing a string to be displayed. Requires the GameObject to have a TransformComponent to be rendered in the correct position.
- TimerComponent: A timer that fires a timeout event when it completes. Can be looped, or stopping if one_shot is enabled.
- AnimatorComponent: Given an animation set and a linked SpriteComponent, the AnimatorComponent will adjust the cell in the sprite's spritesheet and fire animation events at specified frame times.

# Events & Callbacks
One of the most powerful additions to the engine is the capability to have events and callbacks. 

Events are similar to signals in Godot. They have an event_fire function that goes through a list of connected functions and calls them with arguments.
The functions of an event are:
```asm
; // Remember ecx is the "this" pointer!!!
------------------------------------------

; // Takes a "this" pointer (or null for static calls) in pInstance and a pointer to the function to connect to the event. Returns the "connection" instance in eax
event_connect PROTO pInstance: DWORD, pFunction: DWORD

; // Disconnects a function from the event and frees the connection. 
event_disconnect PROTO pConnection: DWORD

; // Fire the event. All of the connected callbacks will be called with the arguments given
event_fire PROTO pArgs: DWORD
```

To define a callback function, be sure to include pArgs as a field as it will be passed regardless of whether your function needs arguments
```asm
callback_example PROC PUBLIC USES eax ebx, pArgs:DWORD
	mov ebx, pArgs ; // we don't need any arguments, but move it into a register so MASM won't complain that we didn't use the parameter

  ; // Add your callback function's body code here.
  ; // Remember that ecx is always the "this" pointer, so if this callback belongs to an instance, ecx will still be the "this" pointer

	ret
callback_example ENDP
```

Because pArgs is a single pointer, to use it for actual arguments, define a struct with offsets
```asm
CallbackArgsStruct STRUCT
  arg1 DWORD ?
  arg2 DWORD ?
  arg3 DWORD ?
CalbackArgsStruct ENDS

callback_with_args_example PROC PUBLIC USES eax ebx, pArgs:DWORD
	mov esi, pArgs

  ; // Accessing the arguments
  mov eax, (CallbackArgsStruct PTR [esi]).arg1
  mov ebx, (CallbackArgsStruct PTR [esi]).arg2
  mov edx, (CallbackArgsStruct PTR [esi]).arg3

  ; // Add your callback function's body code here.

	ret
callback_with_args_example ENDP
```


### Important note about events
If you would like to avoid memory leaks (I strongly suggest you try to avoid leaks, but it is a free country after all), you will need to free all connections to an event on cleanup. I suggest making a list of the connections returned by the event_connect function for an instance and freeing all of the connections in the list when the instance is freed.

# Animator Components
This section should provide more clarity on all of the functionality of AnimatorComponents.

AnimatorComponents have a list of animations. Animations can be created by using the AnimationFrame class like this:
```asm
.data
; // Define animation ID constants
ANIM_3_FRAME EQU 1
ANIM_2_FRAME EQU 2

ANIM_EVENT_CODE EQU 99

; // Create the animation frames
three_frame_animation_looped AnimationFrame <0, 32, 16, 16, 0.1, 0>, <16, 32, 16, 16, 0.1, 0>, <32, 32, 16, 16 0.2, 0>
two_frame_animation_with_event AnimationFrame <0, 32, 16, 16, 0.1, 0>, <16, 32, 16, 16, 0.1, ANIM_EVENT_CODE> ; // The event is in the last frame here as ID: 99

; // Create the list of animations
my_animations Animation \
    <ANIM_3_FRAME, OFFSET three_frame_animation, 3, 1>, \
    <ANIM_2_FRAME, OFFSET two_frame_animation_with_event, 2, 0>
```
2 Things to notice for the animation definitions:
--------------------------------------------------
1. ANIM_3_FRAME is defined as being looped, so it will loop until another animation plays. ANIM_2_FRAME is not looped, so it will end on its final frame and fire animFinishedEvent
2. two_frame_animation_with_event has an event code assigned in its final frame. When a frame has a nonzero eventCode, the animator will fire its frameEvent with the parameter of the event ID. This can be used for playing sounds at certain frames of animations (like footsteps), spawning hitboxes, or other custom user functionality.

# Final notes and working with MASM
- Remember that when you call a windows function, eax, ecx, and edx are considered volatile and will likely be clobbered. 
- Please be careful with the heap and be sure to always have classes destruct and clean up after themselves.
- MASM will throw an error if you do not use a procedure parameter.
- MASM will not throw an error, but will mess up your functionality if you write code like this:
```asm
mov (MyObject PTR [ecx]).field1, parameter1
```
In the above code, you are attempting to move from stack memory to somewhere in the heap. This is impossible to do in a single instruction in X86. MASM will not throw an error if you attempt this, but it will cause strange undefined behavior logic errors. Instead, replace it with the following code where the "fetch" and "store" of the data are in two separate instructions.
```asm
mov esi, parameter1
mov (MyObject PTR [ecx]).field1, esi ; // MASM allows for proper functionality when we go from memory to register and register to memory, not memory to memory!!!
```

Have fun coding.
