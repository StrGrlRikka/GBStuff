Label: ; global label. Must be at the beginning of the line!
;   do stuff
    .local; local defines a local label. Must NOT be at the beginning of a line.
    .locald; don't duplicate a label

ThisIsALabel1:
; do stuff
    .local; this is a different local label than the other .local above
    .local; <-- THIS IS THE SAME AS THAT ONE ^ DONT DO THIS.

    ; registers
    ; the gbz80 uses the following registers:
    ; a, f, b, c, d, e, h, and l
    ; a is special as it can store and access memory adresses such as [$DEAD]
    ; f is an 8-bit register. bits 0-3 are always 0 and 4-7 are C, H, N, Z respectively.
    ; C, H, N, Z stand for: (c)arry, (h)alf-carry, add(n)subtract, (z)ero
    ; a flag is set to true when it's bit is 1

    ; Z is the simplest: If an instructions result was 0, then it's set. Otherwise, it's reset.
    ; (inc)rement and (dec)rement: there are both 8bit and 16bit versions of this

    ld b, $FF
    dec b
    ; B = $FE, Z reset
    inc b
    ; B = $FF, Z reset
    inc b
    ; B = $00, Z set
    inc b
    ; B = $01, Z reset
    dec b
    ; B = $00, Z set

    ld b, $FE
    ; B = $FE, Z set (keep in mind, `ld` doesn't affect flags!)
    inc b
    ; B = $FF, Z reset
    ld b, 0
    ; B = $00, Z reset

    ; C - carry
    ; extends the current operation, stores the ninth bit of an overflow

    ; (add) instruction
    ; add a, X -- take a, add X to contents, store in a
    ; you can also do 'add hl, X' but only the Z flag is updated, AND X cannot
    ; be an immediate value
    ld a, $EF
    ld b, $10

    add a, b
    ; A = $EF, Z reset C reset
    add a, b
    ; A = $0F, Z reset, C set
    add a, b
    ; A = $1F, Z reset, C reset
    add a, $E1
    ; A = $00, Z set, C set
    add a, 0
    ; A = $00, Z set, C reset
    ;



    ; adc - add with carry
    ; normally 'add a, X' does 'a = a + X'
    ; 'adc a, X' does ' a = a + X + Carry (0 or 1)'

    ; Add $1337 to hl
    ; Note: destroys A, that means "alters its value"

    ld a, l
    add a, $37 ; Process the low 8 bits...
    ld l, a ; Store back
    ld a, h
    adc a, $13 ; Process the upper 8 bits, counting the carry that may have stemmed from the low 8 bits
    ld h, a

    ; hl = $CAFE

    ld a, l
    add a, $37
    ; A = $37 + $FE = $35, and Carry set
    ld l, a
    ; hl = $CA35

    ld a, h
    adc a, $13 ; A = $13 + $CA + 1 (carry set) = $DE
    ld h, a
    ; hl = $DE35


    ; (sub)tract
    ld a, 3
    ld b, 2

    sub a, b
    ; A = $01, Z reset, C reset
    sub a, b
    ; A = $FF, Z reset, C set
    sub a, $FF
    ; A = $00, Z set, C reset
    sub a, 0
    ; A = $00, Z set, C reset

    ; cp - compare
    ; cp is basically sub but doesn't write back to a
    ld a, 42

    cp a, 10 ; 42 - 10 = 32,  C reset (42 >= 10), Z reset (42 != 10)
    ; Notice how you can chain comparisons? That comes in handy at times
    cp a, 57 ; 42 - 57 = 241, C set   (42 < 57) , Z reset (42 != 57)
    cp a, 42 ; 42 - 42 = 0,   C reset (42 >= 42), Z set   (42 == 42)

    ; and, or, xor 
    ; all operate on the a register, all reset C flag, all can modify Z flag

    ; and operation takes each bit of both operands and sets the corresponding bit only if
    ; both bits are set
    ld a, %01010011
    ld b, %00110101
    and a, b
    ;       A  %0101 0011
    ;       B  %0011 0101
    ;          ----------
    ; A and B  %0001 0001
    ; Now, a = $11

    
    ; or operation takes each bit of both operands and sets the corresponding bit only if
    ; any of both bits is set
    ld a, %01010011
    ld b, %00110101
    or a, b
    ;      A  %0101 0011
    ;      B  %0011 0101
    ;         ----------
    ; A or B  %0111 0111
    ; Now, a = $77

    ; xor operation takes each bit of both operands and sets the corresponding bit only if
    ; both bits differ
    ld a, %01010011
    ld b, %00110101
    xor a, b
    ;       A  %0101 0011
    ;       B  %0011 0101
    ;          ----------
    ; A xor B  %0110 0110
    ; Now, a = $66

    
    ; (ld) instruction
    ; ld destination, source
    ld d, a ; loads data from register a into register d
    ld c, $2A ; loads $2A (42) into register c
    ld hl, $1245 ; loads $12 into h and $45 into l and then combines them
    ld l, $34 ; loads $34 into l and makes 'hl' into $1234 instead of $1245

    ld [$DEAD], a   ; loads data from a into the byte at address [$DEAD]
    ld a, [$BEEF] ; loads the byte [$BEEF] into register a
    ld [$ABAD], l ;
    ld h, [$1DEA] ; < -- ^ these will not work 

    ; register pairs
    ; registers in brackets represent the byte at the address.
    ; thus, if [$C000] is at hl, then [hl] = [$C000]

    ; Ok
    ld a, [de]
    ld [bc], a

    ; Not ok
    ld c, [de]
    ld [de], hl

    ; Ok
    ld a, [hl]
    ld l, [hl]
    ld [hl], c

    ; Not ok
    ld bc, [hl]
    ld [hl], [hl]

    ; 2-byte values are stored with the second bit first (little endian)
    ; for example, if $C0DE would need to be stored as such
    ld h, $DE
    ld l, $C0

    ; push pop
    ; push stores information to the top of the stack
    ; pop retrieves and removes information from the top of the stack
    ; stack is LIFO

    ; sp is the stack register
    ld sp, $DEAD ; Set sp to something

    ; Point hl to the stack, with a signed 8-bit offset
    ld hl, sp+4
    ; Set sp to hl, although this one doesn't have an offset
    ld sp, hl

    ; Edit sp directly (signed 8-bit offset)
    add sp, -4

    ; Save SP to RAM
    ld [$BEEF], sp

    ; Doesn't affect flags
    inc sp
    dec sp
    ;