(
    Advents of Code 2023 - Day 6: Wait For It, part 1
    Mic, 2023

    Compile with ForthEC
)

-1 constant INVALID_HANDLE_VALUE

variable file-buffer 1024 allot
variable numbers 256 allot
variable num-numbers

: open-file ( filename -- handle )
    notouch
    pop eax
    invoke CreateFile, eax, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    touch a@ ;

: read-file ( handle buffer -- )
    notouch
    pop edi
    pop esi
    invoke ReadFile, esi, edi, 1024, ADDR scratch1, NULL
    mov eax,scratch1
    touch ;

: close-file ( handle -- )
    call CloseHandle ;

: get-commandline ( -- adr )
    call GetCommandLineA a@ ;

: is-digit? ( char -- f )
    dup 48 >= swap 57 <= and ;

: is-neither-digit-nor-null? ( char -- f )
    dup is-digit? swap 0= or not ;

: is-neither-space-nor-null? ( char -- f )
    dup 32 = swap 0= or not ;

: find-next-space ( adr -- adr )
    begin dup c@ is-neither-space-nor-null? while 1+ repeat ;

: find-next-digit ( adr -- adr )
    begin dup c@ is-neither-digit-nor-null? while 1+ repeat ;

: find-next-word ( adr -- adr )
    begin dup c@ 32 = while 1+ repeat ;

: find-nth-word ( adr n -- adr )
    dup 1 > if
        1- 0 do find-next-word find-next-space loop
    else
        drop
    then
    find-next-word ;

\ Returns negative on error
: get-next-number ( adr -- adr n )
    find-next-digit dup c@ 0= if
        -1
    else
        0 swap begin dup c@ is-digit? while
            dup c@ 48 - rot 10 * + swap
            1+ repeat swap
    then ;

: parse-numbers ( output-buffer input-buffer -- n )
    over swap
    begin get-next-number dup 0 >= while
        rot swap !r+ swap repeat drop
    drop swap - 8 / ;

\ Only returns the positive root
: solve-quadratic ( p q -- x )
    fswap 2.0e0 f/
    fswap fover fdup f* fswap f- fsqrt
    fswap f- ;

: optimal-press-time ( available-time -- optimal-time )
    2.0e0 f/ ;

: max-distance ( available-time -- distance )
    fdup optimal-press-time fswap fover f- f* ;

: ways-to-win ( record-distance race-time -- n )
    fdup optimal-press-time fswap max-distance
    frot 1.0e0 f+ f- fnegate 1.0e0 fswap solve-quadratic
    fover fswap f-                  \ shortest possible press time
    fswap fover fover fswap f- f+   \ longest possible press time
    fix 1+ fix - ;


get-commandline 2 find-nth-word
dup c@ 0= if
    ." Usage: advent6-1 input.txt"
    drop bye
then

open-file
dup INVALID_HANDLE_VALUE = if
    ." Error: Unable to open input file"
    drop bye
then
dup file-buffer read-file close-file

numbers file-buffer parse-numbers num-numbers !

1
num-numbers @ 0 do
    i num-numbers @ + /n * numbers + @ float  \ distance
    i /n * numbers + @ float                  \ time
    ways-to-win *
loop
. bye