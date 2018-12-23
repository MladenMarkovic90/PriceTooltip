--[[
	Addon: PriceTooltip
	Author: Mladen90
	Created by @Mladen90
]]--


PriceTooltip = {}
PriceTooltip_MENU = {}


local ATT_Sales = nil


PriceTooltip_ValidPrice = function(price) return price and price > 0 end


PriceTooltip_Round = function (num, numDecimalPlaces)
	if not num then return num end

	local decimalPlaces = numDecimalPlaces or 0

	if PriceTooltip.SavedVariables.RoundPrice then decimalPlaces = 0 end

	local mult = 10 ^ decimalPlaces
	return math.floor(num * mult + 0.5) / mult
end


PriceTooltip_NumberFormat = function(amount)
	local formatted = amount
	local separator = PriceTooltip.SavedVariables.Separator
	
	if separator == PRICE_TOOLTIP_SPACE then separator = " " end
	
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k==0) then break end
	end
	
	return formatted
end


PriceTooltip_GetPrices = function(itemLink)
	local prices =
	{
		vendorPrice = nil,
		profitPrice = nil,
		originalTTCPrice = nil,
		scaledTTCPrice = nil,
		originalMMPrice = nil,
		scaledMMPrice = nil,
		originalATTPrice = nil,
		scaledATTPrice = nil,
		originalAveragePrice = nil,
		scaledAveragePrice = nil,
		bestPrice = nil,
		bestPriceText = nil
	}

	if not itemLink then return nil end
	
	local icon, meetsUsageRequirement

	icon, prices.vendorPrice, meetsUsageRequirement = GetItemLinkInfo(itemLink)

	if not PriceTooltip_ValidPrice(prices.vendorPrice) then prices.vendorPrice = 0 end
	
	if PriceTooltip.SavedVariables.UseProfitPrice then
		prices.profitPrice = prices.vendorPrice * (1 + PriceTooltip.SavedVariables.ScaleProfitPrice / 100)
		if not PriceTooltip_ValidPrice(prices.profitPrice) then prices.profitPrice = 1 end
	end

	if PriceTooltip.SavedVariables.UseTTCPrice then
		if TamrielTradeCentrePrice then
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if priceInfo then prices.originalTTCPrice = priceInfo.SuggestedPrice end
			
			if PriceTooltip_ValidPrice(prices.originalTTCPrice)then
				prices.scaledTTCPrice = prices.originalTTCPrice * (1 + PriceTooltip.SavedVariables.ScaleTTCPrice / 100)
			end
		end
	end

	if PriceTooltip.SavedVariables.UseMMPrice then
		if MasterMerchant then
			prices.originalMMPrice = MasterMerchant.GetItemLinePrice(itemLink)
			
			if PriceTooltip_ValidPrice(prices.originalMMPrice) then
				prices.scaledMMPrice = prices.originalMMPrice * (1 + PriceTooltip.SavedVariables.ScaleMMPrice / 100)
			end
		end
	end

	if PriceTooltip.SavedVariables.UseATTPrice then
		if ATT_Sales then
			local fromTimeStamp = GetTimeStamp() - PriceTooltip.SavedVariables.ATTDays * 60 * 60 * 24
			prices.originalATTPrice = ATT_Sales:GetAveragePricePerItem(itemLink, fromTimeStamp)
			
			if PriceTooltip_ValidPrice(prices.originalATTPrice) then
				prices.scaledATTPrice = prices.originalATTPrice * (1 + PriceTooltip.SavedVariables.ScaleATTPrice / 100)
			end
		end
	end

	if PriceTooltip.SavedVariables.UseAveragePrice then
		prices.scaledAveragePrice = 0
		prices.originalAveragePrice = 0
		local count = 0

		if PriceTooltip_ValidPrice(prices.scaledTTCPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledTTCPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalTTCPrice
			count = count + 1
		end
		if PriceTooltip_ValidPrice(prices.scaledMMPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledMMPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalMMPrice
			count = count + 1
		end
		if PriceTooltip_ValidPrice(prices.scaledATTPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledATTPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalATTPrice
			count = count + 1
		end

		if count > 0 then
			prices.originalAveragePrice = prices.originalAveragePrice / count
			prices.scaledAveragePrice = prices.scaledAveragePrice / count
		end
	end
	
	if PriceTooltip.SavedVariables.UseBestPrice then
		prices.bestPrice = 0

		if PriceTooltip.SavedVariables.UseTTCPrice and PriceTooltip_ValidPrice(prices.scaledTTCPrice) and prices.scaledTTCPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledTTCPrice
			prices.bestPriceText = PRICE_TOOLTIP_TTC_PRICE
		end
		if PriceTooltip.SavedVariables.UseMMPrice and PriceTooltip_ValidPrice(prices.scaledMMPrice) and prices.scaledMMPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledMMPrice
			prices.bestPriceText = PRICE_TOOLTIP_MM_PRICE
		end
		if PriceTooltip.SavedVariables.UseATTPrice and PriceTooltip_ValidPrice(prices.scaledATTPrice) and prices.scaledATTPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledATTPrice
			prices.bestPriceText = PRICE_TOOLTIP_ATT_PRICE
		end
		if PriceTooltip.SavedVariables.UseProfitPrice and PriceTooltip_ValidPrice(prices.profitPrice) and prices.profitPrice > prices.bestPrice then
			prices.bestPrice = prices.profitPrice
			prices.bestPriceText = PRICE_TOOLTIP_PROFIT_PRICE
		end

		if not PriceTooltip_ValidPrice(prices.bestPrice) then
			prices.bestPrice = nil
			prices.bestPriceText = nil
		end
	end

	prices.profitPrice = PriceTooltip_Round(prices.profitPrice, 2)
	prices.originalTTCPrice = PriceTooltip_Round(prices.originalTTCPrice, 2)
	prices.scaledTTCPrice = PriceTooltip_Round(prices.scaledTTCPrice, 2)
	prices.originalMMPrice = PriceTooltip_Round(prices.originalMMPrice, 2)
	prices.scaledMMPrice = PriceTooltip_Round(prices.scaledMMPrice, 2)
	prices.originalATTPrice = PriceTooltip_Round(prices.originalATTPrice, 2)
	prices.scaledATTPrice = PriceTooltip_Round(prices.scaledATTPrice, 2)
	prices.originalAveragePrice = PriceTooltip_Round(prices.originalAveragePrice, 2)
	prices.scaledAveragePrice = PriceTooltip_Round(prices.scaledAveragePrice, 2)
	prices.bestPrice = PriceTooltip_Round(prices.bestPrice, 2)

	return prices
end


PriceTooltip_AddTooltip = function(control, itemLink)
	if not control then return end

	local prices = PriceTooltip_GetPrices(itemLink)
	if not prices then return end

	ZO_Tooltip_AddDivider(control)

	if PriceTooltip.SavedVariables.DisplayVendorPrice and PriceTooltip_ValidPrice(prices.vendorPrice) then
		control:AddLine(PriceTooltip_NumberFormat(prices.vendorPrice, 2) .. PRICE_TOOLTIP_GOLD_TEXT_ICON, PriceTooltip.SavedVariables.Font, PriceTooltip.SavedVariables.TooltipColor.Red, PriceTooltip.SavedVariables.TooltipColor.Green, PriceTooltip.SavedVariables.TooltipColor.Blue, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
	end

	if PriceTooltip.SavedVariables.UseTTCPrice and not TamrielTradeCentrePrice then
		control:AddLine("TTC not available!", PriceTooltip.SavedVariables.Font, 1, 0, 0, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
	end

	if PriceTooltip.SavedVariables.UseMMPrice and not MasterMerchant then
		control:AddLine("MM not available!", PriceTooltip.SavedVariables.Font, 1, 0, 0, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
	end

	if PriceTooltip.SavedVariables.UseATTPrice and not ATT_Sales then
		control:AddLine("ATT not available!", PriceTooltip.SavedVariables.Font, 1, 0, 0, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
	end

	if PriceTooltip.SavedVariables.DisplayProfitPrice then PriceTooltip_AddTooltipLine(control, PRICE_TOOLTIP_PROFIT_PRICE, prices.profitPrice, prices.vendorPrice, prices.profitPrice) end
	if PriceTooltip.SavedVariables.DisplayTTCPrice then PriceTooltip_AddTooltipLine(control, PRICE_TOOLTIP_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice, prices.profitPrice) end
	if PriceTooltip.SavedVariables.DisplayMMPrice then PriceTooltip_AddTooltipLine(control, PRICE_TOOLTIP_MM_PRICE, prices.scaledMMPrice, prices.vendorPrice, prices.profitPrice) end
	if PriceTooltip.SavedVariables.DisplayATTPrice then PriceTooltip_AddTooltipLine(control, PRICE_TOOLTIP_ATT_PRICE, prices.scaledATTPrice, prices.vendorPrice, prices.profitPrice) end
	if PriceTooltip.SavedVariables.DisplayAveragePrice then PriceTooltip_AddTooltipLine(control, PRICE_TOOLTIP_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice, prices.profitPrice) end
	if PriceTooltip.SavedVariables.DisplayBestPrice then PriceTooltip_AddTooltipLine(control, PRICE_TOOLTIP_BEST_PRICE, prices.bestPrice, prices.vendorPrice, prices.profitPrice, prices.bestPriceText) end
end


PriceTooltip_GetLowPriceIndicator = function(price, vendorPrice, profitPrice)
	local lowPriceIndikator = ""

	if PriceTooltip_ValidPrice(price) then
		if price <= vendorPrice then lowPriceIndikator = PriceTooltip_GetStringColor(1, 0, 0) .. "*"
		elseif PriceTooltip.SavedVariables.UseProfitPrice and price < profitPrice then lowPriceIndikator = PriceTooltip_GetStringColor(1, 1, 0) .. "*"
		end
	end

	return lowPriceIndikator
end

PriceTooltip_AddTooltipLine = function(control, text, price, vendorPrice, profitPrice, info)
	if PriceTooltip_ValidPrice(price) then
		if not info then info = ""
		else info = " (" .. info .. ")"
		end

		local lowPriceIndicator = ""
		if PriceTooltip.SavedVariables.LowPriceIndicatorTooltip then lowPriceIndicator = PriceTooltip_GetLowPriceIndicator(price, vendorPrice, profitPrice) end

		local stringColor = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.TooltipColor)
		control:AddLine(stringColor .. text .. " " .. lowPriceIndicator .. stringColor .. PriceTooltip_NumberFormat(price, 2) .. PRICE_TOOLTIP_GOLD_TEXT_ICON .. info, PriceTooltip.SavedVariables.Font, 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
	end
end


PriceTooltip_ToolTipExtension = function(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]
	
	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		
		if not getItemLinkFunction then return end
		
		local itemLink = getItemLinkFunction(...)
		
		if itemLink then PriceTooltip_AddTooltip(control, itemLink) end
	end
end


PriceTooltip_GetWornItemLink = function(equipSlot) return GetItemLink(BAG_WORN, equipSlot) end
PriceTooltip_GetItemLinkFirstParam = function(itemLink) return itemLink end


PriceTooltip_GetStringColor = function(red, green, blue)
	local color = ZO_ColorDef:New(red, green, blue, 1)
	return "|c" .. color:ToHex()
end


PriceTooltip_GetStringColorFromColor = function(color)
	return PriceTooltip_GetStringColor(color.Red, color.Green, color.Blue)
end


PriceTooltip_ChangeGridPrice = function(control, slot)
	if not PriceTooltip.SavedVariables.OverrideItemPrice then return end

	local data = nil
	
	if control and control.dataEntry and control.dataEntry.data and control.dataEntry.data.bagId and control.dataEntry.data.slotIndex and control.dataEntry.data.stackCount then
		mainControl = control
	elseif slot and slot.dataEntry and slot.dataEntry.data and slot.dataEntry.data.bagId and slot.dataEntry.data.slotIndex and slot.dataEntry.data.stackCount then
		mainControl = slot
	end
	
	if mainControl then
		local bagId = mainControl.dataEntry.data.bagId
		local slotIndex = mainControl.dataEntry.data.slotIndex
		local stackCount = mainControl.dataEntry.data.stackCount
		local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)

		if not itemLink then return end
		local prices = PriceTooltip_GetPrices(itemLink, true)

		if not prices then return end
				
		local sellPriceControl = mainControl:GetNamedChild("SellPrice")

		if not sellPriceControl then return end
		
		local price = nil

		if PriceTooltip.SavedVariables.OverrideBehaviour == PRICE_TOOLTIP_AVERAGE_PRICE then price = prices.scaledAveragePrice
		elseif PriceTooltip.SavedVariables.OverrideBehaviour == PRICE_TOOLTIP_MM_PRICE then price = prices.scaledMMPrice
		elseif PriceTooltip.SavedVariables.OverrideBehaviour == PRICE_TOOLTIP_TTC_PRICE then price = prices.scaledTTCPrice
		elseif PriceTooltip.SavedVariables.OverrideBehaviour == PRICE_TOOLTIP_ATT_PRICE then price = prices.scaledATTPrice
		elseif PriceTooltip.SavedVariables.OverrideBehaviour == PRICE_TOOLTIP_BEST_PRICE then price = prices.bestPrice
		elseif PriceTooltip.SavedVariables.OverrideBehaviour == PRICE_TOOLTIP_PROFIT_PRICE then price = prices.profitPrice
		end
		
		local lowPriceIndikator = ""
		if PriceTooltip.SavedVariables.LowPriceIndicatorGrid then lowPriceIndikator = PriceTooltip_GetLowPriceIndicator(price, prices.vendorPrice, prices.profitPrice) end

		if not PriceTooltip_ValidPrice(price) then price = prices.vendorPrice end

		local stackPrice = PriceTooltip_Round(price * stackCount)

		if price == prices.vendorPrice then
			sellPriceControl:SetText(lowPriceIndikator .. PriceTooltip_GetStringColor(1, 1, 1) .. PriceTooltip_NumberFormat(stackPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
		else
			sellPriceControl:SetText(lowPriceIndikator .. PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.GridPriceColor) .. PriceTooltip_NumberFormat(stackPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
		end
	end
end


PriceTooltip_GridPriceExtension = function()
	if MasterMerchant then
		local base = MasterMerchant["SwitchPrice"]
		
		MasterMerchant["SwitchPrice"] = function(control, slot)
			base(control, slot)
			PriceTooltip_ChangeGridPrice(control, slot)
		end
	else
		for _,i in pairs(PLAYER_INVENTORY.inventories) do
			local listView = i.listView
			if listView and listView.dataTypes and listView.dataTypes[1] then
				local originalCall = listView.dataTypes[1].setupCallback				
				listView.dataTypes[1].setupCallback = function(control, slot)						
					originalCall(control, slot)
					PriceTooltip_ChangeGridPrice(control, slot)
				end
			end
		end

		local originalCall = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback
		ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback = function(control, slot)
			originalCall(control, slot)
			PriceTooltip_ChangeGridPrice(control, slot)
		end
	end
end


PriceTooltip_PriceToChat = function(link, priceText, price)
	if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if not chat:HasFocus() then StartChatInput() end
		chat:InsertText(PriceTooltip_NumberFormat(price, 2)  .. " gold for " .. string.gsub(link, '|H0', '|H1'))
	end
end


PriceTooltip_AddCustomMenuItems = function(link, button)
		if not (PriceTooltip.SavedVariables.UsePriceToChat and link and button == MOUSE_BUTTON_INDEX_RIGHT) then return end

		local prices = PriceTooltip_GetPrices(link)

		local count = 1
		local entries = {}

		local stringColor = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.PriceToChatColor)

		if PriceTooltip_ValidPrice(prices.originalTTCPrice) then
			entries[count] = 
			{
				label = stringColor .. PRICE_TOOLTIP_TTC_PRICE .. " " .. PriceTooltip_NumberFormat(prices.originalTTCPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
				callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_TTC_PRICE, prices.originalTTCPrice) end,
				itemType = MENU_ADD_OPTION_LABEL,
			}
			count = count + 1
		end
		if PriceTooltip_ValidPrice(prices.originalMMPrice) then
			entries[count] = 
			{
				label = stringColor .. PRICE_TOOLTIP_MM_PRICE .. " " .. PriceTooltip_NumberFormat(prices.originalMMPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
				callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_MM_PRICE, prices.originalMMPrice) end,
				itemType = MENU_ADD_OPTION_LABEL,
			}
			count = count + 1
		end
		if PriceTooltip_ValidPrice(prices.originalATTPrice) then
			entries[count] = 
			{
				label = stringColor .. PRICE_TOOLTIP_ATT_PRICE .. " " .. PriceTooltip_NumberFormat(prices.originalATTPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
				callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_ATT_PRICE, prices.originalATTPrice) end,
				itemType = MENU_ADD_OPTION_LABEL,
			}
			count = count + 1
		end
		if PriceTooltip_ValidPrice(prices.originalAveragePrice) then
			entries[count] = 
			{
				label = stringColor .. PRICE_TOOLTIP_AVERAGE_PRICE .. " " .. PriceTooltip_NumberFormat(prices.originalAveragePrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
				callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_TRADE_PRICE, prices.originalAveragePrice) end,
				itemType = MENU_ADD_OPTION_LABEL,
			}
			count = count + 1
		end

		if count > 1 then
			AddCustomSubMenuItem(stringColor .. "PT original price to chat", entries)
			ShowMenu()
		end
end


PriceTooltip_LinkHandlerExtension = function()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		PriceTooltip_AddCustomMenuItems(link, button)
	end
end


PriceTooltip_ShowContextMenuExtension = function(inventorySlot)
	local valid = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not valid then return end
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not (bagId and slotIndex) then return end
	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink then return end
	PriceTooltip_AddCustomMenuItems(itemLink, MOUSE_BUTTON_INDEX_RIGHT)
end


PriceTooltip_Load = function(eventCode, addonName)
    if addonName ~= PriceTooltip.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	
	PriceTooltip.SavedVariables = ZO_SavedVars:NewAccountWide(PriceTooltip.SavedVariablesFileName, PriceTooltip.Version, nil, PriceTooltip.Default)

	if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
		ATT_Sales = ArkadiusTradeTools.Modules.Sales
	end

	if PriceTooltip.SavedVariables.FirstTime == false then
		PriceTooltip.SavedVariables.Init.FirstTime_1 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_1 then
		if TamrielTradeCentrePrice then PriceTooltip.SavedVariables.UseTTCPrice = true end
		if MasterMerchant then PriceTooltip.SavedVariables.UseMMPrice = true end
		if ATT_Sales then PriceTooltip.SavedVariables.UseATTPrice = true end
		PriceTooltip.SavedVariables.Init.FirstTime_1 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_2 then
		if PriceTooltip.SavedVariables.Color then
			PriceTooltip.SavedVariables.TooltipColor.Red = PriceTooltip.SavedVariables.Color.Red
			PriceTooltip.SavedVariables.TooltipColor.Green = PriceTooltip.SavedVariables.Color.Green
			PriceTooltip.SavedVariables.TooltipColor.Blue = PriceTooltip.SavedVariables.Color.Blue
			PriceTooltip.SavedVariables.GridPriceColor.Red = PriceTooltip.SavedVariables.Color.Red
			PriceTooltip.SavedVariables.GridPriceColor.Green = PriceTooltip.SavedVariables.Color.Green
			PriceTooltip.SavedVariables.GridPriceColor.Blue = PriceTooltip.SavedVariables.Color.Blue
		end

		if PriceTooltip.SavedVariables.UseVendorPrice ~= nil then PriceTooltip.SavedVariables.DisplayVendorPrice = PriceTooltip.SavedVariables.UseVendorPrice end
		if PriceTooltip.SavedVariables.ShowBestPriceOnly ~= nil then PriceTooltip.SavedVariables.DisplayBestPrice = PriceTooltip.SavedVariables.ShowBestPriceOnly end

		PriceTooltip.SavedVariables.DisplayProfitPrice = PriceTooltip.SavedVariables.UseProfitPrice
		PriceTooltip.SavedVariables.DisplayTTCPrice = PriceTooltip.SavedVariables.UseTTCPrice
		PriceTooltip.SavedVariables.DisplayMMPrice = PriceTooltip.SavedVariables.UseMMPrice
		PriceTooltip.SavedVariables.DisplayATTPrice = PriceTooltip.SavedVariables.UseATTPrice
		PriceTooltip.SavedVariables.DisplayAveragePrice = PriceTooltip.SavedVariables.UseAveragePrice

		PriceTooltip.SavedVariables.Init.FirstTime_2 = false
	end
	
	if PriceTooltip.SavedVariables.Init.FirstTime_3 then
		PriceTooltip.SavedVariables.PriceToChatColor.Red = PriceTooltip.SavedVariables.TooltipColor.Red
		PriceTooltip.SavedVariables.PriceToChatColor.Green = PriceTooltip.SavedVariables.TooltipColor.Green
		PriceTooltip.SavedVariables.PriceToChatColor.Blue = PriceTooltip.SavedVariables.TooltipColor.Blue
		PriceTooltip.SavedVariables.Init.FirstTime_3 = false
	end
	
	PriceTooltip_MENU.Init()
	
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetBagItem", GetItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetLootItem", GetLootItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetWornItem", PriceTooltip_GetWornItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetLink", PriceTooltip_GetItemLinkFirstParam)
	PriceTooltip_ToolTipExtension(PopupTooltip, "SetLink", PriceTooltip_GetItemLinkFirstParam)

	PriceTooltip_GridPriceExtension()
	PriceTooltip_LinkHandlerExtension()
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot) zo_callLater(function() PriceTooltip_ShowContextMenuExtension(inventorySlot) end, 50) end)
end


EVENT_MANAGER:RegisterForEvent("PriceTooltip_Load", EVENT_ADD_ON_LOADED, PriceTooltip_Load)