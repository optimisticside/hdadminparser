-- Token.lua
-- OptimisticSide
-- 12/14/2020

local Token = {}
Token.__index = Token

Token.EOF = 0
Token.IDEN = 1
Token.OPER = 2
Token.BUNCH = 3
Token.COMMENT = 4

function Token.new(pos, str, type, data)
	local self = {}
	setmetatable(self, Token)
	
	self.pos = pos
	self.str = str
	self.type = type
	self.data = data
	
	return self
end

return Token