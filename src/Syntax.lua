-- Syntax.lua
-- OptimisticSide
-- 12/14/2020

local Syntax = {}

Syntax.oper = {
	prefix = "/",
	statement = ";",
	split = " ", -- has to be 1 character only
	argSplit = ",",
	argParam = "-",
}

Syntax.element = {
	allowed = "_-",
}

Syntax.comment = {
	line = "//",
	start = "/*",
	stop = "*/"
}

Syntax.bunch = {
	escape = "\\",
	start = "\"",
	stop = "\"",
}

return Syntax