function()
    if aura_env.state and aura_env.state.unit then
        local region = aura_env.region
        local plate = C_NamePlate.GetNamePlateForUnit(aura_env.state.unit)
        if plate then
            region:ClearAllPoints()
            region:SetAnchor("BOTTOM", plate, "TOP")
            region:SetOffset(aura_env.config.xOffset, aura_env.config.yOffset)
            region:Show()
        else
            region:Hide()
        end
    end
end

