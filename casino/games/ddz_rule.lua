local cjson = require("cjson.safe")

local combinations = {
    ["single"]              = 1,
    ["double"]              = 2,
    ["triple"]              = 3,
    ["triple_plus_one"]     = 4,
    ["straight_5"]          = 5,
    ["straight_6"]          = 6,
    ["straight_7"]          = 7,
    ["straight_8"]          = 8,
    ["straight_9"]          = 9,
    ["straight_10"]         = 10,
    ["straight_11"]         = 11,
    ["straight_12"]         = 12, 
    ["double_straight_3"]   = 6,
    ["double_straight_4"]   = 8,
    ["double_straight_5"]   = 10,
    ["double_straight_6"]   = 12,
    ["double_straight_7"]   = 14,
    ["double_straight_8"]   = 16,
    ["double_straight_9"]   = 18,
    ["double_straight_10"]  = 20, 
    ["triple_straight_2"]   = 6,
    ["triple_straight_3"]   = 9,
    ["triple_straight_4"]   = 12,
    ["triple_straight_5"]   = 15,
    ["triple_straight_6"]   = 18, 
    ["airplane_2"]          = 8,
    ["airplane_3"]          = 12,
    ["airplane_4"]          = 16,
    ["airplane_5"]          = 20,
    ["quartet_plus_two"]    = 6,
    ["bomb"]                = 4,
    ["rocket"]              = 2,
}

local function get_combination_value(cards)
    if #cards == 1 then
        return {
            combination = "single",
            value = cards[1].value
        }
    end

    if #cards == 2 and 
        cards[1].value == cards[2].value then
        return {
            combination = "double",
            value = cards[1].value
        }
    end

    if #cards == 3 and 
        cards[1].value == cards[2].value and 
        cards[1].value == cards[3].value then
        return {
            combination = "triple",
            value = cards[1].value
        }
    end

    if #cards == 4 and
        cards[1].value == cards[2].value and 
        cards[1].value == cards[3].value and 
        cards[1].value == cards[4].value then
        return {
            combination = "bomb",
            value = cards[1].value
        }
    end

    if #cards == 2 and (
            (cards[1].value == 16 and cards[2].value == 17) or 
            (cards[1].value == 17 and cards[2].value == 16)) then
        return {
            combination = "rocket",
            value = 9999
        }
    end

    local counts = {}
    for _, card in ipairs(cards) do
        counts[card.value] = (counts[card.value] or 0) + 1
    end

    local singles = {}
    local doubles = {}
    local triples = {}
    local quartets = {}
    for value, count in pairs(counts) do
        if count == 1 then
            table.insert(singles, value)
        end

        if count == 2 then
            table.insert(doubles, value)
        end

        if count == 3 then
            table.insert(triples, value)
        end

        if count == 4 then
            table.insert(quartets, value)
        end
    end

    local smaller = function (a, b)
        return a < b
    end

    table.sort(doubles, smaller)
    table.sort(triples, smaller)
    table.sort(quartets, smaller)

    local is_straight = function (values)
        for i = 2, #values do
            if values[i - 1] + 1 ~= values[i] then
                return false
            end
        end

        return true
    end

    for combination, cards_num in pairs(combinations) do
        if #cards == cards_num then
            if combination == "triple_plus_one" then
                if #triples == 1 and #quartets == 0 then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "straight_5" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 5 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_6" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 6 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_7" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 7 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_8" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 8 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_9" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 9 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_10" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 10 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_11" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 11 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "straight_12" then
                if #doubles == 0 and #triples == 0 and #quartets == 0 and #singles == 12 and is_straight(singles) then
                    return {
                        combination = combination,
                        value = singles[1]
                    }
                end
            end

            if combination == "double_straight_3" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 3 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_4" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 4 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_5" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 5 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_6" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 6 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_7" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 7 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_8" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 8 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_9" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 9 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "double_straight_10" then
                if #singles == 0 and #triples == 0 and #quartets == 0 and #doubles == 10 and is_straight(doubles) then
                    return {
                        combination = combination,
                        value = doubles[1]
                    }
                end
            end

            if combination == "triple_straight_2" then
                if #singles == 0 and #doubles == 0 and #quartets == 0 and #triples == 2 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "triple_straight_3" then
                if #singles == 0 and #doubles == 0 and #quartets == 0 and #triples == 3 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "triple_straight_4" then
                if #singles == 0 and #doubles == 0 and #quartets == 0 and #triples == 4 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "triple_straight_5" then
                if #singles == 0 and #doubles == 0 and #quartets == 0 and #triples == 5 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "triple_straight_6" then
                if #singles == 0 and #doubles == 0 and #quartets == 0 and #triples == 6 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "airplane_2" then
                if #quartets == 0 and #triples == 2 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "airplane_3" then
                if #quartets == 0 and #triples == 3 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "airplane_4" then
                if #quartets == 0 and #triples == 4 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "airplane_5" then
                if #quartets == 0 and #triples == 5 and is_straight(triples) then
                    return {
                        combination = combination,
                        value = triples[1]
                    }
                end
            end

            if combination == "quartet_plus_two" then
                if #quartets == 1 then
                    return {
                        combination = combination,
                        value = quartets[1]
                    }
                end
            end
        end
    end

    return nil
end

local function beats(current, previous)
    if type(previous) ~= "table" then
        return true
    end

    if previous.combination == "rocket" then
        return false
    end

    if current.combination == "rocket" then
        return true
    end

    if previous.combination ~= current.combination then
        if current.combination == "bomb" then
            return true
        end

        return nil
    end

    return current.value > previous.value
end
