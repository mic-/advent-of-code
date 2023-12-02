; Advent of Code 2023 - Day 1: Trebuchet?!, part 1
; Mic, 2023
;
; Usage:
;   ml /c /coff advent1.asm
;   link /SUBSYSTEM:CONSOLE advent1.obj
;   advent1.exe input.txt

.686
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

wsprintf equ <wsprintfA>

INPUT_BUFFER_SIZE equ 1024

.data?
    hInputFile        dd ?
    hConsole          dd ?
    bytesRead         dd ?
    szBuffer          db 256 dup (?)
    inputBuffer       db INPUT_BUFFER_SIZE dup (?)

.data
    szFormatSum db 'Sum of calibration values: %d',13,10,0

.code

PUTS MACRO string
    LOCAL _szStr
    LOCAL _skip
    jmp _skip
    .data
    _szStr db &string&,13,10,0
    .code
    _skip:
    invoke WriteConsole, hConsole, ADDR _szStr ,SIZEOF _szStr, ADDR bytesRead, NULL
ENDM

ABORT MACRO string
    PUTS string
    invoke ExitProcess,0
ENDM

;----------------------------------------------------------------------------------------

get_filename_from_commandline PROTO STDCALL
open_file PROTO STDCALL :DWORD
parse_file PROTO STDCALL :DWORD

;----------------------------------------------------------------------------------------

start:
    invoke GetStdHandle,STD_OUTPUT_HANDLE
    mov [hConsole],eax

    invoke get_filename_from_commandline
    invoke open_file, eax
    mov [hInputFile], eax

    invoke parse_file, hInputFile
    push eax
    invoke CloseHandle, hInputFile
    pop eax

    pusha
    invoke wsprintf, ADDR szBuffer, ADDR szFormatSum, eax
    invoke WriteConsole, hConsole, ADDR szBuffer, eax, ADDR bytesRead, NULL
    popa

    invoke ExitProcess, 0


; Get the name of the input file from the command line
; @return A pointer to the first argument on the command line
;
get_filename_from_commandline PROC
    invoke GetCommandLineA
    mov edi,eax
    mov al,' '
    mov ecx,1024
    repne scasb
    repe scasb
    dec edi
    invoke lstrlenA, edi
    test eax,eax
    jne @F
    ABORT "Error: No input file name provided"
@@:
    mov eax,edi
    ret
get_filename_from_commandline ENDP


; Open the file with the given name
; @param lpszFilename A pointer to the file name
; @return A handle to the opened file
;
open_file PROC lpszFilename:DWORD
    invoke CreateFile,lpszFilename,
                      GENERIC_READ,
                      FILE_SHARE_READ,
                      NULL,OPEN_EXISTING,
                      FILE_ATTRIBUTE_NORMAL,
                      NULL
    cmp eax,INVALID_HANDLE_VALUE
    jne @F
    ABORT "Error: Unable to open input file"
@@:
    ret
open_file ENDP


; Parse all lines in the given file
; @param hFile The file handle
; @return The sum of all rows in the file, where the value of each row
;         is first*10+last, with 'first' and 'last' being the first and
;         last digits found on that line
;
parse_file PROC hFile:DWORD
    LOCAL result:DWORD
    xor ebx,ebx
    mov [result],ebx
    xor edx,edx
    xor esi,esi
    xor edi,edi
parse_input:
    lea eax,inputBuffer
    xor ecx,ecx
parse_line:
    cmp esi,edi
    jb have_data
    pusha
    invoke ReadFile, hFile, eax, INPUT_BUFFER_SIZE, ADDR bytesRead, NULL
    popa
    xor esi,esi
    mov edi,[bytesRead]
    cmp edi,0
    jle end_of_line
have_data:
    mov bl,[eax + esi]
    inc esi
    cmp bl,13
    je end_of_line
    cmp bl,10
    je end_of_line
    cmp bl,'0'
    jb parse_line
    cmp bl,'9'
    ja parse_line
    test ecx,ecx
    cmovz ecx,ebx
    mov edx,ebx
    jmp parse_line
end_of_line:
    test ecx,ecx
    jz @F
    sub ecx,'0'
    sub edx,'0'
    lea eax,[ecx*4 + ecx]
    lea eax,[eax*2 + edx]
    add [result],eax
@@:
    test edi,edi
    jne parse_input
    mov eax,[result]
    ret
parse_file ENDP

END start