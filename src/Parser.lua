-- Parser.lua
-- OptimisticSide
-- 12/14/2020

local package = script.Parent

local Lexer = require(package.Lexer)
local Syntax = require(package.Syntax)
local Token = require(package.Token)

local Parser = {}
Parser.__index = Parser

Parser.EOF = 0
Parser.STATEMENT = 1
Parser.ARG = 2
Parser.ARG_SEGMENT = 3

function Parser:advance()
	-- ensure not out of boundd
	if self.pos < self.size then
		-- advance by 1 character
		self.pos = self.pos + 1
		self.token = self.tokens[self.pos]
	end
end

function Parser:readArgSegment()
	local segment = {
		type = Parser.ARG_SEGMENT,
		pos = self.pos,
		call = nil,
		param = nil,
	}

	-- go through tokens and ensure bounds
	while self.pos <= self.size do
		-- if we already have data
		-- then make sure there was an argParam operator before this token
		if segment.call then
			local lastTok = self.tokens[self.pos-1]
			if segment.param or lastTok.type ~= Token.OPER or lastTok.str ~= Syntax.oper.argParam then
				break
			end
		end

		-- collect identifier or bunch and handle accordingly
		if self.token.type == Token.IDEN or self.token.type == Token.BUNCH then
			if not segment.call then
				segment.call = self.token.str
			else
				segment.param = self.token.str
			end
		end

		-- advance for next loop
		self:advance()
	end

	-- return segment
	return segment
end

function Parser:readArg()
	local arg = {
		type = Parser.ARG,
		pos = self.pos,
		segments = {}
	}

	-- go through tokens and ensure bounds
	while self.pos <= self.size do
		-- if data hs already been collected
		-- then make sure there was an argSplit operator before this token
		if #arg.segments > 0 then
			local lastTok = self.tokens[self.pos-1]
			if lastTok.type ~= Token.OPER or lastTok.str ~= Syntax.oper.argSplit then
				break
			end
		end

		-- collect identifier or bunch and handle accordingly
		if self.token.type == Token.IDEN or self.token.type == Token.BUNCH then
			arg.segments[#arg.segments+1] = self:readArgSegment()
		end

		-- advance for next loop
		self:advance()
	end

	-- return argument
	return arg
end

function Parser:nextStatement()
	local statement = {
		type = Parser.STATEMENT,
		pos = self.pos,
		command = nil,
		args = {}
	}

	local complete = false
	while self.pos < self.size and not complete do
		-- if statement ending operator, then signal a statement completion
		if self.token.type == Token.OPER then
			if self.token.str == Syntax.oper.statement then
				complete = true
			end

			-- add command or argument if identifier or bunch
		elseif self.token.type == Token.IDEN or self.token.type == Token.BUNCH then
			local str = self.token.str
			if self.token.type == Token.BUNCH then
				str = self:handleBunch(str)
			end

			if not statement.command then
				statement.command = str
			else
				statement.args[#statement.args+1] = self:readArg()
			end
		end

		self:advance()
	end

	return statement
end

function Parser:start()
	while self.pos < self.size do
		self.statements[#self.statements+1] = self:nextStatement()
	end
end

function Parser.new(tokens)
	local self = {}
	setmetatable(self, Parser)

	self.tokens = tokens or {}
	self.statements = {}

	self.size = #self.tokens
	self.pos = 1
	self.token = self.tokens[self.pos]

	return self
end

return Parser