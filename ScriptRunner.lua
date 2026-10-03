local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptRunner"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.new(0.5, 0, 0.6, 0)
root.Position = UDim2.new(0.25, 0, 0.15, 0)
root.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
root.BorderSizePixel = 1
root.BorderColor3 = Color3.fromRGB(20, 20, 20)
root.Parent = screenGui

local textBox = Instance.new("TextBox")
textBox.Name = "ScriptInput"
textBox.Size = UDim2.new(1, 0, 0.75, 0)
textBox.Position = UDim2.new(0, 0, 0, 0)
textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
textBox.BorderSizePixel = 0
textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
textBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
textBox.Font = Enum.Font.Code
textBox.TextSize = 16
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.PlaceholderText = "Made by Axo for ezCode"
textBox.Text = ""
textBox.Parent = root

local bottomBar = Instance.new("Frame")
bottomBar.Name = "BottomBar"
bottomBar.Size = UDim2.new(1, 0, 0.25, 0)
bottomBar.Position = UDim2.new(0, 0, 0.75, 0)
bottomBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
bottomBar.BorderSizePixel = 0
bottomBar.Parent = root

local runButton = Instance.new("TextButton")
runButton.Name = "RunButton"
runButton.Size = UDim2.new(0, 60, 0, 30)
runButton.Position = UDim2.new(0, 6, 1, -36)
runButton.AnchorPoint = Vector2.new(0, 0)
runButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
runButton.BorderSizePixel = 1
runButton.BorderColor3 = Color3.fromRGB(20, 20, 20)
runButton.TextColor3 = Color3.fromRGB(230, 230, 230)
runButton.Font = Enum.Font.SourceSans
runButton.TextSize = 16
runButton.Text = "Run"
runButton.Parent = bottomBar

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 60, 0, 30)
stopButton.Position = UDim2.new(0, 72, 1, -36)
stopButton.AnchorPoint = Vector2.new(0, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(90, 50, 50)
stopButton.BorderSizePixel = 1
stopButton.BorderColor3 = Color3.fromRGB(20, 20, 20)
stopButton.TextColor3 = Color3.fromRGB(230, 230, 230)
stopButton.Font = Enum.Font.SourceSans
stopButton.TextSize = 16
stopButton.Text = "Stop"
stopButton.Parent = bottomBar

local outputLabel = Instance.new("TextLabel")
outputLabel.Name = "OutputLabel"
outputLabel.Size = UDim2.new(1, -146, 1, -12)
outputLabel.Position = UDim2.new(0, 138, 0, 6)
outputLabel.BackgroundTransparency = 1
outputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
outputLabel.Font = Enum.Font.SourceSans
outputLabel.TextSize = 14
outputLabel.TextXAlignment = Enum.TextXAlignment.Left
outputLabel.TextYAlignment = Enum.TextYAlignment.Top
outputLabel.TextWrapped = true
outputLabel.Text = "Ready."
outputLabel.Parent = bottomBar

local KEYWORDS = {
	["local"] = true, ["true"] = true, ["false"] = true, ["nil"] = true,
	["and"] = true, ["or"] = true, ["not"] = true,
	["if"] = true, ["then"] = true, ["elseif"] = true, ["else"] = true, ["end"] = true,
	["while"] = true, ["for"] = true, ["in"] = true, ["do"] = true,
	["function"] = true, ["return"] = true, ["break"] = true,
}

local function tokenize(input)
	local tokens = {}
	local i = 1
	local len = #input
	local line = 1

	while i <= len do
		local char = input:sub(i, i)

		if char == "\n" then
			line = line + 1
			i = i + 1

		elseif char:match("%s") then
			i = i + 1

		elseif char == "-" and input:sub(i + 1, i + 1) == "-" then
			local nl = input:find("\n", i)
			i = nl and nl or (len + 1)

		elseif char:match("[%a_]") then
			local ident = input:match("^([%a_][%a_%d]*)", i)
			if KEYWORDS[ident] then
				table.insert(tokens, { type = ident:upper(), value = ident, line = line })
			else
				table.insert(tokens, { type = "IDENTIFIER", value = ident, line = line })
			end
			i = i + #ident

		elseif char:match("%d") then
			local num = input:match("^(%d+%.?%d*)", i)
			table.insert(tokens, { type = "NUMBER", value = tonumber(num), line = line })
			i = i + #num

		elseif char == '"' or char == "'" then
			local quote = char
			local closeIdx = input:find(quote, i + 1, true)
			if not closeIdx then
				error("input:" .. line .. ": unfinished string")
			end
			local str = input:sub(i + 1, closeIdx - 1)
			table.insert(tokens, { type = "STRING", value = str, line = line })
			i = closeIdx + 1

		elseif char == "(" then
			table.insert(tokens, { type = "LPAREN", value = "(", line = line }); i = i + 1
		elseif char == ")" then
			table.insert(tokens, { type = "RPAREN", value = ")", line = line }); i = i + 1
		elseif char == "{" then
			table.insert(tokens, { type = "LBRACE", value = "{", line = line }); i = i + 1
		elseif char == "}" then
			table.insert(tokens, { type = "RBRACE", value = "}", line = line }); i = i + 1
		elseif char == "[" then
			table.insert(tokens, { type = "LBRACKET", value = "[", line = line }); i = i + 1
		elseif char == "]" then
			table.insert(tokens, { type = "RBRACKET", value = "]", line = line }); i = i + 1
		elseif char == ":" then
			table.insert(tokens, { type = "COLON", value = ":", line = line }); i = i + 1
		elseif char == "," then
			table.insert(tokens, { type = "COMMA", value = ",", line = line }); i = i + 1
		elseif char == "+" then
			table.insert(tokens, { type = "PLUS", value = "+", line = line }); i = i + 1
		elseif char == "-" then
			table.insert(tokens, { type = "MINUS", value = "-", line = line }); i = i + 1
		elseif char == "*" then
			table.insert(tokens, { type = "STAR", value = "*", line = line }); i = i + 1
		elseif char == "%" then
			table.insert(tokens, { type = "PERCENT", value = "%", line = line }); i = i + 1
		elseif char == "/" then
			table.insert(tokens, { type = "SLASH", value = "/", line = line }); i = i + 1
		elseif char == "." and input:sub(i + 1, i + 1) == "." then
			table.insert(tokens, { type = "CONCAT", value = "..", line = line }); i = i + 2
		elseif char == "." then
			table.insert(tokens, { type = "DOT", value = ".", line = line }); i = i + 1
		elseif char == "=" and input:sub(i + 1, i + 1) == "=" then
			table.insert(tokens, { type = "EQ", value = "==", line = line }); i = i + 2
		elseif char == "~" and input:sub(i + 1, i + 1) == "=" then
			table.insert(tokens, { type = "NEQ", value = "~=", line = line }); i = i + 2
		elseif char == "<" and input:sub(i + 1, i + 1) == "=" then
			table.insert(tokens, { type = "LTE", value = "<=", line = line }); i = i + 2
		elseif char == ">" and input:sub(i + 1, i + 1) == "=" then
			table.insert(tokens, { type = "GTE", value = ">=", line = line }); i = i + 2
		elseif char == "=" then
			table.insert(tokens, { type = "ASSIGN", value = "=", line = line }); i = i + 1
		elseif char == "<" then
			table.insert(tokens, { type = "LT", value = "<", line = line }); i = i + 1
		elseif char == ">" then
			table.insert(tokens, { type = "GT", value = ">", line = line }); i = i + 1
		else
			error("input:" .. line .. ": unexpected symbol near '" .. char .. "'")
		end
	end

	return tokens
end

local MAX_STATEMENTS = 400

local function parse(tokens, knownBuiltins)
	local pos = 1
	local statementBudget = MAX_STATEMENTS
	local lastLine = 1

	local scopes = { {} }
	local function declare(name)
		scopes[#scopes][name] = true
	end
	local function pushScope()
		table.insert(scopes, {})
	end
	local function popScope()
		table.remove(scopes)
	end
	local function isDeclared(name)
		if knownBuiltins[name] then return true end
		for j = #scopes, 1, -1 do
			if scopes[j][name] then return true end
		end
		return false
	end

	local function peek() return tokens[pos] end
	local function peekType() local t = tokens[pos]; return t and t.type end
	local function currentLine()
		local t = tokens[pos]
		return t and t.line or lastLine
	end
	local function consume()
		local t = tokens[pos]
		if not t then error("input:" .. lastLine .. ": unexpected end of script") end
		lastLine = t.line
		pos = pos + 1
		return t
	end
	local function expect(tokType, humanName)
		local t = consume()
		if t.type ~= tokType then
			error("input:" .. t.line .. ": '" .. (humanName or tokType:lower()) .. "' expected, got '" .. tostring(t.value) .. "'")
		end
		return t
	end

	local parseExpr, parseBlock

	local function parseArgList()
		local args = {}
		expect("LPAREN", "(")
		if peekType() ~= "RPAREN" then
			table.insert(args, parseExpr())
			while peekType() == "COMMA" do
				consume()
				table.insert(args, parseExpr())
			end
		end
		expect("RPAREN", ")")
		return args
	end

	local function parseTableConstructor()
		local openTok = expect("LBRACE", "{")
		local arrayPart = {}
		local hashPart = {}
		while peekType() ~= "RBRACE" do
			if peekType() == "LBRACKET" then
				consume()
				local keyExpr = parseExpr()
				expect("RBRACKET", "]")
				expect("ASSIGN", "=")
				local valExpr = parseExpr()
				table.insert(hashPart, { key = keyExpr, value = valExpr })
			elseif peekType() == "IDENTIFIER" and tokens[pos + 1] and tokens[pos + 1].type == "ASSIGN" then
				local keyTok = consume()
				consume()
				local valExpr = parseExpr()
				table.insert(hashPart, { key = { type = "StringLiteral", value = keyTok.value, line = keyTok.line }, value = valExpr })
			else
				table.insert(arrayPart, parseExpr())
			end
			if peekType() == "COMMA" then
				consume()
			else
				break
			end
		end
		expect("RBRACE", "}")
		return { type = "TableConstructor", arrayPart = arrayPart, hashPart = hashPart, line = openTok.line }
	end

	local function parseCallOrIdentifier()
		local nameTok = expect("IDENTIFIER", "identifier")
		local base
		if peekType() == "LPAREN" then
			local args = parseArgList()
			base = { type = "CallExpression", callee = { type = "Identifier", name = nameTok.value, line = nameTok.line }, arguments = args, line = nameTok.line }
		else
			if not isDeclared(nameTok.value) then
				error("input:" .. nameTok.line .. ": attempt to use undeclared variable '" .. nameTok.value .. "'")
			end
			base = { type = "Identifier", name = nameTok.value, line = nameTok.line }
		end

		while true do
			if peekType() == "DOT" then
				consume()
				local keyTok = expect("IDENTIFIER", "identifier")
				base = { type = "IndexExpr", object = base, key = { type = "StringLiteral", value = keyTok.value, line = keyTok.line }, line = keyTok.line }
			elseif peekType() == "LBRACKET" then
				local brTok = consume()
				local keyExpr = parseExpr()
				expect("RBRACKET", "]")
				base = { type = "IndexExpr", object = base, key = keyExpr, line = brTok.line }
			elseif peekType() == "COLON" then
				consume()
				local methTok = expect("IDENTIFIER", "identifier")
				local args = parseArgList()
				base = { type = "MethodCallExpression", object = base, method = methTok.value, arguments = args, line = methTok.line }
			elseif peekType() == "LPAREN" then
				local args = parseArgList()
				base = { type = "CallExpression", callee = base, arguments = args, line = base.line }
			else
				break
			end
		end
		return base
	end

	local function parseParamList()
		local params = {}
		expect("LPAREN", "(")
		if peekType() ~= "RPAREN" then
			table.insert(params, expect("IDENTIFIER", "identifier").value)
			while peekType() == "COMMA" do
				consume()
				table.insert(params, expect("IDENTIFIER", "identifier").value)
			end
		end
		expect("RPAREN", ")")
		return params
	end

	local function parseFactor()
		local t = peek()
		if not t then error("input:" .. lastLine .. ": unexpected end of expression") end

		if t.type == "NUMBER" then
			consume(); return { type = "NumberLiteral", value = t.value, line = t.line }
		elseif t.type == "STRING" then
			consume(); return { type = "StringLiteral", value = t.value, line = t.line }
		elseif t.type == "TRUE" then
			consume(); return { type = "BoolLiteral", value = true, line = t.line }
		elseif t.type == "FALSE" then
			consume(); return { type = "BoolLiteral", value = false, line = t.line }
		elseif t.type == "NIL" then
			consume(); return { type = "NilLiteral", line = t.line }
		elseif t.type == "LBRACE" then
			return parseTableConstructor()
		elseif t.type == "FUNCTION" then
			consume()
			local params = parseParamList()
			pushScope()
			for _, p in ipairs(params) do declare(p) end
			local body = parseBlock({ END = true })
			popScope()
			expect("END", "end")
			return { type = "FunctionExpr", params = params, body = body, line = t.line }
		elseif t.type == "MINUS" then
			consume(); return { type = "UnaryExpr", operator = "-", operand = parseFactor(), line = t.line }
		elseif t.type == "LPAREN" then
			consume()
			local e = parseExpr()
			expect("RPAREN", ")")
			return e
		elseif t.type == "IDENTIFIER" then
			return parseCallOrIdentifier()
		else
			error("input:" .. t.line .. ": unexpected symbol near '" .. tostring(t.value) .. "'")
		end
	end

	local function parseTerm()
		local left = parseFactor()
		while peekType() == "STAR" or peekType() == "SLASH" or peekType() == "PERCENT" do
			local opTok = consume()
			left = { type = "BinaryExpr", operator = opTok.value, left = left, right = parseFactor(), line = opTok.line }
		end
		return left
	end

	local function parseAddExpr()
		local left = parseTerm()
		while peekType() == "PLUS" or peekType() == "MINUS" or peekType() == "CONCAT" do
			local opTok = consume()
			left = { type = "BinaryExpr", operator = opTok.value, left = left, right = parseTerm(), line = opTok.line }
		end
		return left
	end

	local function parseCompareExpr()
		local left = parseAddExpr()
		local ct = peekType()
		if ct == "EQ" or ct == "NEQ" or ct == "LT" or ct == "GT" or ct == "LTE" or ct == "GTE" then
			local opTok = consume()
			left = { type = "BinaryExpr", operator = opTok.value, left = left, right = parseAddExpr(), line = opTok.line }
		end
		return left
	end

	local function parseNotExpr()
		if peekType() == "NOT" then
			local t = consume()
			return { type = "UnaryExpr", operator = "not", operand = parseNotExpr(), line = t.line }
		end
		return parseCompareExpr()
	end

	local function parseAndExpr()
		local left = parseNotExpr()
		while peekType() == "AND" do
			local t = consume()
			left = { type = "LogicalExpr", operator = "and", left = left, right = parseNotExpr(), line = t.line }
		end
		return left
	end

	parseExpr = function()
		local left = parseAndExpr()
		while peekType() == "OR" do
			local t = consume()
			left = { type = "LogicalExpr", operator = "or", left = left, right = parseAndExpr(), line = t.line }
		end
		return left
	end

	local function useBudget()
		statementBudget = statementBudget - 1
		if statementBudget <= 0 then
			error("input:" .. currentLine() .. ": script too long (max " .. MAX_STATEMENTS .. " statements)")
		end
	end

	local function parseStatement()
		useBudget()
		local tt = peekType()

		if tt == "LOCAL" then
			consume()
			if peekType() == "FUNCTION" then
				consume()
				local nameTok = expect("IDENTIFIER", "identifier")
				declare(nameTok.value)
				local params = parseParamList()
				pushScope()
				for _, p in ipairs(params) do declare(p) end
				local body = parseBlock({ END = true })
				popScope()
				expect("END", "end")
				return { type = "LocalFunctionDecl", name = nameTok.value, params = params, body = body, line = nameTok.line }
			end
			local nameTok = expect("IDENTIFIER", "identifier")
			expect("ASSIGN", "=")
			local value = parseExpr()
			declare(nameTok.value)
			return { type = "LocalAssign", name = nameTok.value, value = value, line = nameTok.line }

		elseif tt == "IF" then
			local ifTok = consume()
			local clauses = {}
			local cond = parseExpr()
			expect("THEN", "then")
			pushScope()
			local body = parseBlock({ END = true, ELSEIF = true, ELSE = true })
			popScope()
			table.insert(clauses, { condition = cond, body = body })
			while peekType() == "ELSEIF" do
				consume()
				local c2 = parseExpr()
				expect("THEN", "then")
				pushScope()
				local b2 = parseBlock({ END = true, ELSEIF = true, ELSE = true })
				popScope()
				table.insert(clauses, { condition = c2, body = b2 })
			end
			local elseBody = nil
			if peekType() == "ELSE" then
				consume()
				pushScope()
				elseBody = parseBlock({ END = true })
				popScope()
			end
			expect("END", "end")
			return { type = "IfStatement", clauses = clauses, elseBody = elseBody, line = ifTok.line }

		elseif tt == "WHILE" then
			local whileTok = consume()
			local cond = parseExpr()
			expect("DO", "do")
			pushScope()
			local body = parseBlock({ END = true })
			popScope()
			expect("END", "end")
			return { type = "WhileStatement", condition = cond, body = body, line = whileTok.line }

		elseif tt == "FOR" then
			local forTok = consume()
			local varTok = expect("IDENTIFIER", "identifier")
			if peekType() == "COMMA" or peekType() == "IN" then
				local names = { varTok.value }
				while peekType() == "COMMA" do
					consume()
					table.insert(names, expect("IDENTIFIER", "identifier").value)
				end
				expect("IN", "in")
				local iterExpr = parseExpr()
				expect("DO", "do")
				pushScope()
				for _, n in ipairs(names) do declare(n) end
				local body = parseBlock({ END = true })
				popScope()
				expect("END", "end")
				return {
					type = "GenericForStatement", names = names,
					iterExpr = iterExpr, body = body, line = forTok.line,
				}
			end
			expect("ASSIGN", "=")
			local startExpr = parseExpr()
			expect("COMMA", ",")
			local stopExpr = parseExpr()
			local stepExpr = nil
			if peekType() == "COMMA" then
				consume()
				stepExpr = parseExpr()
			end
			expect("DO", "do")
			pushScope()
			declare(varTok.value)
			local body = parseBlock({ END = true })
			popScope()
			expect("END", "end")
			return {
				type = "ForStatement", varName = varTok.value,
				startExpr = startExpr, stopExpr = stopExpr, stepExpr = stepExpr, body = body, line = forTok.line,
			}

		elseif tt == "RETURN" then
			consume()
			local nt = peekType()
			if nt == "END" or nt == "ELSE" or nt == "ELSEIF" or nt == nil then
				return { type = "ReturnStatement", value = nil }
			end
			return { type = "ReturnStatement", value = parseExpr() }

		elseif tt == "BREAK" then
			consume()
			return { type = "BreakStatement" }

		else
			local expr = parseExpr()
			if peekType() == "ASSIGN" then
				if expr.type ~= "Identifier" and expr.type ~= "IndexExpr" then
					error("input:" .. currentLine() .. ": cannot assign to this expression")
				end
				if expr.type == "Identifier" and not isDeclared(expr.name) then
					error("input:" .. expr.line .. ": attempt to assign to undeclared variable '" .. expr.name .. "'")
				end
				consume()
				local value = parseExpr()
				return { type = "AssignStatement", target = expr, value = value, line = expr.line }
			end
			return { type = "ExpressionStatement", expression = expr }
		end
	end

	parseBlock = function(stopSet)
		local statements = {}
		while true do
			local tt = peekType()
			if tt == nil then break end
			if stopSet and stopSet[tt] then break end
			table.insert(statements, parseStatement())
		end
		return statements
	end

	local body = parseBlock(nil)
	return { type = "Program", body = body }
end

local MAX_LOOP_ITERATIONS = 10000
local MAX_CALL_DEPTH = 50

local SIGNAL_RETURN = "return"
local SIGNAL_BREAK = "break"

local STOP_SENTINEL = { __isStopSentinel = true }
local stopRequested = false

local function checkStop()
	if stopRequested then
		error(STOP_SENTINEL)
	end
end

local function newScope(parentEnv)
	return setmetatable({}, { __index = parentEnv })
end

local function assignVar(env, name, value)
	local scope = env
	while scope do
		if rawget(scope, name) ~= nil then
			scope[name] = value
			return
		end
		local mt = getmetatable(scope)
		scope = mt and mt.__index
	end
	env[name] = value
end

local evaluate, execBlock

local function truthy(v)
	return v ~= nil and v ~= false
end

local function luaType(v)
	return type(v)
end

local function indexValue(objVal, key, line)
	local tv = type(objVal)
	if tv == "table" then
		return objVal[key]
	elseif tv == "userdata" then
		local ok, result = pcall(function() return objVal[key] end)
		if not ok then
			error("input:" .. line .. ": " .. tostring(result))
		end
		return result
	else
		error("input:" .. line .. ": attempt to index a " .. tv .. " value")
	end
end

local function setIndexValue(objVal, key, value, line)
	local tv = type(objVal)
	if tv == "table" then
		objVal[key] = value
	elseif tv == "userdata" then
		local ok, err = pcall(function() objVal[key] = value end)
		if not ok then
			error("input:" .. line .. ": " .. tostring(err))
		end
	else
		error("input:" .. line .. ": attempt to index a " .. tv .. " value")
	end
end

local function describeCallee(node)
	if node.type == "Identifier" then return node.name end
	if node.type == "IndexExpr" and node.key.type == "StringLiteral" then return node.key.value end
	return "?"
end

local function callValue(funcOrDef, evaluatedArgs, depth, line, label)
	if type(funcOrDef) == "function" then
		return funcOrDef(table.unpack(evaluatedArgs, 1, evaluatedArgs.n or #evaluatedArgs))
	elseif type(funcOrDef) == "table" and funcOrDef.__isUserFunction then
		if depth >= MAX_CALL_DEPTH then
			error("input:" .. line .. ": stack overflow")
		end
		local callScope = newScope(funcOrDef.closureEnv)
		for i, paramName in ipairs(funcOrDef.params) do
			callScope[paramName] = evaluatedArgs[i]
		end
		local signal, value = execBlock(funcOrDef.body, callScope, depth + 1)
		if signal == SIGNAL_RETURN then
			return value
		end
		return nil
	else
		error("input:" .. line .. ": attempt to call a nil value ('" .. tostring(label) .. "')")
	end
end

local function evalCall(node, env, depth)
	local evaluatedArgs = {}
	for idx, argNode in ipairs(node.arguments) do
		evaluatedArgs[idx] = evaluate(argNode, env, depth)
	end
	local funcOrDef = evaluate(node.callee, env, depth)
	return callValue(funcOrDef, evaluatedArgs, depth, node.line, describeCallee(node.callee))
end

local function evalMethodCall(node, env, depth)
	local objVal = evaluate(node.object, env, depth)
	if objVal == nil then
		error("input:" .. node.line .. ": attempt to index a nil value")
	end
	local funcOrDef = indexValue(objVal, node.method, node.line)
	local evaluatedArgs = { objVal }
	for idx, argNode in ipairs(node.arguments) do
		evaluatedArgs[idx + 1] = evaluate(argNode, env, depth)
	end
	return callValue(funcOrDef, evaluatedArgs, depth, node.line, node.method)
end

evaluate = function(node, env, depth)
	local t = node.type

	if t == "NumberLiteral" or t == "StringLiteral" or t == "BoolLiteral" then
		return node.value

	elseif t == "NilLiteral" then
		return nil

	elseif t == "Identifier" then
		return env[node.name]

	elseif t == "IndexExpr" then
		local objVal = evaluate(node.object, env, depth)
		if objVal == nil then
			error("input:" .. node.line .. ": attempt to index a nil value")
		end
		local keyVal = evaluate(node.key, env, depth)
		return indexValue(objVal, keyVal, node.line)

	elseif t == "TableConstructor" then
		local tbl = {}
		for _, itemNode in ipairs(node.arrayPart) do
			table.insert(tbl, evaluate(itemNode, env, depth))
		end
		for _, pair in ipairs(node.hashPart) do
			local k = evaluate(pair.key, env, depth)
			tbl[k] = evaluate(pair.value, env, depth)
		end
		return tbl

	elseif t == "MethodCallExpression" then
		return evalMethodCall(node, env, depth)

	elseif t == "FunctionExpr" then
		return {
			__isUserFunction = true,
			params = node.params,
			body = node.body,
			closureEnv = env,
		}

	elseif t == "UnaryExpr" then
		if node.operator == "not" then
			return not truthy(evaluate(node.operand, env, depth))
		end
		local val = evaluate(node.operand, env, depth)
		if type(val) ~= "number" then
			error("input:" .. node.line .. ": attempt to perform arithmetic (unm) on a " .. luaType(val) .. " value")
		end
		return -val

	elseif t == "LogicalExpr" then
		local l = evaluate(node.left, env, depth)
		if node.operator == "and" then
			if not truthy(l) then return l end
			return evaluate(node.right, env, depth)
		else
			if truthy(l) then return l end
			return evaluate(node.right, env, depth)
		end

	elseif t == "BinaryExpr" then
		local l = evaluate(node.left, env, depth)
		local r = evaluate(node.right, env, depth)
		local op = node.operator

		local function assertNumberOperands()
			if type(l) ~= "number" or type(r) ~= "number" then
				local badVal = type(l) ~= "number" and l or r
				error("input:" .. node.line .. ": attempt to perform arithmetic on a " .. luaType(badVal) .. " value")
			end
		end

		if op == "+" then assertNumberOperands(); return l + r
		elseif op == "-" then assertNumberOperands(); return l - r
		elseif op == "*" then assertNumberOperands(); return l * r
		elseif op == "/" then
			assertNumberOperands()
			if r == 0 then error("input:" .. node.line .. ": attempt to divide by zero") end
			return l / r
		elseif op == "%" then
			assertNumberOperands()
			if r == 0 then error("input:" .. node.line .. ": attempt to perform '%%' with zero") end
			return l % r
		elseif op == ".." then return tostring(l) .. tostring(r)
		elseif op == "==" then return l == r
		elseif op == "~=" then return l ~= r
		elseif op == "<" then return l < r
		elseif op == ">" then return l > r
		elseif op == "<=" then return l <= r
		elseif op == ">=" then return l >= r
		end

	elseif t == "CallExpression" then
		return evalCall(node, env, depth)
	end
end

execBlock = function(statements, env, depth)
	for _, stmt in ipairs(statements) do
		local t = stmt.type

		if t == "LocalAssign" then
			env[stmt.name] = evaluate(stmt.value, env, depth)

		elseif t == "AssignStatement" then
			local value = evaluate(stmt.value, env, depth)
			if stmt.target.type == "Identifier" then
				assignVar(env, stmt.target.name, value)
			else
				local objVal = evaluate(stmt.target.object, env, depth)
				if objVal == nil then
					error("input:" .. stmt.line .. ": attempt to index a nil value")
				end
				local keyVal = evaluate(stmt.target.key, env, depth)
				setIndexValue(objVal, keyVal, value, stmt.line)
			end

		elseif t == "LocalFunctionDecl" then
			env[stmt.name] = {
				__isUserFunction = true,
				params = stmt.params,
				body = stmt.body,
				closureEnv = env,
			}

		elseif t == "IfStatement" then
			local handled = false
			for _, clause in ipairs(stmt.clauses) do
				if truthy(evaluate(clause.condition, env, depth)) then
					local sig, val = execBlock(clause.body, newScope(env), depth)
					if sig then return sig, val end
					handled = true
					break
				end
			end
			if not handled and stmt.elseBody then
				local sig, val = execBlock(stmt.elseBody, newScope(env), depth)
				if sig then return sig, val end
			end

		elseif t == "WhileStatement" then
			local iterations = 0
			while truthy(evaluate(stmt.condition, env, depth)) do
				iterations = iterations + 1
				checkStop()
				if iterations > MAX_LOOP_ITERATIONS then
					error("input:" .. stmt.line .. ": 'while' loop exceeded " .. MAX_LOOP_ITERATIONS .. " iterations")
				end
				local sig, val = execBlock(stmt.body, newScope(env), depth)
				if sig == SIGNAL_RETURN then return sig, val end
				if sig == SIGNAL_BREAK then break end
			end

		elseif t == "ForStatement" then
			local startVal = evaluate(stmt.startExpr, env, depth)
			local stopVal = evaluate(stmt.stopExpr, env, depth)
			local stepVal = stmt.stepExpr and evaluate(stmt.stepExpr, env, depth) or 1
			if type(startVal) ~= "number" or type(stopVal) ~= "number" or type(stepVal) ~= "number" then
				error("input:" .. stmt.line .. ": 'for' loop range must be numbers")
			end
			if stepVal == 0 then
				error("input:" .. stmt.line .. ": 'for' step is zero")
			end

			local iterations = 0
			local i = startVal
			while (stepVal > 0 and i <= stopVal) or (stepVal < 0 and i >= stopVal) do
				iterations = iterations + 1
				checkStop()
				if iterations > MAX_LOOP_ITERATIONS then
					error("input:" .. stmt.line .. ": 'for' loop exceeded " .. MAX_LOOP_ITERATIONS .. " iterations")
				end
				local loopScope = newScope(env)
				loopScope[stmt.varName] = i
				local sig, val = execBlock(stmt.body, loopScope, depth)
				if sig == SIGNAL_RETURN then return sig, val end
				if sig == SIGNAL_BREAK then break end
				i = i + stepVal
			end

		elseif t == "GenericForStatement" then
			local iterFunc, state, control
			if stmt.iterExpr.type == "CallExpression" then
				iterFunc, state, control = evalCall(stmt.iterExpr, env, depth)
			elseif stmt.iterExpr.type == "MethodCallExpression" then
				iterFunc, state, control = evalMethodCall(stmt.iterExpr, env, depth)
			else
				iterFunc = evaluate(stmt.iterExpr, env, depth)
			end
			local iterations = 0
			while true do
				iterations = iterations + 1
				checkStop()
				if iterations > MAX_LOOP_ITERATIONS then
					error("input:" .. stmt.line .. ": 'for' loop exceeded " .. MAX_LOOP_ITERATIONS .. " iterations")
				end
				local results = { iterFunc(state, control) }
				if results[1] == nil then break end
				control = results[1]
				local loopScope = newScope(env)
				for i, n in ipairs(stmt.names) do
					loopScope[n] = results[i]
				end
				local sig, val = execBlock(stmt.body, loopScope, depth)
				if sig == SIGNAL_RETURN then return sig, val end
				if sig == SIGNAL_BREAK then break end
			end

		elseif t == "ReturnStatement" then
			local val = stmt.value and evaluate(stmt.value, env, depth) or nil
			return SIGNAL_RETURN, val

		elseif t == "BreakStatement" then
			return SIGNAL_BREAK, nil

		elseif t == "ExpressionStatement" then
			evaluate(stmt.expression, env, depth)
		end
	end
	return nil, nil
end

local function appendOutput(text)
	outputLabel.Text = text
end

local ALLOWED_SERVICES = {
	Workspace = true, Players = true, Lighting = true, ReplicatedStorage = true,
	TweenService = true, RunService = true, UserInputService = true,
	SoundService = true, Debris = true, TextService = true, StarterGui = true,
	CollectionService = true, ContentProvider = true, HttpService = true,
}

local ALLOWED_CLASSES = {
	Part = true, WedgePart = true, MeshPart = true, Model = true, Folder = true,
	Frame = true, TextLabel = true, TextButton = true, TextBox = true,
	ImageLabel = true, ImageButton = true, ScreenGui = true, UIListLayout = true,
	UIPadding = true, UICorner = true, Sound = true, Attachment = true,
	Vector3Value = true, NumberValue = true, StringValue = true, BoolValue = true,
	Humanoid = true, BodyVelocity = true, BodyPosition = true, Highlight = true,
}

local function trackTask(fn, ...)
	local args = { ... }
	local ok, err = pcall(function()
		return callValue(fn, args, 0, 0, "task")
	end)
	if not ok then
		warn("[Sandbox]:", tostring(err))
	end
end

local SANDBOX_ENV = {
	print = function(...)
		local parts = {}
		for _, v in ipairs({ ... }) do
			table.insert(parts, tostring(v))
		end
		local line = table.concat(parts, "\t")
		print("[Sandbox]:", line)
		appendOutput(line)
	end,
	warn = function(...)
		local parts = {}
		for _, v in ipairs({ ... }) do
			table.insert(parts, tostring(v))
		end
		local line = table.concat(parts, "\t")
		warn("[Sandbox]:", line)
		appendOutput("WARN: " .. line)
	end,
	math_floor = function(n) return math.floor(n) end,
	math_ceil = function(n) return math.ceil(n) end,
	math_abs = function(n) return math.abs(n) end,
	math_random = function(a, b) return math.random(a, b) end,
	math_max = function(a, b) return math.max(a, b) end,
	math_min = function(a, b) return math.min(a, b) end,
	string_len = function(s) return #tostring(s) end,
	string_upper = function(s) return tostring(s):upper() end,
	string_lower = function(s) return tostring(s):lower() end,
	math = {
		floor = function(n) return math.floor(n) end,
		ceil = function(n) return math.ceil(n) end,
		abs = function(n) return math.abs(n) end,
		sqrt = function(n) return math.sqrt(n) end,
		random = function(a, b)
			if a == nil then return math.random() end
			if b == nil then return math.random(a) end
			return math.random(a, b)
		end,
		max = function(...) return math.max(...) end,
		min = function(...) return math.min(...) end,
		sign = function(n) if n > 0 then return 1 elseif n < 0 then return -1 else return 0 end end,
		clamp = function(n, lo, hi) if n < lo then return lo elseif n > hi then return hi else return n end end,
		pi = math.pi,
		huge = math.huge,
	},
	string = {
		len = function(s) return #tostring(s) end,
		upper = function(s) return tostring(s):upper() end,
		lower = function(s) return tostring(s):lower() end,
		sub = function(s, i, j) return tostring(s):sub(i, j) end,
		find = function(s, pattern) return tostring(s):find(pattern, 1, true) end,
		rep = function(s, n) return tostring(s):rep(n) end,
		reverse = function(s) return tostring(s):reverse() end,
		byte = function(s, i) return tostring(s):byte(i) end,
		char = function(...) return string.char(...) end,
		format = function(fmt, ...) return string.format(fmt, ...) end,
	},
	os = {
		time = function() return os.time() end,
		clock = function() return os.clock() end,
	},
	tostring = function(v) return tostring(v) end,
	tonumber = function(v) return tonumber(v) end,
	typeof = function(v)
		if type(v) == "userdata" then
			local ok, result = pcall(function() return v.ClassName end)
			if ok then return "Instance" end
		end
		return typeof and typeof(v) or type(v)
	end,
	ipairs = function(t) return ipairs(t) end,
	pairs = function(t) return pairs(t) end,
	table = {
		insert = function(t, a, b)
			if b ~= nil then table.insert(t, a, b) else table.insert(t, a) end
		end,
		remove = function(t, i)
			if i ~= nil then return table.remove(t, i) else return table.remove(t) end
		end,
		concat = function(t, sep) return table.concat(t, sep) end,
		sort = function(t) table.sort(t) end,
	},
	Vector3 = Vector3,
	Vector2 = Vector2,
	CFrame = CFrame,
	Color3 = Color3,
	UDim2 = UDim2,
	UDim = UDim,
	Enum = Enum,
	workspace = workspace,
	game = setmetatable({}, {
		__index = function(_, key)
			if key == "GetService" then
				return function(_, serviceName)
					if not ALLOWED_SERVICES[serviceName] then
						error("service '" .. tostring(serviceName) .. "' is not accessible from this sandbox")
					end
					return game:GetService(serviceName)
				end
			end
			error("attempt to index 'game' with '" .. tostring(key) .. "'")
		end,
		__tostring = function() return "game" end,
	}),
	Instance = {
		new = function(className, parentInst)
			if not ALLOWED_CLASSES[className] then
				error("'" .. tostring(className) .. "' is not creatable from this sandbox")
			end
			local inst = Instance.new(className)
			if parentInst ~= nil then
				inst.Parent = parentInst
			end
			return inst
		end,
	},
	task = {
		wait = function(seconds)
			return task.wait(seconds)
		end,
		spawn = function(fn, ...)
			return trackTask(fn, ...)
		end,
		delay = function(seconds, fn, ...)
			local args = { ... }
			return task.delay(seconds, function()
				trackTask(fn, table.unpack(args))
			end)
		end,
		defer = function(fn, ...)
			local args = { ... }
			return task.defer(function()
				trackTask(fn, table.unpack(args))
			end)
		end,
	},
}

local function runCode(sourceCode)
	if type(sourceCode) ~= "string" then
		return false, "input: script must be a string"
	end
	if #sourceCode > 4000 then
		return false, "input: script too long (max 4000 characters)"
	end

	stopRequested = false
	local env = newScope(SANDBOX_ENV)

	local knownBuiltins = {}
	for name in pairs(SANDBOX_ENV) do
		knownBuiltins[name] = true
	end

	local ok, tokensOrErr = pcall(tokenize, sourceCode)
	if not ok then return false, tostring(tokensOrErr) end

	local ok2, astOrErr = pcall(parse, tokensOrErr, knownBuiltins)
	if not ok2 then return false, tostring(astOrErr) end

	local ok3, sigOrErr = pcall(execBlock, astOrErr.body, env, 0)
	if not ok3 then
		if type(sigOrErr) == "table" and sigOrErr.__isStopSentinel then
			return false, "input: script stopped"
		end
		return false, tostring(sigOrErr)
	end

	return true, nil
end

local lastRun = 0
local RUN_COOLDOWN = 0.5
local isRunning = false

runButton.MouseButton1Click:Connect(function()
	local now = os.clock()
	if now - lastRun < RUN_COOLDOWN then
		return
	end
	if isRunning then
		return
	end
	lastRun = now
	isRunning = true

	appendOutput("Running...")
	local sourceCode = textBox.Text
	task.spawn(function()
		local ok, err = runCode(sourceCode)
		if not ok then
			appendOutput(err)
		end
		isRunning = false
	end)
end)

stopButton.MouseButton1Click:Connect(function()
	if isRunning then
		stopRequested = true
	end
end)
