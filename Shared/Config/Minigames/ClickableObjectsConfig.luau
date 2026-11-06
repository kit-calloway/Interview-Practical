return {
	Selection = {
		DotProductThreshold = 0.99,
	},
	Highlight = {
		FillColor = Color3.new(0, 0.533333, 1),
		OutlineColor = Color3.new(0, 0.533333, 1),
		Tween = {
			TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear),
			HoveredProperties = {
				FillTransparency = 0.5,
				OutlineTransparency = 0,
			},
			UnhoveredProperties = {
				FillTransparency = 1,
				OutlineTransparency = 1,
			},
		}
	},
}