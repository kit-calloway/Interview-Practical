local TableNavigator = {}

--[[
    Returns nested data from within a table.
]]
function TableNavigator.Get<T>(source: {}, path: string): T?
    local data = source
    local steps = path:split(".")
	for _, step in steps do
		if typeof(data) ~= "table" then return nil end
		if data == nil then return nil end
		data = data[step]
	end
    return data
end

return TableNavigator