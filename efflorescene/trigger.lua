-- Listens to event PLAYER_TOTEM_UPDATE
function(event, totem_slot)
    if totem_slot == nil then
        totem_slot = 0
    end

    aura_env.slot = totem_slot
    return true
end
