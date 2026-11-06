local UserInputService = game:GetService("UserInputService")

local MouseCast = {}

--[[
    Returns a ray projected from the player's mouse location.
]]
function MouseCast.GetRay(): Ray
    local mouseLocation = UserInputService:GetMouseLocation()
    return workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y, 0)
end

--[[
    Returns a Raycast result of the mouse position.
]]
function MouseCast.Cast(range: number, exclude: {Instance}?): RaycastResult?
    local ray = MouseCast.GetRay()
    local raycastParams = RaycastParams.new()
    raycastParams.ExcludeInstances = exclude
    return workspace:Raycast(ray.Origin, ray.Direction * range, raycastParams)
end

--[[
    Returns the position of air beneath the player's mouse.
]]
function MouseCast.AirCast(range: number, exclude: {Instance}?): Vector3
    local ray = MouseCast.GetRay()
    local raycastResult = MouseCast.Cast(range, exclude)
    return
        if raycastResult ~= nil then raycastResult.Position
        else ray.Origin + ray.Direction * range
end

--[[
    Returns the position of ground beneath the player's mouse.
]]
function MouseCast.GroundCast(range: number, maxHeight: number, exclude: {Instance}?): RaycastResult?
    local airPosition = MouseCast.AirCast(range, exclude)
    return workspace:Raycast(airPosition + Vector3.yAxis * 0.1, -Vector3.yAxis * maxHeight)
end

return MouseCast