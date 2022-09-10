function()
    local region = aura_env.region
    if aura_env.state and aura_env.state.unit then
        local plate = C_NamePlate.GetNamePlateForUnit(aura_env.state.unit)
        if plate and aura_env.state.playerName and not aura_env.state.isHide then
            region:ClearAllPoints()
            region:SetAnchor("BOTTOM", plate, "TOP")
            region:SetOffset(aura_env.config.xOffset, aura_env.config.yOffset)
        else
            region:SetOffset(1000, 1000)
        end
    end
end

