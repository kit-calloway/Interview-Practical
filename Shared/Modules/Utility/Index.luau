export type Index = {
	Items: {[string]: boolean},
}

local Index = {}

function Index.new(keys: {string}): Index
	local index = { Items = {}, }
	for _, key in keys do
		Index.SetDiscovered(index, key, false)
	end
	return index
end

--[[
	Returns whether a provided key is discovered.
]]
function Index.IsDiscovered(index: Index, key: string): boolean
	return index.Items[key]
end

--[[
	Marks the provided key as discovered or otherwise.
	Returns the result of Index.GetProgress().
]]
function Index.SetDiscovered(index: Index, key: string, discovered: boolean): (number, number)
	index.Items[key] = discovered
	return Index.GetProgress(index)
end

--[[
	Returns a tuple containing the current amount of discovered keys, and the total amount of keys in the index.
]]
function Index.GetProgress(index: Index): (number, number)
	local discovered = 0
	local total = 0
	for _, isDiscovered in index.Items do
		discovered += if isDiscovered then 1 else 0
		total += 1
	end
	return discovered, total
end

return Index