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

.data?
    result           dd ?
    hInputFile       dd ?
    hConsole         dd ?
    bytesRead        dd ?
    szBuffer         db 256 dup (?)
    lineBuffer       db 1024 dup (?)
    szLineView       db 513 dup (?)
    lineBufferOffset dd ?
    lineBufferLength dd ?
    activeLineBuffer dd ?

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
read_line_from_file PROTO STDCALL :DWORD
parse_line PROTO STDCALL :DWORD

;----------------------------------------------------------------------------------------

start:
    invoke GetStdHandle,STD_OUTPUT_HANDLE
    mov [hConsole],eax

    invoke get_filename_from_commandline
    invoke open_file, eax
    mov [hInputFile], eax

    mov [result],0
    mov [lineBufferOffset],0
    mov [lineBufferLength], 0
    mov [activeLineBuffer], OFFSET lineBuffer
    xor edi,edi
loop_lines:
    invoke read_line_from_file, hInputFile
    test eax,eax
    jz end_of_file
    invoke parse_line, eax
    add [result],eax
    jmp loop_lines
end_of_file:
    invoke CloseHandle, hInputFile

    pusha
    invoke wsprintf, ADDR szBuffer, ADDR szFormatSum, result
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


; Read one line from the given file
; @param hFile A handle to the file to read from
; @return A pointer to a zero-terminated string containing the line read, or NULL
;
read_line_from_file PROC hFile:DWORD
    mov esi,[activeLineBuffer]
    lea edi,szLineView
    mov ecx,[lineBufferOffset]
    mov edx,[lineBufferLength]
parse_buffer:
    cmp ecx,edx
    jae buffer_more_data
    mov al,[esi + ecx]
    inc ecx
    cmp al,13
    je newline
    cmp al,10
    je newline
    mov [edi],al
    inc edi
    jmp parse_buffer
newline:
    mov [lineBufferOffset],ecx
    mov byte ptr [edi],0
    lea eax,szLineView
    ret
buffer_more_data:
    mov ebx,512
    mov eax,[activeLineBuffer]
    cmp eax,OFFSET lineBuffer
    je @F
    neg ebx
@@:
    add eax,ebx
    mov [activeLineBuffer],eax
    invoke ReadFile, hFile, eax, 512, ADDR lineBufferLength, NULL
    mov esi,[activeLineBuffer]
    xor ecx,ecx
    mov edx,[lineBufferLength]
    test edx,edx
    jne parse_buffer
    cmp edi,OFFSET szLineView
    ja @F
    xor eax,eax
    ret
@@:
    mov byte ptr [edi],0
    lea eax,szLineView
    ret
read_line_from_file ENDP


; Parse the given line
; @param lpszLine A pointer to a zero-terminated string containing the line to parse
; @return The value first*10+last, where 'first' and 'last' is the first and last digits found on the line
;
parse_line PROC lpszLine:DWORD
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    mov eax,[lpszLine]
search_digits:
    mov bl,[eax]
    test ebx,ebx
    jz end_of_string
    cmp bl,'0'
    jb @F
    cmp bl,'9'
    ja @F
    test ecx,ecx
    cmovz ecx,ebx
    mov edx,ebx
@@:
    inc eax
    jmp search_digits
end_of_string:
    xor eax,eax
    test ecx,ecx
    jz @F
    sub ecx,'0'
    sub edx,'0'
    lea eax,[ecx*4 + ecx]
    lea eax,[eax*2 + edx]
@@:
    ret
parse_line ENDP

END start