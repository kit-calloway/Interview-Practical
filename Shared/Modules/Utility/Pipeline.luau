export type Callback<T> = (T, ...any) -> T
export type Pipeline<T> = {
	Steps: {Callback<T>},
	SetStep: (Pipeline<T>, index: number, callback: Callback<T>) -> Pipeline<T>,
	CalculateValue: (Pipeline<T>, startingValue: T, ...any) -> T
}

--[[
    Sets a step in a pipeline.
]]--
local function SetStep<T>(pipeline: Pipeline<T>, index: number, callback: Callback<T>): Pipeline<T>
	pipeline.Steps[index] = callback
	return pipeline
end

--[[
    Calculates and returns a value.
]]--
local function CalculateValue<T>(pipeline: Pipeline<T>, startingValue: T, ...): T
	local value = startingValue
	for _, callback in pipeline.Steps do
		value = callback(value, ...)
	end
	return value
end

--[[
    Returns a new pipeline object.
]]--
local function new<T>(): Pipeline<T>
	local pipeline = {
		Steps = {},
		SetStep = SetStep,
		CalculateValue = CalculateValue,
	}
	return pipeline
end

return {
	new = new,
	SetStep = SetStep,
	CalculateValue = CalculateValue,
}