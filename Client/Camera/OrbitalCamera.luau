const StarterPlayer = game:GetService("StarterPlayer")
const RunService = game:GetService("RunService")

const CameraConfig = require("@game/ReplicatedStorage/Shared/Config/Camera/CameraConfig")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")

const Camera = workspace.CurrentCamera
const Subject = Query.Descendant(workspace, "Model.Pet")

--[[
	Clamps the camera Y angle.
--]]
local function ClampCamera()
	local focusPosition = Camera.Focus.Position
	local offset = Camera.CFrame.Position - focusPosition
	local distance = offset.Magnitude

	-- Clamp the vertical elevation
	local elevation = math.asin(math.clamp(offset.Y / distance, -1, 1))
	local clampedElevation = math.clamp(elevation, CameraConfig.AngleRange.Min, CameraConfig.AngleRange.Max)

	-- Rebuild the offset at the clamped angle, keeping the same distance and heading
	local horizontalOffset = offset * Vector3.new(1, 0, 1)
	local horizontal = horizontalOffset.Unit * (math.cos(clampedElevation) * distance)
	local vertical = Vector3.yAxis * (math.sin(clampedElevation) * distance)
	local newOffset = horizontal + vertical
	
	Camera.CFrame = CFrame.lookAt(focusPosition + newOffset, focusPosition)
end

--[[
	Sets up the camera's properties.
--]]
local function SetUpCamera()
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Subject
	Camera.Focus = CFrame.new(Vector3.zero)
end

--[[
	Sets up left-click camera pan input binding.
--]]
local function SetUpInput()
	Query.DescendantPromise(StarterPlayer, "InputAction#CameraPanActiveAction > InputBinding#MouseBinding", 5)
	:andThen(function(rightInputBinding: InputBinding)
		local leftInputBinding = rightInputBinding:Clone()
		leftInputBinding.Parent = rightInputBinding.Parent
		leftInputBinding.KeyCode = Enum.KeyCode.MouseLeftButton
	end)
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	SetUpCamera()
	SetUpInput()
	RunService:BindToRenderStep("ClampCamera", Enum.RenderPriority.Camera.Value + 1, ClampCamera)
end

Start()

return {}