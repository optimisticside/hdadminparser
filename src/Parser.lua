-- Parser.lua
-- OptimisticSide
-- 12/14/2020

local package = script.Parent

local Token = require(package.Token)
local Syntax = require(package.Syntax)

local Parser = {}
Parser.__index = Parser

function Parser:error(msg)
	
end

function Parser:formatBunch(bunch)
	local bell = Syntax.bunch.escape.."b"
	local newLine = Syntax.bunch.escape.."n"
	local horizTab = Syntax.bunch.escape.."t"
	local vertTab = Syntax.bunch.escape.."v"
	local escapeOverride = Syntax.bunch.escape..Syntax.bunch.escape
	
	return bunch:gsub(bell, "\b"):gsub(newLine, "\n"):gsub(horizTab, "t"):gsub(vertTab, "v"):gsub(escapeOverride, Syntax.bunch.escape)
end

function Parser:advance()
	if self.pos < self.size then
		self.pos = self.pos + 1
		self.token = self.tokens[self.pos]
	end
end

function Parser:readArgSegment()
	local segment = {
		call = nil,
		param = nil
	}
	
	local lastSplit = self.pos
	local complete = false
	
	while self.pos <= self.size and not complete do
		complete = true
		
		if self.token.type == Token.OPER and self.token.str == Syntax.oper.argParam then
			print('arg paramer')
			lastSplit = self.pos
			
		else
			if self.pos - lastSplit > 1 then
				complete = true
			end
			
			if self.token.type == Token.IDEN or self.token.type == Token.BUNCH then
				local str = self.token.str
				if self.token.type == Token.BUNCH then
					str = self:formatBunch(str)
				end
				
				if segment.call then
					print('param')
					segment.param = str
				else
					print('call', self.pos, self.size, self.token.str)
					segment.call = str
				end
			end
		end
		
		if self.pos == self.size then
			return segment
		end
		
		self:advance()
	end
	
	return segment
end

function Parser:readArg()
	local arg = {
		segments = {}
	}
	
	local complete = false
	local lastSplit = self.pos
	
	while self.pos <= self.size and not complete do
		if self.token.type == Token.OPER and self.token.str == Syntax.oper.argSegment then
			print('arg segmenter')
			lastSplit = self.pos
			
		else
			if self.pos - lastSplit > 1 then
				complete = true
			end
			
			if self.token.type == Token.IDEN or self.token.type == Token.BUNCH then
				print('segment #' .. tonumber(#arg.segments))
				arg.segments[#arg.segments+1] = self:readArgSegment()
			end
		end
		if self.pos == self.size then
			return arg
		end
		
		self:advance()
	end
	
	return arg
end

function Parser:readStatement()
	print('statement')
	local statement = {
		command = nil,
		args = {}
	}
	
	local complete = false
	while self.pos < self.size and not complete do
		if self.token.type == Token.OPER then
			if self.token.str == Syntax.oper.statement then
				print('statement end')
				complete = true
			end
			
		elseif self.token.type == Token.IDEN or self.token.type == Token.BUNCH then
			print('statement element')
			local str = self.token.str
			if self.token.type == Token.BUNCH then
				str = self:formatBunch(str)
			end

			if not statement.command then
				print('command')
				statement.command = str
			else
				print('argument #' .. tonumber(#statement.args))
					statement.args[#statement.args+1] = self:readArg()
			end
		end
		
		self:advance()
	end
	
	self.statements[#self.statements+1] = statement
	if self.pos < self.size then
		self:readStatement()
	end
end

function Parser:start()
	return self:readStatement()
end	

function Parser.new(tokens)
	print(tokens)
	print('________________')
	local self = {}
	setmetatable(self, Parser)
	
	self.tokens = tokens
	self.statements = {}
	
	self.pos = 1
	self.size = #self.tokens
	self.token = self.tokens[self.pos]
	
	return self
end

return Parser