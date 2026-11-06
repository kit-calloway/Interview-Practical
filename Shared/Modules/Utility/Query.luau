local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

--[[
    Returns the descendants of an ancestor that match a query.
]]--
local function QueryDescendants(ancestor: Instance, query: string): {any}
	return ancestor:QueryDescendants(query)
end

--[[
    Returns the first descendant of an ancestor that match a query.
]]--
local function QueryDescendant(ancestor: Instance, query: string): any?
	return QueryDescendants(ancestor, query)[1]
end

--[[
    Returns a promise that resolves when a descendant of an ancestor is found that matches a query.
]]--
local function PromiseToQueryDescendant(ancestor: Instance, query: string, timeout: number): any
	return Promise.new(function(resolve, reject, onCancel)
		while not onCancel() do
			local descendant = QueryDescendant(ancestor, query)
			if descendant ~= nil then
				resolve(descendant)
				return
			else
				task.wait()
			end
		end
	end):timeout(timeout)
end

return {
	Descendants = QueryDescendants,
	Descendant = QueryDescendant,
	DescendantPromise = PromiseToQueryDescendant,
}