-- Custom globals
aura_env.SPELL_ID_BUFF = 102351
aura_env.SPELL_ID_HOT = 102352
aura_env.init_done = false
aura_env.buff_duration = 0
aura_env.buff_exp_time = GetTime()
aura_env.cooldown_duration = 0
aura_env.cooldown_exp_time = GetTime()
aura_env.active_buff_id = -1
aura_env.timer_spell_ready = nil
aura_env.timer_hot = nil

-- Returns: (spell id, unit, duration, expiration time) if new info is found and updated,
--          (-1, -1, -1, -1) otherwise
aura_env.find_buff_in_group = function()
    for unit in WA_IterateGroupMembers() do
        -- This buff can only be on one target at a time
        local spell_id, duration, exp_time = aura_env.find_buff_on_unit(unit)
        if spell_id ~= -1 then
            return spell_id, unit, duration, exp_time
        end
    end
    return -1, -1, -1, -1
end

-- Updates buff info from a player if any monitored buff is on it
-- Returns: (spell id, duration, expiration time) if new info is found and updated,
--          (-1, -1, -1) otherwise
aura_env.find_buff_on_unit = function(unit)
    for i_buff = 1, 40 do
        local ret_aura = {UnitBuff(unit, i_buff)}
        if (not ret_aura[1]) then
            break
        end

        -- Buff found
        local spell_id = ret_aura[10]
        if spell_id == aura_env.SPELL_ID_HOT or spell_id == aura_env.SPELL_ID_BUFF then
            local buff_duration = ret_aura[5]
            local buff_exp_time = ret_aura[6]
            return spell_id, buff_duration, buff_exp_time
        end
    end

    return -1, -1, -1
end
