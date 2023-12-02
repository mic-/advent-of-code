# Advent of Code 2023 - Day 1: Trebuchet?!, part 2
# Mic, 2023
#
# Usage:
#   java -jar mars.jar nc advent1-2.s pa input.txt
#
#   Delayed branching in Mars is assumed to be disabled.

##########################################################################

.macro ABORT (%message)
.data
    myLabel: .asciiz %message
.text
    li $v0, 4
    la $a0, myLabel
    syscall
    li $v0,10
    syscall
.end_macro

.macro OPEN_FILE (%filename)
    move $a0,%filename
    li $a1,0     # read-only
    li $a2,0     # mode (ignored)
    li $v0,13
    syscall
    bgez $v0,_open_success
    ABORT("Error: Unable to open input file")
_open_success:
.end_macro

.macro CLOSE_FILE (%descriptor)
    move $a0,%descriptor
    li $v0,16
    syscall
.end_macro

##########################################################################

.data
    line_buffer: .space 1024
    line_view:   .space 513

.align 4
    digit_name_hashes: .word 9806, 13430, 8817176, 97881, 93838, 12399, 8310185, 1972769, 234238, 0

##########################################################################

.text
.globl main

# Global register usage:
#   $s0: input file descriptor
#   $s1: current line buffer
#   $s2: next line buffer
#   $s3: offset within current line buffer
#   $s4: length of current line buffer
#   $s5: sum of calibration values

main:
    bgtz $a0,open_input_file
    ABORT("Error: No input file name provided")

open_input_file:
    lw $a0,($a1)
    OPEN_FILE($a0)

process_file:
    move $s0,$v0
    la $s1,line_buffer
    addiu $s2,$s1,512
    li $s3,0
    li $s4,0
    li $s5,0
loop_lines:
    jal read_line
    beq $v0,$zero,end_of_file
    move $a0,$v0
    jal parse_line
    addu $s5,$s5,$v0
    j loop_lines

end_of_file:
    CLOSE_FILE($s0)

    move $a0,$s5
    li $v0,1
    syscall

    li $v0,10
    syscall


read_line:
    la $t0,line_view
    addu $t1,$s1,$s3
_parse_buffer:
    bge $s3,$s4,_fill_buffer
    lbu $t2,($t1)
    addiu $t1,$t1,1
    addiu $s3,$s3,1
    beq $t2,13,_newline
    beq $t2,10,_newline
    sb $t2,($t0)
    addiu $t0,$t0,1
    j _parse_buffer
_newline:
    sb $zero,($t0)
    la $v0,line_view
    jr $ra
_fill_buffer:
    move $t2,$s1
    move $s1,$s2
    move $s2,$t2
    move $a0,$s0
    move $a1,$s1
    li $a2,512
    li $v0,14
    syscall
    move $s4,$v0
    li $s3,0
    addu $t1,$s1,$s3
    bgtz $s4,_parse_buffer
    la $v0,line_view
    beq $t0,$v0,_read_failed
    sb $zero,($t0)
    jr $ra
_read_failed:
    li $v0,0
    jr $ra


parse_line:
    li $t0,0   # first digit
    li $t1,0   # last digit
    li $t3,0   # running name length
    li $t4,0   # running name hash
    li $t5,26  # lowercase alphabet size
    la $t6,digit_name_hashes
_search_digits:
    lbu $t2,($a0)
    addiu $a0,$a0,1
    beq $t2,$zero,_end_of_line
    blt $t2,'0',_search_digits
    bgt $t2,'9',_maybe_name
_found_digit:
    bne $t3,$zero,_not_name
    bne $t0,$zero,_already_have_first_digit
    move $t0,$t2
_already_have_first_digit:
    move $t1,$t2
    j _search_digits
_maybe_name:
    blt $t2,'a',_not_name
    bgt $t2,'z',_not_name
    addiu $t2,$t2,-97
    mul $t4,$t4,$t5
    addu $t4,$t4,$t2           # hash = (hash * 26) + (character -'a')
    addiu $t3,$t3,1
    blt $t3,3,_search_digits   # all digit names are at least 3 characters long
_search_hashes:
    lw $t2,($t6)
    addiu $t6,$t6,4
    beq $t2,$zero,_search_hashes_done
    bne $t2,$t4,_search_hashes
_search_hashes_done:
    bne $t2,$t4,_hash_not_found
    addiu $t2,$t6,-4
    la $t6,digit_name_hashes
    subu $t2,$t2,$t6
    srl $t2,$t2,2
    addiu $t2,$t2,'1'
    subu $a0,$a0,$t3
    addiu $a0,$a0,1            # move back to the character after the start of this match
    li $t3,0
    li $t4,0
    j _found_digit
_hash_not_found:
    la $t6,digit_name_hashes
    lbu $t2,-1($a0)
    beq $t2,$zero,_not_name
    blt $t3,5,_search_digits   # all digit names are at most 5 characters long
    addiu $a0,$a0,1
_not_name:
    subu $a0,$a0,$t3
    li $t3,0
    li $t4,0
    j _search_digits
_end_of_line:
    bge $t3,3,_search_hashes  # maybe the line ended with a digit name?
    bne $t0,$zero,_found_digits
    li $v0,0
    jr $ra
_found_digits:
    addiu $t0,$t0,-48
    addiu $t1,$t1,-48
    sll $t2,$t0,2
    addu $t2,$t2,$t0
    addu $v0,$t2,$t2
    addu $v0,$v0,$t1
    jr $ra