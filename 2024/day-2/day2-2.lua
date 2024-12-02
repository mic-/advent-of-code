-- Advent of Code 2024 - Day 2: Red-Nosed Reports, part 2
-- Mic, 2024

function table.copy(it)
    return {unpack(it)}
end

function is_safe(levels)
    local sign = 0
    for i = 1,table.getn(levels)-1 do
        local delta = levels[i+1] - levels[i]
        if math.abs(delta) < 1 or math.abs(delta) > 3 then
            return false
        end
        local delta_sign = delta < 0 and -1 or 1
        if delta_sign ~= sign and sign ~= 0 then
            return false
        end
        if sign == 0 then sign = delta_sign end
    end
    return true
end

if #arg < 1 then
    print("Error: no input file specified")
    os.exit()
end

local f = io.open(arg[1], "rb")
if f == nil then
    print("Error: unable to open input file")
    os.exit()
end
f:close()

local num_safe = 0
for line in io.lines(arg[1]) do
    local report = {}
    for level in string.gmatch(line, "%S+") do
        table.insert(report, level)
    end
    for x = 0,table.getn(report) do
        local report_copy = table.copy(report)
        table.remove(report_copy, x)
        if is_safe(report_copy) then
            num_safe = num_safe + 1
            break
        end
    end
end

print("Number of safe reports: "..num_safe)