--[[
	Returns a color sequence that is filled with one color up to a given point, and a second color afterward.
]]--
function SetColorSequenceProgress(progress: number, color1: Color3, color2: Color3): ColorSequence
	progress = math.clamp(progress, 0, 1)
	if progress == 0 then
		return ColorSequence.new(color2)
	elseif progress == 1 then
		return ColorSequence.new(color1)
	else
		local keypoints = {
			ColorSequenceKeypoint.new(0, color1),
			ColorSequenceKeypoint.new(progress, color1),
			ColorSequenceKeypoint.new(progress + 0.001, color2),
		}
		if keypoints[3].Time >= 1 then
			keypoints[3] = ColorSequenceKeypoint.new(1, color2)
		else
			keypoints[4] = ColorSequenceKeypoint.new(1, color2)
		end
		return ColorSequence.new(keypoints)
	end
end

--[[
	Returns a color sequence that is filled with one color up to a given point, and a second color afterward.
]]--
function SetNumberSequenceProgress(progress: number, value1: number, value2: number): NumberSequence
	progress = math.clamp(progress, 0, 1)
	if progress == 0 then
		return NumberSequence.new(value2)
	elseif progress == 1 then
		return NumberSequence.new(value1)
	else
		local keypoints = {
			NumberSequenceKeypoint.new(0, value1),
			NumberSequenceKeypoint.new(progress, value1),
			NumberSequenceKeypoint.new(progress + 0.001, value2),
		}
		if keypoints[3].Time >= 1 then
			keypoints[3] = NumberSequenceKeypoint.new(1, value2)
		else
			keypoints[4] = NumberSequenceKeypoint.new(1, value2)
		end
		return NumberSequence.new(keypoints)
	end
end

return {
	SetColorSequenceProgress = SetColorSequenceProgress,
	SetNumberSequenceProgress = SetNumberSequenceProgress,
}