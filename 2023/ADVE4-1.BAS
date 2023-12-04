' Advent of Code 2023 - Day 4: Scratchcards, part 1
' Mic, 2023
'
' Run with QB45

DEFINT A-Z
'$DYNAMIC

DECLARE FUNCTION ReadLine$ ()
DECLARE SUB ParseNumbers (numbers$, parsed() AS INTEGER)

DIM iwinning(1) AS INTEGER
DIM ihave(1) AS INTEGER

ON ERROR GOTO ErrorHandler

CLS
IF LEN(COMMAND$) = 0 THEN
    PRINT "Error: No input file specified."
    END
END IF

' LINE INPUT expects CR characters to be present, so read in BINARY mode instead
OPEN COMMAND$ FOR BINARY AS 1
IF errorflag <> 0 THEN
    errorflag = 0
    CLOSE
    PRINT "Error: Unable to open input file."
    END
END IF

PRINT "Processing..."

points& = 0
DO WHILE NOT EOF(1)
    line$ = ReadLine$
    bar% = INSTR(line$, "|")
    winning$ = LEFT$(line$, bar% - 1)
    have$ = LTRIM$(MID$(line$, bar% + 1))
    winning$ = LTRIM$(RIGHT$(winning$, LEN(winning$) - INSTR(winning$, ":")))
    ParseNumbers winning$, iwinning()
    ParseNumbers have$, ihave()

    pts& = 1
    FOR H = 1 TO UBOUND(ihave)
        FOR W = 1 TO UBOUND(iwinning)
            IF iwinning(W) = ihave(H) THEN
                pts& = pts& * 2
                EXIT FOR
            END IF
        NEXT W
    NEXT H
    points& = points& + (pts& \ 2)
LOOP

CLOSE 1
PRINT "Number of points:", points&
END

ErrorHandler:
errorflag = ERR
RESUME NEXT


FUNCTION ReadLine$
    result$ = ""
    DIM buffer AS STRING
    buffer = SPACE$(1)
    DO WHILE NOT EOF(1)
        GET #1, , buffer
        IF buffer = CHR$(10) OR buffer = CHR$(13) THEN
            EXIT DO
        ELSE
            result$ = result$ + buffer
        END IF
    LOOP
    ReadLine$ = result$
END FUNCTION


SUB ParseNumbers (numbers$, parsed() AS INTEGER)
    DIM temp(100) AS INTEGER
    N = 0
    nextSpace% = 1
    DO WHILE LEN(numbers$) > 0 AND nextSpace% > 0
        nextSpace% = INSTR(numbers$, " ")
        last% = nextSpace%
        IF nextSpace% = 0 THEN
            last% = LEN(numbers$) + 1
        END IF
        N = N + 1
        s$ = LEFT$(numbers$, last% - 1)
        numbers$ = LTRIM$(MID$(numbers$, last%))
        temp(N) = VAL(s$)
    LOOP
    REDIM parsed(N) AS INTEGER
    FOR I = 1 TO N
        parsed(I) = temp(I)
    NEXT
END SUB