-- Advent of Code 2024 - Day 2: Red-Nosed Reports, part 1
-- Mic, 2024

function is_safe(levels)
    local sign = 0
    for i = 1,table.getn(levels)-1 do
        local delta = levels[i+1] - levels[i]
        if math.abs(delta) < 1 or math.abs(delta) > 3 then return 0 end
        local delta_sign = delta < 0 and -1 or 1
        if delta_sign == sign or sign == 0 then sign = delta_sign else return 0 end
    end
    return 1
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
    num_safe = num_safe + is_safe(report)
end

print("Number of safe reports: "..num_safe)