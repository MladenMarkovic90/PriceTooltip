PriceTooltip_MENU.LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")


PriceTooltip_MENU.PanelData =
{
	type = "panel",
	name = "Price Tooltip",
	displayName = "Price Tooltip",
	author = "Mladen90",
	version = PriceTooltip.StringVersion,
	registerForRefresh = true
}


PriceTooltip_MENU.OptionData = 
{
	{
		type = "header",
		name = "Format settings"
	},
	{
		type = "dropdown",
		name = "Thousand separator",
		tooltip = "Separator to split thousand values",
		width = "half",
		choices = {"'", ",", ".", "_", PRICE_TOOLTIP_SPACE},
		getFunc = function() return PriceTooltip.SavedVariables.Separator end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.Separator = newValue end
	},
	{
		type = "dropdown",
		name = "Tooltip font",
		tooltip = "Font for the price tooltip",
		width = "half",
		choices =
		{
			"ZoFontWinH5",
			"ZoFontWinH4",
			"ZoFontWinH3",
			"ZoFontWinH2",
			"ZoFontGameSmall",
			"ZoFontGame",
			"ZoFontGameBold",
		},
		getFunc = function() return PriceTooltip.SavedVariables.Font end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.Font = newValue end
	},
	{
		type = "colorpicker",
		name = "Tooltip color",
		width = "half",
		getFunc = function()
			return
			PriceTooltip.SavedVariables.TooltipColor.Red,
			PriceTooltip.SavedVariables.TooltipColor.Green,
			PriceTooltip.SavedVariables.TooltipColor.Blue
		end,
		setFunc = function(r, g, b)
			PriceTooltip.SavedVariables.TooltipColor.Red = r
			PriceTooltip.SavedVariables.TooltipColor.Green = g
			PriceTooltip.SavedVariables.TooltipColor.Blue = b
		end
    },
	-- Price settings
	{
		type = "header",
		name = "Price settings"
	},
	{
		type = "checkbox",
		name = "Round price to nearest gold",
		width = "full",
		getFunc = function() return PriceTooltip.SavedVariables.RoundPrice end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.RoundPrice = newValue end
	},
	{
		type = "checkbox",
		name = "Display vendor price tooltip",
		getFunc = function() return PriceTooltip.SavedVariables.DisplayVendorPrice end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayVendorPrice = newValue end
	},
	{
		type = "submenu",
		name = "Profit price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use profit price",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseProfitPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseProfitPrice = newValue end,
			},
			{
				type = "checkbox",
				name = "Display profit price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayProfitPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayProfitPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseProfitPrice) end
			},
			{
				type = "slider",
				name = "Scale profit price",
				tooltip = "Scales profit price by percent (%)",
				width = "full",
				min = 10,
				max = 200,
				step = 0.1,
				getFunc = function() return PriceTooltip.SavedVariables.ScaleProfitPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleProfitPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseProfitPrice) end
			}
		}
	},
	{
		type = "submenu",
		name = "TTC price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use scaled TTC price",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseTTCPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseTTCPrice = newValue end,
			},
			{
				type = "checkbox",
				name = "Display scaled TTC price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayTTCPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayTTCPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseTTCPrice) end
			},
			{
				type = "slider",
				name = "Scale TTC price",
				tooltip = "Scales TTC price by percent (%)",
				width = "full",
				min = -50,
				max = 50,
				step = 0.1,
				getFunc = function() return PriceTooltip.SavedVariables.ScaleTTCPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleTTCPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseTTCPrice) end
			}
		}
	},
	{
		type = "submenu",
		name = "MM price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use scaled MM price",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseMMPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseMMPrice = newValue end,
			},
			{
				type = "checkbox",
				name = "Display scaled MM price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayMMPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayMMPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseMMPrice) end
			},
			{
				type = "slider",
				name = "Scale MM price",
				tooltip = "Scales MM price by percent (%)",
				width = "full",
				min = -50,
				max = 50,
				step = 0.1,
				getFunc = function() return PriceTooltip.SavedVariables.ScaleMMPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleMMPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseMMPrice) end
			}
		}
	},
	{
		type = "submenu",
		name = "ATT price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use scaled ATT price",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseATTPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseATTPrice = newValue end,
			},
			{
				type = "checkbox",
				name = "Display scaled ATT price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayATTPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayATTPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
			},
			{
				type = "slider",
				name = "Scale ATT price",
				tooltip = "Scales ATT price by percent (%)",
				width = "half",
				min = -50,
				max = 50,
				step = 0.1,
				getFunc = function() return PriceTooltip.SavedVariables.ScaleATTPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleATTPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
			},
			{
				type = "slider",
				name = "ATT price days range",
				tooltip = "Calculate ATT price for this amount of days",
				width = "half",
				min = 1,
				max = 30,
				step = 1,
				getFunc = function() return PriceTooltip.SavedVariables.ATTDays end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.ATTDays = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
			}
		}
	},
	{
		type = "submenu",
		name = "Average (trade) price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use average (trade) price",
				tooltip = "Use average (trade) price from enabled scaled prices: MM, TTC, ATT",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseAveragePrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseAveragePrice = newValue end,
			},
			{
				type = "checkbox",
				name = "Display average (trade) price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayAveragePrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayAveragePrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseAveragePrice) end
			}
		}
	},
	{
		type = "submenu",
		name = "Best price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use best price",
				tooltip = "Use best price from enabled scaled prices: Profit, MM, TTC, ATT",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseBestPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseBestPrice = newValue end,
			},
			{
				type = "checkbox",
				name = "Display best price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayBestPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayBestPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseBestPrice) end
			}
		}
	},
	-- Override settings
	{
		type = "header",
		name = "Override settings"
	},
	{
		type = "checkbox",
		name = "Override grid price",
		tooltip = "Overrides the item price in grid",
		width = "half",
		getFunc = function() return PriceTooltip.SavedVariables.OverrideItemPrice end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.OverrideItemPrice = newValue end,
	},
	{
		type = "dropdown",
		name = "Override behaviour",
		tooltip = "Set the behaviour of the override grid price",
		width = "half",
		choices = {PRICE_TOOLTIP_AVERAGE_PRICE, PRICE_TOOLTIP_MM_PRICE, PRICE_TOOLTIP_TTC_PRICE, PRICE_TOOLTIP_ATT_PRICE, PRICE_TOOLTIP_BEST_PRICE, PRICE_TOOLTIP_PROFIT_PRICE},
		getFunc = function() return PriceTooltip.SavedVariables.OverrideBehaviour end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.OverrideBehaviour = newValue end,
		disabled = function() return (not PriceTooltip.SavedVariables.OverrideItemPrice) end
	},
	{
		type = "colorpicker",
		name = "Grid price color",
		width = "half",
		getFunc = function()
			return
			PriceTooltip.SavedVariables.GridPriceColor.Red,
			PriceTooltip.SavedVariables.GridPriceColor.Green,
			PriceTooltip.SavedVariables.GridPriceColor.Blue
		end,
		setFunc = function(r, g, b)
			PriceTooltip.SavedVariables.GridPriceColor.Red = r
			PriceTooltip.SavedVariables.GridPriceColor.Green = g
			PriceTooltip.SavedVariables.GridPriceColor.Blue = b
		end
    },
}


PriceTooltip_MENU.Init = function()
	PriceTooltip_MENU.LAM2:RegisterAddonPanel("PRICE_TOOLTIP_SETTINGS", PriceTooltip_MENU.PanelData)
	PriceTooltip_MENU.LAM2:RegisterOptionControls("PRICE_TOOLTIP_SETTINGS", PriceTooltip_MENU.OptionData)
end