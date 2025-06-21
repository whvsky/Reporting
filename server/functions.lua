Scully.Functions = {
    Debug = false,
    CallBacks = {},
    CreateCallback = function(name, cb)
        Scully.Functions.CallBacks[name] = cb
    end,
    TriggerCallback = function(name, source, cb, ...)
        if Scully.Functions.CallBacks[name] then
            Scully.Functions.CallBacks[name](source, cb, ...)
        end
    end,
    DiscordLog = function(webhook, message)
        local embed = {
            {
                ["color"] = "3056887",
                ["title"] = "LEO Logs",
                ["description"] = message,
                ["footer"] = {
                    ["text"] = "Created by Scully#5775"
                },
            }
        }
        PerformHttpRequest(webhook, function(err, text, headers)
            if Scully.Functions.Debug then
                print(message)
            end
        end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json'})
    end,
    HasPermissions = function(source, permission)
        if Scully.Functions.Debug then 
            return true 
        end
        return IsPlayerAceAllowed(source, permission)
    end,
    GetIdentifier = function(source, identifier)
        local foundIdentifier = nil
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            if string.match(id, identifier) then
                foundIdentifier = string.gsub(id, identifier .. ":", "")
                break
            end
        end
        return foundIdentifier
    end,
    ShowNotification = function(target, text)
        TriggerClientEvent('scully:functions:shownotification', target, text)
    end,
    ShowCharNotification = function(target, title, text)
        TriggerClientEvent('scully:functions:showcharnotification', target, title, text)
    end,
    GetIndexFromValue = function(array, value)
        for index, v in ipairs(array) do
            if v == value then
                return index
            end
        end
        return nil
    end,
    ConvertToTime = function(value)
        local hours = string.format("%02.f", math.floor(value/3600))
        local minutes = string.format("%02.f", math.floor(value/60 - (hours*60)))
        local seconds = string.format("%02.f", math.floor(value - hours*3600 - minutes *60))
        return hours .. ":" .. minutes .. ":" .. seconds
    end
}

RegisterNetEvent('scully:functions:triggercallback', function(name, ...)
    local _source = source
    Scully.Functions.TriggerCallback(name, _source, function(...)
        TriggerClientEvent('scully:functions:triggercallback', _source, name, ...)
    end, ...)
end)