-- Advents of Code 2023 - Day 3: Gear Ratios, part 1
-- Mic, 2023

include std/convert.e
include std/math.e
include std/io.e
include std/regex.e as re

constant RE_NUMBER = re:new("[0-9]+")

function char_at(sequence strings, integer column, integer row)
    integer r = mod(row - 1, length(strings)) + 1
    integer c = mod(column - 1, length(strings[r])) + 1
    return strings[r][c]
end function

function has_adjacent_symbol(sequence strings, sequence columns, integer row)
    sequence non_symbols = "0123456789."
    for r = row-1 to row+1 do
        for c = columns[1]-1 to columns[2]+1 do
            if not find(char_at(strings, c, r), non_symbols) then
                return 1
            end if
        end for
    end for
    return 0
end function


sequence cmd = command_line()
if length(cmd) < 3 then
    puts(1, "Error: No input filename specified")
    abort(0)
end if

sequence lines = read_lines(cmd[3])
atom sum = 0
for row = 1 to length(lines) do
    object matches = re:find_all(RE_NUMBER, lines[row])
    for m = 1 to length(matches) do
        sequence columns = matches[m][1]
        if has_adjacent_symbol(lines, columns, row) then
            sum += to_integer(lines[row][columns[1]..columns[2]])
        end if
    end for
end for
? sum