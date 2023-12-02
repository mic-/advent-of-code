; Various macros for NESASM
; /Mic, 2005


 .include "io.inc"
 
 

;--------------------------
;         Video
;--------------------------

set_vram_adr .macro
 	lda #(\1 / 256)
 	sta REG_VRAMADR2
 	lda #(\1 % 256)
 	sta REG_VRAMADR2
 .endm
 
 
dma_sprites .macro
	lda	#$0
	sta	REG_OBJADR
	lda	#\1
	sta	REG_OBJDMA
 .endm




;--------------------------
;       Arithmetic
;--------------------------


; Shift the operand left a given number of bits (max 8)
asli .macro
	IF (\2 > 0)
	asl \1
	ENDIF
	IF (\2 - 1 > 0)
	asl \1
	ENDIF
	IF (\2 - 2 > 0)
	asl \1
	ENDIF
	IF (\2 - 3 > 0)
	asl \1
	ENDIF
	IF (\2 - 4 > 0)
	asl \1
	ENDIF
	IF (\2 - 5 > 0)
	asl \1
	ENDIF
	IF (\2 - 6 > 0)
	asl \1
	ENDIF
	IF (\2 - 7 > 0)
	asl \1
	ENDIF
 .endm


; Shift the operand right a given number of bits (max 8)
lsri .macro
	IF (\2 > 0)
	lsr \1
	ENDIF
	IF (\2 - 1 > 0)
	lsr \1
	ENDIF
	IF (\2 - 2 > 0)
	lsr \1
	ENDIF
	IF (\2 - 3 > 0)
	lsr \1
	ENDIF
	IF (\2 - 4 > 0)
	lsr \1
	ENDIF
	IF (\2 - 5 > 0)
	lsr \1
	ENDIF
	IF (\2 - 6 > 0)
	lsr \1
	ENDIF
	IF (\2 - 7 > 0)
	lsr \1
	ENDIF
 .endm

 
clr .macro
	lda #0
	sta \1
 .endm


add .macro
	clc
	adc \1
 .endm
 

sub .macro
	sec
	sbc \1
 .endm
 
 
; Increments a 16-bit value in memory
inc16 .macro
 	lda \1
 	clc
 	adc #1
 	sta \1
 	lda \1 + 1
 	adc #0
 	sta \1 + 1
 .endm
 
; Adds two 8-bit values in memory
addm .macro
	lda \1
	clc
	adc \2
	sta \1
 .endm

 
; Adds two 16-bit values in memory
addm16 .macro
 	lda \1
 	clc
 	adc \2
 	sta \1
 	lda \1 + 1
 	adc \2 + 1
 	sta \1 + 1
 .endm




;--------------------------
;      Data transfer
;--------------------------

; Stores an 8-bit value in memory
movi .macro
	lda #\2
	sta \1
 .endm
 

mov16 .macro
	lda \2
	sta \1
	lda \2 + 1
	sta \1 + 1
 .endm
 
 
; Stores a 16-bit value in memory
movi16 .macro
 	lda #(\2 % 256)
 	sta \1
 	lda #(\2 / 256)
 	sta \1 + 1
 .endm
  

; Memory copy with fixed destination address
memcpy_fixed_dest .macro
	ldx #0
.x\@:
	lda \2,x
	sta \1
	inx
	cpx #\3
	bne .x\@
 .endm


; Memory copy of a full page (256 bytes) with fixed destination address
memcpy_page_fixed_dest .macro
	ldx #0
.x\@:
	lda \2,x
	sta \1
	inx
	bne .x\@
 .endm
 
 
memset_fixed_dest .macro
 	ldx #\3
 	lda \2
 .x\@:
 	sta \1
 	dex
 	bne .x\@
 .endm
 
 
memcpy .macro
	ldx #0
.x\@:
	lda \2,x
	sta \1,x
	inx
	cpx #\3
	bne .x\@
 .endm


memset .macro
	ldx #0
	lda \2
.x\@:
	sta \1,x
	inx
	cpx #\3
	bne .x\@
 .endm


memcpy_page .macro
	ldx #0
.x\@:
	lda \2,x
	sta \1,x
	inx
	bne .x\@
 .endm


memset_page .macro
	ldx #0
	lda \2
.x\@:
	sta \1,x
	inx
	bne .x\@
 .endm
 