-- Lexer.lua
-- OptimisticSide
-- 12/14/2020

local package = script.Parent

local Syntax = require(package.Syntax)
local Token = require(package.Token)
local Char = require(package.Char)

local Lexer = {}
Lexer.__index = Lexer

function Lexer:advance()
	-- ensure not out of boundd
	if self.pos <= self.size then
		-- advance by 1 character
		self.pos = self.pos + 1
		self.char = self.src:sub(self.pos, self.pos)
	end
end

function Lexer:jump(n)
	-- ensure position is not out of bounds
	self.pos = math.min(self.pos + n, self.size)
	self.char = self.src:sub(self.pos, self.pos)
end

function Lexer:peekSegment(segment, shouldJump)
	-- check the next few characters for the desired segment
	if self.src:sub(self.pos, self.pos + (#segment-1)) == segment then
		-- jump if needed
		if shouldJump then
			self:jump(#segment-1)
		end

		return true
	end

	return false
end

function Lexer:skipSplits()
	-- while split operator available and not exceeded size, advance
	while self.char == Syntax.oper.split and self.pos <= self.size do
		self:advance()
	end
end

function Lexer:pushToken(str, ...)
	-- add token to list
	-- offset the starting position accordingly
	self.tokens[#self.tokens+1] = Token.new(self.pos-#str, str, ...)
end

function Lexer:collectComment(stop)
	local comment = ""

	-- go through comment and keep appending data
	-- if able to peek the stop segment, then stop
	while self.pos <= self.size and not self:peekSegment(stop) do
		comment = comment .. self.char
		self:advance()
	end

	-- push token to stack & jump past stopper
	self:pushToken(comment, Token.COMMENT)
	self:jump(#stop)
end

function Lexer:collectBunch(stop, escape)
	local bunch = ""
	local escaping = false

	-- go through comment and keep appending data
	-- if able to peek the stop segment, then stop
	while self.pos <= self.size and not self:peekSegment(stop) and (not self:peekSegment(escape, true) or escaping) do
		-- check if we are escaping
		-- if so, then jump past the escape character
		escaping = self:peekSegment(escape, true) and not escaping

		bunch = bunch .. self.char
		self:advance()
	end

	-- push token to stack & jump past stopper
	self:pushToken(bunch, Token.BUNCH)
	self:jump(#stop)
end

function Lexer:collectIden()
	local iden = ""

	-- go through identifier and keep appending data
	-- make sure either alpha-numeric or an allowed character
	-- if able to peek the stop segment, then stop
	while self.pos <= self.size and (Char.isAlnum(self.char) or Syntax.element.allowed:find(self.char)) do
		iden = iden .. self.char
		self:advance()
	end

	-- push token to stack & jump past stopper
	self:pushToken(iden, Token.IDEN)
end

function Lexer:nextToken()
	-- stop if we have gone through the whole string
	if self.pos > self.size then
		return
	end

	-- if alphet, then collect as an identifier
	if Char.isAlpha(self.char) then
		self:collectIden()
	end

	-- if split opreator, then skip through
	if self:peekSegment(Syntax.oper.split) then
		self:skipSplits()
	end

	-- if bunch starter, then advance through and collect bunch
	if self:peekSegment(Syntax.bunch.start, true) then
		self:advance()
		self:collectBunch(Syntax.bunch.stop, Syntax.bunch.escape)
	end

	-- we lex comments incase of syntax-highlighting
	-- if comment starter, then advance through and collect comment
	if self:peekSegment(Syntax.comment.start, true) then
		self:advance()
		self:collectComment(Syntax.comment.stop)
		
	-- if LINE comment starter, then collect comment until next new line
	elseif self:peekSegment(Syntax.comment.line, true) then
		self:advance()
		self:collectComment("\n")
	end
	
	-- if prefix operator, then push to stack
	if self:peekSegment(Syntax.oper.prefix) then
		self:pushToken(self.src:sub(self.pos, self.pos + #Syntax.oper.prefix-1), Token.OPER)
		self:jump(#Syntax.oper.prefix)
	
	-- if statment end operator, then push to stack
	elseif self:peekSegment(Syntax.oper.statement) then
		self:pushToken(self.src:sub(self.pos, self.pos + #Syntax.oper.statement-1), Token.OPER)
		self:jump(#Syntax.oper.statement)

	-- if argument split operator, then push to stack
	elseif self:peekSegment(Syntax.oper.argSplit) then
		self:pushToken(self.src:sub(self.pos, self.pos + #Syntax.oper.argSplit-1), Token.OPER)
		self:jump(#Syntax.oper.argSplit)

	-- if argument parameter operator, then push to stack
	elseif self:peekSegment(Syntax.oper.argParam) then
		self:pushToken(self.src:sub(self.pos, self.pos + #Syntax.oper.argParam-1), Token.OPER)
		self:jump(#Syntax.oper.argParam)
	end

	-- collect next token
	self:nextToken()
end

function Lexer:start()
	-- start token collection procedure
	return self:nextToken()
end

function Lexer.new(src)
	local self = {}
	setmetatable(self, Lexer)

	self.tokens = {}
	self.src = src or ""

	self.pos = 1
	self.size = #self.src
	self.char = src:sub(self.pos, self.pos)

	return self
end

return Lexer