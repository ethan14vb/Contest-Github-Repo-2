; // ==================================
; // music_player.asm
; // ----------------------------------
; // Plays .wav files using win32 functions.
; // ==================================

INCLUDE default_header.inc
INCLUDE music_player.inc

; // Win32 PlaySound function from learn.microsoft.com/en-us/previous-versions/dd743680(v=vs.85)
; // This function was used because of its pure ease of usage
PlaySound PROTO, pszSound : PTR BYTE, hmod : DWORD, fdwSound : DWORD
INCLUDELIB Winmm.lib

.data
    SND_ASYNC    = 1 ; // The sound should play asynchronously
    SND_LOOP     = 8 ; // The sound should loop when it is finished
    SND_FILENAME = 20000h ; // The pszSound parameter points to a filename

	wavFile BYTE "usefulpix-retro-synthwave-background-soundtrack-341853.wav", 0

.code
playMusic PROC PUBLIC
	INVOKE PlaySound, OFFSET wavFile, 0, SND_ASYNC OR SND_LOOP OR SND_FILENAME
	ret
playMusic ENDP

END