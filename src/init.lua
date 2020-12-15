local Lexer = require(script.Lexer)
local Parser = require(script.Parser)

local Reader = {}

function Reader.parse(src)
	local start = os.clock()
	local lexer = Lexer.new(src)
	lexer:start()
	print("Lexed in", (os.clock() - start) * 1000, "ms")
	
	start = os.clock()
	local parser = Parser.new(lexer.tokens)
	parser:start()
	print("Parsed in", (os.clock() - start) * 1000, "ms")
	
	return parser.statements
end

return Reader