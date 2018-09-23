local resty_string = require("resty.string")
local resty_random = require("resty.random")
local cjson = require("cjson.safe")

local _M = {
    PLAYER_NUM = 3
}

local mt = { __index = _M }

local STATUS_EMPTY = 0
local STATUS_SEATED = 1
local STATUS_READY = 10

function _M.new()
    return setmetatable({
        players = { 
            {
                status = STATUS_EMPTY,
                cards = {},
            }, 
		{
                status = STATUS_EMPTY,
                cards = {},
            }, 
		{
                status = STATUS_EMPTY,
                cards = {},
            }
        }
    }, mt)
end

local function get_combination_value(cards)
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

    table.sort(singles, smaller)
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
    
    local combinations = {
        { name = "single", 			    car_num = 1, 	singles = 1, 	doubles = 0, 	triples = 0, quartets = 0, straight = nil, 		value = singles[1] 	},
        { name = "double", 			    car_num = 2, 	singles = 0, 	doubles = 1, 	triples = 0, quartets = 0, straight = nil, 		value = doubles[1] 	},
        { name = "triple", 			    car_num = 3, 	singles = 0, 	doubles = 0, 	triples = 1, quartets = 0, straight = nil, 		value = triples[1] 	},
        { name = "bomb", 				car_num = 4, 	singles = 0, 	doubles = 0, 	triples = 0, quartets = 1, straight = nil, 		value = quartets[1] },
        { name = "triple_plus_one", 	car_num = 4, 	singles = 1, 	doubles = 0, 	triples = 1, quartets = 0, straight = nil, 		value = triples[1] 	},
        { name = "quartet_plus_two", 	car_num = 6, 	singles = nil, 	doubles = 1, 	triples = 0, quartets = 1, straight = nil, 		value = quartets[1] },
        { name = "straight_5", 		    car_num = 5, 	singles = 5, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_6", 		    car_num = 6, 	singles = 6, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_7", 		    car_num = 7, 	singles = 7, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_8", 		    car_num = 8, 	singles = 8, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_9", 		    car_num = 9, 	singles = 9, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_10", 		car_num = 10,   singles = 10, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_11", 		car_num = 11,   singles = 11, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "straight_12", 		car_num = 12,   singles = 12, 	doubles = 0, 	triples = 0, quartets = 0, straight = singles, 	value = singles[1] 	},
        { name = "double_straight_3",   car_num = 6, 	singles = 0, 	doubles = 3, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_4",   car_num = 8, 	singles = 0, 	doubles = 4, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_5",   car_num = 10,   singles = 0, 	doubles = 5, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_6",   car_num = 12,   singles = 0, 	doubles = 6, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_7",   car_num = 14,   singles = 0, 	doubles = 7, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_8",   car_num = 16,   singles = 0, 	doubles = 8, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_9",   car_num = 18,   singles = 0, 	doubles = 9, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "double_straight_10",  car_num = 20,   singles = 0, 	doubles = 10, 	triples = 0, quartets = 0, straight = doubles, 	value = doubles[1] 	},
        { name = "triple_straight_2",   car_num = 6, 	singles = 0, 	doubles = 0, 	triples = 2, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "triple_straight_3",   car_num = 9, 	singles = 0, 	doubles = 0, 	triples = 3, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "triple_straight_4",   car_num = 12,   singles = 0, 	doubles = 0, 	triples = 4, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "triple_straight_5",   car_num = 15,   singles = 0, 	doubles = 0, 	triples = 5, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "triple_straight_6",   car_num = 18,   singles = 0, 	doubles = 0, 	triples = 6, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "airplane_2", 		    car_num = 8, 	singles = nil, 	doubles = nil, 	triples = 2, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "airplane_3", 		    car_num = 12,   singles = nil, 	doubles = nil, 	triples = 3, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "airplane_4", 		    car_num = 16,   singles = nil, 	doubles = nil, 	triples = 4, quartets = 0, straight = triples, 	value = triples[1] 	},
        { name = "airplane_5", 		    car_num = 20,   singles = nil, 	doubles = nil, 	triples = 5, quartets = 0, straight = triples, 	value = triples[1] 	},
    }

    for _, combination in ipairs(combinations) do
        if combination.car_num == #cards and
            (combination.singles == nil or singles[combination.singles] == #singles) and
            (combination.doubles == nil or doubles[combination.doubles] == #doubles) and
            (combination.triples == nil or triples[combination.triples] == #triples) and
            (combination.quartets == nil or quartets[combination.quartets] == #quartets) and
            (combination.straight == nil or (is_straight(combination.straight) and combination.straight[#combination.straight] < 15)) then
            return {
                combination = combination.name,
                value = combination.value
            }
        end
    end

    return nil
end

local function beats(current, previous)
    if previous == nil then
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

local function random()
    return tonumber(resty_string.to_hex(resty_random.bytes(2, true)), 16)
end

local function get_card_by_index(index)
    local name = { "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "BJ", "RJ" }
    local color = { "diamond", "club", "heart", "spade" }
    
    if index <= 48 then
        local value = math.floor(index / 4)
        local rest = index % 4
        return {
            value = value + 3,
            display = {
                name = name[value + 1],
                color = color[rest + 1]
            }
        }
    end

    if index >= 49 and index <= 52 then
        return {
            value = 15,
            display = {
                name = name[13],
                color = color[index % 4 + 1]
            }
        }
    end

    if index == 53 then
        return {
            value = 16,
            display = {
                name = "BJ",
                color = "black"
            }
        }
    end

    if index == 54 then
        return {
            value = 17,
            display = {
                name = "RJ",
                color = "red"
            }
        }
    end

    return nil
end

local function sort_cards(cards)
    table.sort(cards, function (a, b) 
        return a.value < b.value
    end)
end

function _M:shuffle()
    local cards = {}
    for i = 1, 54 do
        table.insert(cards, i)
    end

    for i = #cards, 1, -1 do
        local rd = random() % i + 1
        cards[i], cards[rd] = cards[rd], cards[i]
    end

    local res = { 
        outputs = {
            {
                typ = "deal",
                cards = {},
            },
            {
                typ = "deal",
                cards = {},
            },
            {
                typ = "deal",
                cards = {},
            }
        }    
    }

    for i = 1, 20 do
        table.insert(res.outputs[1].cards, get_card_by_index(cards[i]))
    end

    for i = 21, 37 do
        table.insert(res.outputs[2].cards, get_card_by_index(cards[i]))
    end

    for i = 38, 54 do
        table.insert(res.outputs[3].cards, get_card_by_index(cards[i]))
    end

    sort_cards(res.outputs[1].cards)
    self.players[1].cards = res.outputs[1].cards

    sort_cards(res.outputs[2].cards)
    self.players[2].cards = res.outputs[2].cards

    sort_cards(res.outputs[3].cards)
    self.players[3].cards = res.outputs[3].cards

    return res
end

function _M:join()
    local seatno
    for i, player in ipairs(self.players) do
        if player.status == STATUS_EMPTY then
            player.status = STATUS_READY
            seatno = i
            break
        end   
    end

    if seatno then
        for _, player in ipairs(self.players) do
            if player.status ~= STATUS_READY then
                return seatno
            end
        end

    end

    local res = self:shuffle()
    return seatno, res
end

function _M:play(seatno, hand)
    return {
        outputs = {hand, hand, hand}
    }
end

return _M
