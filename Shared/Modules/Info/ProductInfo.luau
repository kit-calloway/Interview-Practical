local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local NumberFormatter = require(ReplicatedStorage.Shared.Modules.Utility.NumberFormatter)

export type Discount = {
	Type: Enum.DiscountType,
	AmountInRobux: number,
	Percent: number,
}
export type ProductInfo = {
	Name: string,
	Description: string,
	PriceInRobux: number,
	UserBasePriceInRobux: number,
	PriceDiscountDetails: {Discount},
	ProductType: string,
	Created: string,
	Updated: string,
	TargetId: number,
}
export type SubscriptionInfo = {
	Name: string,
	Description: string,
	IconImageAssetId: number,
	SubscriptionPeriod: Enum.SubscriptionPeriod,
	DisplayPrice: string,
	DisplaySubscriptionPeriod: string,
	IsForSale: boolean,
	PriceTier: number,
	PriceInRobux: number,
}

local InfoCache = {}

--[[
    Returns a promise that resolves to info about a gamepass or dev product.
]]--
local function GetInfo(productId: number, productType: Enum.InfoType): any
	local cached = InfoCache[productId] ~= nil
	
	if not cached then
		local getInfoFn =
			if productType == Enum.InfoType.Subscription
			then MarketplaceService.GetSubscriptionProductInfoAsync
			else MarketplaceService.GetProductInfoAsync
		InfoCache[productId] = Promise.retryWithDelay(
			Promise.try,
			5,
			1,
			getInfoFn, 
			MarketplaceService, 
			productId, 
			productType
		)
	end
	
	return InfoCache[productId]
end

--[[
    Returns a promise that resolves to the price of a gamepass or dev product.
]]--
local function GetPrice(productId: number, productType: Enum.InfoType): any
	return GetInfo(productId, productType):andThen(
		function(info)
			return info.PriceInRobux 
		end)
end

--[[
    Returns a promise that resolves to the price of a list of gamepasses and dev products.
]]--
local function GetCumulativePrice(productIds: {number}, productType: Enum.InfoType): any
	local promises = {}
	for _, productId in productIds do
		local promise = GetPrice(productId, productType)
		table.insert(promises, promise)
	end
	
	return Promise.all(promises)
		:andThen(function(prices)
			local total = 0
			for _, price in prices do
				total += price
			end
			return total
		end)
end

--[[
    Formats a price as a string.
]]--
local function FormatPrice(price: number): string
	return `\u{E002}{NumberFormatter.AddDelimiters(price)}`
end

return {
	GetInfo = GetInfo,
	GetPrice = GetPrice,
	GetCumulativePrice = GetCumulativePrice,
	FormatPrice = FormatPrice,
}