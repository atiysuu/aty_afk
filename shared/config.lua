Config = {
    AfkTimer = 1, -- Minutes to be considered AFK

    Notify = function(title, message, type, src, length)
        local length = length or 5000

        if src then
            TriggerClientEvent("QBCore:Notify", src, message, type, length)
        else
            TriggerEvent("QBCore:Notify", message, type, length)
        end
    end
}