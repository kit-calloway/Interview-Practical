local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

export type ComponentModule<T,U> = {
    _Construct: (T) -> U,
    _Destroy: (U) -> (),
    _Components: {[T]: U},
}

local ComponentModule = {}

--[[
    Performs setup for a component module.
    Should be called in the module's `Start()` function.
]]
function ComponentModule.new<T,U>(module: ComponentModule<T,U>, tag: string, ancestors: {Instance}?)
    Observers.observeTag(tag, function(object: T)
        local component = module._Construct(object)
        return function()
            module._Destroy(component)
        end
    end, ancestors)
end

return ComponentModule