const NAMES = {
	"Kit",
	"Amity",
	"Jade",
	"Ember",
	"Maple",
	"Rusty",
	"Ginger",
	"Copper",
	"Russet",
	"Cinder",
	"Saffron",
	"Nutmeg",
	"Marigold",
	"Juniper",
	"Willow",
	"Hazel",
	"Clover",
	"Sorrel",
	"Basil",
	"Fennel",
	"Sage",
	"Rowan",
	"Briar",
	"Bramble",
	"Thistle",
	"Tansy",
	"Pip",
	"Poppy",
	"Biscuit",
	"Mochi",
	"Fig",
	"Olive",
	"Wren",
	"Gilad Pellaeon", -- Addition from my girlfriend. She says hi!
}

--[[
	Returns a random name from the name list.
--]]
local function PickRandom(): string
	local index = math.random(1, #NAMES)
	return NAMES[index]
end

return {
	PickRandom = PickRandom,
}