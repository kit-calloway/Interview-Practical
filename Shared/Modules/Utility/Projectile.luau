local Projectile = {}
Projectile.__index = Projectile

--[[
    Creates a new projectile object.
]]
function Projectile.new(position: Vector3, velocity: Vector3, acceleration: Vector3?, raycastParams: RaycastParams?)
    local projectile = {
        Position = position,
        Velocity = velocity,
        Acceleration = acceleration or Vector3.zero,
        RaycastParams = raycastParams or RaycastParams.new(),
    }
    setmetatable(projectile, Projectile)
    return projectile
end

--[[
    Updates a projectile's velocity and position.
    Returns a raycast result if the projectile collides with an object.
]]
function Projectile:Simulate(deltaTime: number): RaycastResult?
    self.Velocity += self.Acceleration * deltaTime

    local raycastResult = workspace:Raycast(
        self.Position,
        self.Velocity * deltaTime,
        self.RaycastParams
    )

    if raycastResult == nil then
        self.Position += self.Velocity * deltaTime
        return nil
    else
        self.Position = raycastResult.Position
        return raycastResult
    end
end

return Projectile