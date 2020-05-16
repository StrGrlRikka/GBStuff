INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

EntryPoint:
    di
    jp Start ;

REPT $150 - $104
    db 0
ENDR

SECTION "Game Code", ROM0

Start:
    ; Turn off the LCD
.waitVBlank
    ld a, [rLY]
    cp 144 ; check if LCD is past VBlank
    jr c, .waitVBlank

    xor a ; ld a, 0 ; 
    ld [rLCDC], a ; 

    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
    ld a, [de] ; grab 1 byte from the source [de]
    ld [hli], a ; load into destination and increment hl
    inc de
    dec bc
    ld a, b ; check if count is 0 since 'dec bc' doesn't update flags
    or c ;
    jr nz, .copyFont

    ld hl, $9800 ; this puts the string at the top left
    ld de, HelloWorldStr
.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a ; check if the byte we just copied is 0
    jr nz, .copyString ; continue if it's not

    ; init display registers
    ld a, %11100100
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; shut down sound
    ld [rNR52], a

    ; turn on screen and display background
    ld a, %10000001
    ld [rLCDC], a

    ; lock up cpu
.lockup
    jr .lockup

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
    db "Hello World!", 0