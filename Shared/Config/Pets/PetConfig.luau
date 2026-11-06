const Timestamp = require("@game/ReplicatedStorage/Shared/Modules/Utility/Timestamp")

export type PetSchema = { 
	Name: string,
	Needs: {
		Food: number,
		Happiness: number,
		Cleanliness: number,
		-- NOTE: Suggestions for extra needs
		-- Energy: number
		-- Affection: number
	},
}

return {
	Name = {
		Length = NumberRange.new(3, 12),
		AllowedPattern = "^[%w%s]+$", -- Matches strings with alphanumeric characters and spaces
	},
	Needs = {
		DefaultValue = { -- The starting value of a need for a new pet
			Food = 0.6,
			Happiness = 0.8,
			Cleanliness = 1,
		},
		DecayInterval = 1,
		DecayDuration = { -- How long each need takes to decay fully
			Food = 2 * Timestamp.SECONDS_IN.Minute,
			Happiness = 2 * Timestamp.SECONDS_IN.Minute,
			Cleanliness = 3 * Timestamp.SECONDS_IN.Minute,
		},
	},
}