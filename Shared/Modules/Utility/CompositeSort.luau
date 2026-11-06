local CompositeSort = {}

export type Criteria = {
    Value: number,
    Width: number,
}

export type Element<T> = {
    Id: T,
    Values: {number},
}

export type CompositeSortResult<T> = {
    Id: T,
    Key: number,
}

--[[
    Useful for when you want to "score" an element by multiple criteria.
    It returns a single value based on a list of criteria, ordered in descending priority.
]]
function CompositeSort.CalculateCompositeKey(criteriaList: {Criteria}): number
    local key = 0
    local offset = 32

	for _, criteria in criteriaList do
        key = bit32.replace(key, criteria.Value, offset - criteria.Width, criteria.Width)
        offset -= criteria.Width
    end

    return key
end

--[[
    Sorts a list of elements by a list of criteria. See <code>Sort.CalculateCompositeKey</code> for further details.
]]
function CompositeSort.SortByCompositeKey<T>(criteriaWidths: {number}, elements: {Element<T>}): {Element<T>}
    -- Create criteria lists
    local criteriaLists = {}
    for _, element in elements do
        criteriaLists[element.Id] = {}
        for index, value in element.Values do
            local criteria = {
                Value = value,
				Width = criteriaWidths[index],
            }
            table.insert(criteriaLists[element.Id], criteria)
        end
    end

    -- Calculate keys for each element
    local results = {}
    for elementId, criteriaList in criteriaLists do
        local key = CompositeSort.CalculateCompositeKey(criteriaList)
        results[elementId] = key
    end

    -- Sort elements by keys
    local sortedList = table.clone(elements)
    table.sort(sortedList, function(elementA, elementB)
        local resultA = results[elementA.Id]
        local resultB = results[elementB.Id]
        return resultA < resultB
    end)
    return sortedList
end

return CompositeSort