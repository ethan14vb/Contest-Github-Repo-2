; // Contains external declarations for all of the public functions in renderer.asm

IFNDEF RENDERER_INC
RENDERER_INC EQU 1

displayBuffer PROTO pBuffer:DWORD
initializeRenderer PROTO
renderCommands PROTO pRenderCommands:DWORD, numCommands:DWORD, pCamera:DWORD

ENDIF