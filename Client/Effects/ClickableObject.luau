local ReplicatedStorage = game:GetService("ReplicatedStorage")
const TweenService = game:GetService("TweenService")
const RunService = game:GetService("RunService")

const ClickableObjectsConfig = require("@game/ReplicatedStorage/Shared/Config/Minigames/ClickableObjectsConfig")
const MouseCast = require("@game/ReplicatedStorage/Shared/Modules/Utility/MouseCast")
const Observers = require("@game/ReplicatedStorage/Packages/Observers")
const Promise = require("@game/ReplicatedStorage/Packages/Promise")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")
const Query = require("@game/ReplicatedStorage/Shared/Modules/Utility/Query")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")

export type Key = Model
export type Component = {
	Key: Key,
	Trove: any,
	Highlight: Highlight,
	Selected: any,
}

local SELECT_ACTION = Query.Descendant(ReplicatedStorage.Shared.Assets, "InputAction#Select") :: InputAction
local VALID_ANCESTORS = {
	workspace,
}

local Components = {} :: {[Key]: Component}
local CurrentHoveredObject = nil :: Key?

--[[
	Returns the selected signal for a clickable object.
--]]
local function GetSelectedSignal(key: Key): any
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	return component.Selected
end

--[[
	Returns the dot product of the mouse's vector and a clickable object.
--]]
local function GetDotProduct(key: Key): number
	local mouseVector = MouseCast.GetRay().Direction.Unit
	local cameraPosition = workspace.CurrentCamera.CFrame.Position
	local objectPosition = key:GetPivot().Position
	local cameraOffset = (objectPosition - cameraPosition).Unit
	return cameraOffset:Dot(mouseVector)
end

--[[
	Sets up a clickable object's highlight
--]]
local function SetUpHighlight(key: Key)
	local component = Components[key]
	assert(component ~= nil, "Invalid component key!")
	component.Highlight.Parent = key
	component.Highlight.Enabled = false
	component.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	component.Highlight.FillColor = ClickableObjectsConfig.Highlight.FillColor
	component.Highlight.OutlineColor = ClickableObjectsConfig.Highlight.OutlineColor
	component.Highlight.FillTransparency = ClickableObjectsConfig.Highlight.Tween.UnhoveredProperties.FillTransparency
	component.Highlight.OutlineTransparency = ClickableObjectsConfig.Highlight.Tween.UnhoveredProperties.OutlineTransparency
end

--[[
    Constructs a component.
]]
local function Construct(key: Key)
	local component = {
		Key = key,
		Trove = Trove.new(),
		Highlight = Instance.new("Highlight"),
		Selected = Signal.new(),
	} :: Component

	Components[key] = component
	
	SetUpHighlight(key)
end

--[[
    Deconstructs a component.
]]
local function Deconstruct(key: Key)
	local component = Components[key]
	if component == nil then return end
	component.Trove:Clean()
	component.Trove = nil
	Components[component.Key] = nil
end

--[[
	Returns whether an instance is a component key.
--]]
local function IsComponent(key: Key): boolean
	return Components[key] ~= nil
end

--[[
	Returns a promise that resolves when a component is created.
--]]
local function WaitForComponent(key: Key, timeout: number): any
	return Promise.try(function()
		while not IsComponent(key) do
			task.wait()
		end
	end)
	:timeout(timeout)
end

--[[
	Returns the current hovered object.
--]]
local function GetCurrentHoveredObject(): Key?
	local bestObject
	local bestDotProduct = -1
	for key in Components do
		local dotProduct = GetDotProduct(key)
		if dotProduct < ClickableObjectsConfig.Selection.DotProductThreshold then continue end
		if dotProduct < bestDotProduct then continue end
		bestDotProduct = dotProduct
		bestObject = key
	end
	return bestObject
end

--[[
	Updates the current hovered object.
--]]
local function UpdateCurrentHoveredObject()
	local currentHoveredObject = GetCurrentHoveredObject()
	if CurrentHoveredObject == currentHoveredObject then return end -- No change
	
	local components = {
		Old = if CurrentHoveredObject ~= nil then Components[CurrentHoveredObject] else nil,
		New = if currentHoveredObject ~= nil then Components[currentHoveredObject] else nil,
	}
	
	CurrentHoveredObject = currentHoveredObject
	
	if components.Old ~= nil then
		local hideTween = TweenService:Create(
			components.Old.Highlight,
			ClickableObjectsConfig.Highlight.Tween.TweenInfo,
			ClickableObjectsConfig.Highlight.Tween.UnhoveredProperties
		)
		hideTween:Play()
		hideTween.Completed:Once(function()
			if CurrentHoveredObject == components.Old.Key then return end
			components.Old.Highlight.Enabled = false
		end)
	end
	
	if components.New ~= nil then
		local showTween = TweenService:Create(
			components.New.Highlight,
			ClickableObjectsConfig.Highlight.Tween.TweenInfo,
			ClickableObjectsConfig.Highlight.Tween.HoveredProperties
		)
		showTween:Play()
		components.New.Highlight.Enabled = true
	end
end

--[[
	Attempts to fire a signal on the current hovered object.
--]]
local function OnSelectAction()
	if CurrentHoveredObject == nil then return end
	local component = Components[CurrentHoveredObject]
	assert(component ~= nil, "Invalid component key!")
	component.Selected:Fire()
end

--[[
    Main entry function to the module. Performs module-specific setup.
]]
local function Start()
	Observers.observeTag(
		script.Name,
		function(key: Key)
			Construct(key)
			return function()
				Deconstruct(key)
			end
		end,
		VALID_ANCESTORS
	)
	
	RunService.RenderStepped:Connect(UpdateCurrentHoveredObject)
	SELECT_ACTION.Released:Connect(OnSelectAction)
end

Start()

return {
	GetSelectedSignal = GetSelectedSignal,
	
	IsComponent = IsComponent,
	WaitForComponent = WaitForComponent,
}