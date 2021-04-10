function()
    local totem_slot = aura_env.slot
    if totem_slot == 0 then
        return 0, GetTime()
    end

    local _, totem_name, start_time, duration, _ = GetTotemInfo(aura_env.slot)
    return duration, start_time + duration
end
