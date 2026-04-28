; // ==================================
; // sprite_test_scene.inc
; // ----------------------------------
; // Initializes a scene to have a single sprite to test sprite rendering.
; // ==================================

IFNDEF SPRITE_TEST_SCENE_INC
SPRITE_TEST_SCENE_INC EQU 1

; // ********************************************
; // Input Bindings
; // ********************************************

; // Action Ids
ACTION_UI_LEFT    EQU 1
ACTION_UI_RIGHT   EQU 2
ACTION_LANE_UP    EQU 3
ACTION_LANE_DOWN  EQU 4
ACTION_SELECT     EQU 5

; // Shop Ids
INCO_SHOP_ID	EQU 0
SWOR_SHOP_ID	EQU 1
ARCH_SHOP_ID	EQU 2
HEAV_SHOP_ID	EQU 3

populate_sprite_test_scene PROTO pScene: DWORD
spawn_knight PROTO, knightIndex:DWORD, team:DWORD

ENDIF