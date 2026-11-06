--[[
    Substitutes all instances of a string with a new string.
]]--
local function Substitute(source: string, replacements: {[string]: string}): string
	for from, to in replacements do
		source = source:gsub(`\{{from}}`, to)
	end
	return source
end

--[[
    Returns the pluralized form of a noun depending on the context.
]]--
local function Pluralize(singular: string, amount: number): string
	return if amount == 1 then singular else `{singular}s`
end

return {
	Substitute = Substitute,
	Pluralize = Pluralize,
}