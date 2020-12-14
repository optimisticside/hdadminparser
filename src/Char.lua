-- Char.lua
-- OptimisticSide
-- 12/14/2020

local ALPHA_START = tonumber(("A"):byte())
local ALPHA_END = tonumber(("z"):byte())

local DIGIT_START = tonumber(("0"):byte())
local DIGIT_END = tonumber(("9"):byte())

local Char = {}

function Char.isDigit(char)
	local byte = char:byte()
	return byte >= DIGIT_START and byte <= DIGIT_END
end

function Char.isAlpha(char)
	local byte = char:byte()
	return byte >= ALPHA_START and byte <= ALPHA_END
end

function Char.isAlnum(char)
	return Char.isDigit(char) or Char.isAlpha(char)
end

return Char