-- Listening to events: UNIT_AURA, SPELL_UPDATE_COOLDOWN, and the custom
-- event JOEGNIS_RDHPS_SPELL_READY
function(allstates, event, unit)
    local now = GetTime()

    local function update_local_buff_info(spell_id, target, duration, exp_time)
        if spell_id ~= -1 then
            if duration > 0 and exp_time > now then
                aura_env.buff_duration = duration
                aura_env.buff_exp_time = exp_time
                aura_env.active_buff_id = spell_id

                -- Refires an event to update the WA timely
                if aura_env.timer_hot then
                    aura_env.timer_hot:Cancel()
                end
                aura_env.timer_hot = C_Timer.NewTimer(exp_time - now,
                    function()
                        WeakAuras.ScanEvents("UNIT_AURA", target)
                    end
                )
            end
        end
    end

    local function update_local_cooldown_info()
        local gcd_start, gcd_duration = GetSpellCooldown(61304)
        local gcd_exp_time = gcd_start + gcd_duration

        local cooldown_start, cooldown_duration, _, _ = GetSpellCooldown(aura_env.SPELL_ID_BUFF)
        local cooldown_exp_time = cooldown_start + cooldown_duration

        if cooldown_start > 0 and cooldown_duration > 0 and cooldown_exp_time > gcd_exp_time then
            aura_env.cooldown_duration = cooldown_duration
            aura_env.cooldown_exp_time = cooldown_start + cooldown_duration

            if not allstates[""].isSpellInCoolDown then
                allstates[""].isSpellInCoolDown = true
                allstates[""].changed = true
            end

            -- Changes the state when the spell cools down so that we can
            -- change display in conditions
            if aura_env.timer_spell_ready then
                aura_env.timer_spell_ready:Cancel()
            end
            local timer_time = aura_env.cooldown_exp_time - now
            if timer_time > 0 then
                aura_env.timer_spell_ready = C_Timer.NewTimer(
                    timer_time,
                    function()
                        -- Refires an event so that states are updated timely
                        WeakAuras.ScanEvents("JOEGNIS_RDHPS_SPELL_READY")
                    end
                )
            end
        end
    end

    if event == "UNIT_AURA" and unit == nil then
        -- Initialization
        allstates[""] = {
            show = true,
            changed = true,
            name = "Cenarion Ward",
            icon = GetSpellTexture(aura_env.SPELL_ID_BUFF),
            progressType = "timed",
            duration = 0,
            expirationTime = now,
            buffExpirationTime = now,
            hotExpirationTime = now,
            spellReadyTime = now,
            isSpellInCoolDown = false,
            activeBuffId = -1,
        }

        local spell_id, target, duration, exp_time = aura_env.find_buff_in_group()
        update_local_buff_info(spell_id, target, duration, exp_time)
        update_local_cooldown_info()
    elseif event == "UNIT_AURA" and unit ~= nil then
        -- Since we monitor a buff, we only care about allies' aura
        if UnitIsFriend("player", unit) then
            local spell_id, duration, exp_time = aura_env.find_buff_on_unit(unit)
            update_local_buff_info(spell_id, unit, duration, exp_time)
        end
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        update_local_cooldown_info()
    elseif event == aura_env.EVENT_SPELL_READY then
        allstates[""].isSpellInCoolDown = false
        allstates[""].changed = true
    end

    local has_buff = now < aura_env.buff_exp_time and aura_env.buff_duration > 0
    local has_cooldown = now < aura_env.cooldown_exp_time and aura_env.cooldown_duration > 0

    -- If buff is active, show buff timer
    if has_buff then
        allstates[""].duration = aura_env.buff_duration
        allstates[""].expirationTime = aura_env.buff_exp_time
        allstates[""].activeBuffId = aura_env.active_buff_id
        allstates[""].changed = true
    elseif has_cooldown then
        allstates[""].duration = aura_env.cooldown_duration
        allstates[""].expirationTime = aura_env.cooldown_exp_time
        allstates[""].activeBuffId = -1
        allstates[""].changed = true
    else
        allstates[""].duration = 0
        allstates[""].expirationTime = now
        allstates[""].activeBuffId = -1
    end

    return true
end
