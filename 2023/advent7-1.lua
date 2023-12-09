-- Advent of Code 2023 - Day 7: Camel Cards, part 1
-- Mic, 2023

function table.copy(it)
    return {table.unpack(it)}
end

revcards = {["2"] = 2, ["3"] = 3, ["4"] =  4, ["5"] =  5, ["6"] =  6, ["7"] =  7,
            ["8"] = 8, ["9"] = 9, ["T"] = 10, ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14}

function getcardvalue(card)
    return revcards[card]
end

function groupbyvalue(cards)
    local result = {}
    local sorted = table.copy(cards)
    table.sort(sorted, function(a, b) return getcardvalue(a) < getcardvalue(b) end)
    for i,c in ipairs(sorted) do
        if #result > 0 and result[#result][#result[#result]] == c then
            table.insert(result[#result], c)
        else
            table.insert(result, {c})
        end
    end
    return result
end

function getstrength(cards)
    local grouped = groupbyvalue(cards)
    local sortedgroups = grouped
    table.sort(sortedgroups, function(a, b) return #a > #b end)
    if #sortedgroups[1] == 5 then
        return 7
    elseif #sortedgroups[1] == 4 then
        return 6
    elseif #sortedgroups[1] == 3 then
        return (#sortedgroups[2] == 2) and 5 or 4
    elseif #sortedgroups[1] == 2 then
        return (#sortedgroups[2] == 2) and 3 or 2
    else
        return 1
    end
end

Player = {}
Player.__index = Player

function Player:create(playerstring)
    local plr = {}
    setmetatable(plr, Player)
    local cards,bet = playerstring:match("(%S+)%s+(%S+)$")
    local cardstbl = {}
    cards:gsub(".",function(c) table.insert(cardstbl,c) end)
    plr.cards = cardstbl
    plr.bet = tonumber(bet)
    return plr
end

function compareplayers(a, b)
    local hand1 = table.copy(a.cards)
    local hand2 = table.copy(b.cards)
    local strength1 = getstrength(hand1)
    local strength2 = getstrength(hand2)
    if strength1 == strength2 then
        for i,c in ipairs(hand1) do
            local val1 = getcardvalue(hand1[i])
            local val2 = getcardvalue(hand2[i])
            if val1 ~= val2 then
                return val1 < val2
            end
        end
        return false
    else
        return strength1 < strength2
    end
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

local players = {}
for line in io.lines(arg[1]) do
    table.insert(players, Player:create(line))
end

table.sort(players, compareplayers)

local winnings = 0
for i,p in ipairs(players) do
    winnings = winnings + p.bet * i
end
print("Total winnings: "..winnings)