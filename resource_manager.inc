; // ==================================
; // resource_manager.inc
; // ----------------------------------
; // Responsible for loading and unloading large
; // assets such as textures.
; // ==================================

IFNDEF RESOURCE_MANAGER_INC
RESOURCE_MANAGER_INC EQU 1

load_texture PROTO pFilename:DWORD
unload_texture PROTO pTexture:DWORD

ENDIF