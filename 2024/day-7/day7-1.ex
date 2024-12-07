-- Advent of Code 2024 - Day 7: Bridge Repair, part 1
-- Mic, 2024

include std/convert.e
include std/math.e
include std/sequence.e
include std/io.e

function get_answer_if_solvable(atom answer, sequence operands)
    integer operators = floor(power(2, length(operands)-1))
    for i = 0 to operators-1 do
        atom result = operands[1]
        for j = 2 to length(operands) do
            if and_bits(i, power(2, j-2)) then
                result *= operands[j]
            else
                result += operands[j]
            end if
        end for
        if result = answer then
            return answer
        end if
    end for

    return 0
end function

function get_calibration_result(sequence line)
    sequence s = split(line, ':')
    sequence operands = split(s[2], ' ', 1)
    atom answer = to_number(s[1])
    for j = 1 to length(operands) do
        operands[j] = to_integer(operands[j])
    end for
    return get_answer_if_solvable(answer, operands)
end function

sequence cmd = command_line()
if length(cmd) < 3 then
    puts(1, "Error: No input filename specified")
    abort(0)
end if

atom sum = 0
sequence lines = read_lines(cmd[3])
for i = 1 to length(lines) do
    sum += get_calibration_result(lines[i])
end for

printf(1, "Total calibration result: %d", sum)
