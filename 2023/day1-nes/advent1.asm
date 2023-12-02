; Advent of Code 2023 - Day 1: Trebuchet?!, part 1
; NES version
; Mic, 2023
;
; Assemble with NESASM
;
; Limitations:
;  * Can only handle input files of up to 24kB.
;  * Can only handle results of up to 65536.
;  * Displays the result in hexadecimal notation.

 .inesprg    2			; Two 16k PRG-ROM banks
 .ineschr    1			; One 8k CHR-ROM bank
 .inesmir    1			; Vertical mirroring
 .inesmap    0			; Mapper 0 (NROM)

; Zeropage variables
INPUT_PTR   = $00
FIRST_DIGIT = $02
LAST_DIGIT  = $03
RESULT      = $04
TEMP        = $06

 .bank 0
 .org  $8000

input:
 .incbin "input.txt"
 .db 0

 .include	"io.inc"
 .include	"macros.inc"

 .bank 3
 .org $e000

reset:
    cld
    sei
    ldx    #$00
    txs
    stx    REG_PPUCNT1  ; No NMI
    stx    REG_PPUCNT2  ; Disable screen
    stx    REG_APU_STATUS
    inx
waitvb:
    lda    REG_PPUSTAT
    bpl    waitvb  ; Wait a few frames
    dex
    bpl    waitvb

    set_vram_adr $3F00
    memcpy_fixed_dest REG_VRAMIO,palette,32

    ; Clear name table
    set_vram_adr $2000
    ldy    #$1E         ; 30 rows
    lda    #0
clear_nt:
    ldx    #$20         ; 32 columns
clear_row:
    sta    REG_VRAMIO  ; Write to VRAM, address is auto-incremented
    dex
    bne    clear_row
    dey
    bne    clear_nt

    ; Clear attribute table
    set_vram_adr $23C0
    memset_fixed_dest REG_VRAMIO,#$00,$40

    ldx    #0
    lda    #0
clear_zp:
    sta    <$00,x
    inx
    bne    clear_zp

    lda    #(input%256)
    sta    <INPUT_PTR
    lda    #(input/256)
    sta    <INPUT_PTR+1
    ldy    #0
parse_input:
    ldx    #0
    stx    <FIRST_DIGIT
parse_line:
    lda    [INPUT_PTR],y
    beq    end_of_line
    iny
    bne    no_page_cross
    inc    <INPUT_PTR+1
no_page_cross:
    cmp    #13
    beq    end_of_line
    cmp    #10
    beq    end_of_line
    cmp    #48
    bcc    parse_line
    cmp    #58
    bcs    parse_line
    ldx    <FIRST_DIGIT
    bne    already_have_first_digit
    sta    <FIRST_DIGIT
already_have_first_digit:
    sta    <LAST_DIGIT
    jmp    parse_line
end_of_line:
    tax
    lda    <FIRST_DIGIT
    beq    next_line
    sec
    sbc    #48
    sta    <TEMP
    asl    a
    asl    a
    adc    <TEMP
    asl    a
    adc    <LAST_DIGIT
    sec
    sbc    #48
    sta    <TEMP
    addm16 RESULT,TEMP
next_line:
    cpx    #0
    bne    parse_input

    ; Print result
    set_vram_adr $21CE
    lda    <RESULT+1
    jsr    print_byte
    lda    <RESULT
    jsr    print_byte

    ; Enable screen
    lda    #(PPUCNT2_E_BG | PPUCNT2_NOCLIP_BG | PPUCNT2_COLOR)
    sta    REG_PPUCNT2
    lda    #(PPUCNT1_BG_0000 | PPUCNT1_INC_1 | PPUCNT1_NT_2000)
    sta    REG_PPUCNT1
    set_vram_adr $2000

forever: jmp forever

print_byte:
    tax
    lsr    a
    lsr    a
    lsr    a
    lsr    a
    cmp    #10
    bcc    .lt101
    clc
    adc    #7
.lt101:
    clc
    adc    #$10
    sta    REG_VRAMIO
    txa
    and    #$0f
    cmp    #10
    bcc    .lt102
    clc
    adc    #7
.lt102:
    clc
    adc    #$10
    sta    REG_VRAMIO
    rts

nmi:
irq:
	rti

palette:
    .db 2,32,32,32
    .db 2,14,32,38
    .db 2,3,32,10
    .db 2,3,32,9
    .db 2,32,32,32
    .db 2,19,35,48
    .db 2,19,19,35
    .db 2,51,52,51


; Interrupt vectors
 .bank 3
 .org  $fffa
	.dw   nmi
	.dw   reset
	.dw   irq


; CHR-ROM
 .bank 4
 .org $0000
    ; Font
	.incbin "adore64.pat"
 .org $1000
    .db 0