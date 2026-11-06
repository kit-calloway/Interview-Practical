export type Duration = {
	Weeks: number,
	Days: number,
	Hours: number,
	Minutes: number,
	Seconds: number,
}

local Timestamp = {}

Timestamp.SECONDS_IN = {
	Minute = 60,
	Hour = 60 * 60,
	Day = 24 * 60 * 60,
	Week = 7 * 24 * 60 * 60,
}

--[[
	Converts an amount of seconds into a Duration object.
]]
function Timestamp.SecondsToDuration(seconds: number | Duration): Duration
	if typeof(seconds) ~= "number" then return seconds end
	local weeks = seconds // Timestamp.SECONDS_IN.Week
	seconds -= weeks * Timestamp.SECONDS_IN.Week
	local days = seconds // Timestamp.SECONDS_IN.Day
	seconds -= days * Timestamp.SECONDS_IN.Day
	local hours = seconds // Timestamp.SECONDS_IN.Hour
	seconds -= hours * Timestamp.SECONDS_IN.Hour
	local minutes = seconds // Timestamp.SECONDS_IN.Minute
	seconds -= minutes * Timestamp.SECONDS_IN.Minute
	
	return {
		Weeks = weeks,
		Days = days,
		Hours = hours,
		Minutes = minutes,
		Seconds = seconds,
	}
end

--[[
	Converts a Duration object into an amount of seconds.
]]
function Timestamp.DurationToSeconds(duration: number | Duration): number
	if typeof(duration) == "number" then return duration end
	local seconds = 0
	seconds += duration.Seconds or 0
	seconds += (duration.Minutes or 0) * Timestamp.SECONDS_IN.Minute
	seconds += (duration.Hours or 0) * Timestamp.SECONDS_IN.Hour
	seconds += (duration.Days or 0) * Timestamp.SECONDS_IN.Day
	seconds += (duration.Weeks or 0) * Timestamp.SECONDS_IN.Week
	return seconds
end

--[[
	Converts a duration into a formatted string.
	Returns the two most significant increments of time (e.g. "5h 30m").
]]
function Timestamp.DurationToString(duration: number | Duration): string
	duration = math.ceil(duration)
	duration = Timestamp.SecondsToDuration(duration)
	
	local result = ""
	local increments = 0
	for _, increment in { "Weeks", "Days", "Hours", "Minutes", "Seconds" } do
		if duration[increment] == 0 then continue end
		increments += 1
		result ..= `{duration[increment]}{string.lower(string.sub(increment, 1, 1))} `
		if increments == 2 then break end
	end
	
	return string.gsub(result, "%s$", "") -- Remove trailing whitespace
end

--[[
	Returns an amount of seconds between now and the given timestamp.
]]
function Timestamp.SecondsSince(timestamp: number): number
	return os.time() - timestamp
end

--[[
	Returns a Duration object from the amount of seconds since the given timestamp.
]]
function Timestamp.DurationSince(timestamp: number): Duration
	local secondsSince = Timestamp.SecondsSince(timestamp)
	return Timestamp.SecondsToDuration(secondsSince)
end

--[[
	Returns whether a given duration of time has elapsed since the given timestamp.
]]
function Timestamp.HasTimePassed(timestamp: number, duration: number | Duration): boolean
	local seconds = Timestamp.DurationToSeconds(duration)
	return Timestamp.SecondsSince(timestamp) >= seconds
end

return Timestamp