-- Listens to event UNIT_AURA
function(event, unit)
    if event == "UNIT_AURA" then
        if unit == nil then
            -- Initialization
            for member in WA_IterateGroupMembers() do
                local _, _, _, _, duration, exp_time = WA_GetUnitBuff(member, aura_env.BUFF_ID)
                if duration and exp_time and duration > 0 and exp_time > GetTime() then
                    aura_env.buff_duration = duration
                    aura_env.buff_exp_time = exp_time
                    break
                end
            end
        else
            local _, _, _, _, duration, exp_time = WA_GetUnitBuff(unit, aura_env.BUFF_ID)
            if duration and exp_time and duration > 0 and exp_time > GetTime() then
                aura_env.buff_duration = duration
                aura_env.buff_exp_time = exp_time
            end
        end
    end
    return true
end
