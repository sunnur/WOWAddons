local addonName,addon = ...

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then 
    _G.error("Load Lib Err")
    return
end

local plugin = ldb:NewDataObject(addonName, {type = "data source", icon = "Interface\\AddOns\\RubbishTerminator\\Media\\Icons\\icon"})

function plugin:OnClick(button)
    if button == "LeftButton" then
        if IsShiftKeyDown() then
            addon:print("shift")
        elseif IsAltKeyDown() then
            addon:print("alt")
		elseif IconConfigFrame and IconConfigFrame:IsShown() then
			IconConfigFrame:Hide()
		else
			IconConfigFrame:Show()
		end
    elseif button == "RightButton" then
        addon:print("right")
    end
end

local frame = CreateFrame("Frame")

frame:SetScript("OnEvent", 
    function()
        local icon = LibStub("LibDBIcon-1.0", true)
        if not icon then
            _G.error("Load icon Err")
            return
        end
        if not RTR_DB then RTR_DB = {} end
        icon:Register(addonName, plugin, RTR_DB)
    end)

frame:RegisterEvent("PLAYER_LOGIN")

