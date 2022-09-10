function()
    
    if aura_env.state and aura_env.state.sourceName then
        local englishClass = select(2,UnitClass(aura_env.state.sourceName))
        if englishClass then            
            local colors = RAID_CLASS_COLORS[englishClass]
            if colors then
                return colors.r,colors.g,colors.b,1
            end            
        end
    end
    
    
end
