--===========================================================================--
-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING --
--===========================================================================--
Scully.LEO = {
    GSRList = {},
    DutyPlayers = {}
}

if Scully.DutyBlips.enable then
    CreateThread(function()
        while true do
            Wait(Scully.DutyBlips.updateInterval)
            for k, v in pairs(Scully.LEO.DutyPlayers) do
                Scully.LEO.DutyPlayers[k].location = GetEntityCoords(GetPlayerPed(k))
                TriggerClientEvent("scully_leo:updateblips", -1, Scully.LEO.DutyPlayers)
            end
        end
    end)
end

RegisterCommand('panic', function(source, args, rawCommand)
	if Scully.Functions.HasPermissions(source, "isLEO") then
		local pos = GetEntityCoords(GetPlayerPed(source))
        local name = GetPlayerName(source)
		TriggerClientEvent('scully_leo:panic', -1, pos.x, pos.y, pos.z, name)
	end
end)

RegisterCommand('911', function(source, args, rawCommand)
    if args[1] then
        local pos = GetEntityCoords(GetPlayerPed(source))
		local text = rawCommand:sub(4)
        local name = GetPlayerName(source)
        TriggerClientEvent('scully_leo:911', -1, pos.x, pos.y, pos.z, name, text)
        TriggerEvent("scully:cad:hamz", {type = "send911", call = name .. " | " .. text, sender = source})
    end
end)

RegisterNetEvent("scully_leo:setdutystatus", function(onDuty)
    local src = source
    if onDuty then
        Scully.LEO.DutyPlayers[src] = {
            name = name,
            time = os.time(),
            location = GetEntityCoords(GetPlayerPed(src))
        }
        Scully.Functions.DiscordLog(Scully.Webhooks.Duty, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Status:** 10-41")
    else
        Scully.Functions.DiscordLog(Scully.Webhooks.Duty, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Status:** 10-42\n**Duration:** " .. Scully.Functions.ConvertToTime(os.time() - Scully.LEO.DutyPlayers[src].time))
        Scully.LEO.DutyPlayers[src] = nil
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
	if Scully.LEO.DutyPlayers[src] then
        Scully.Functions.DiscordLog(Scully.Webhooks.Duty, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Status:** 10-42\n**Duration:** " .. Scully.Functions.ConvertToTime(os.time() - Scully.LEO.DutyPlayers[src].time))
		Scully.LEO.DutyPlayers[src] = nil
	end
end)

RegisterNetEvent("scully_leo:shotspotterGSR", function(location, streetName)
    local src = source
    Scully.LEO.GSRList[src] = os.time()
    TriggerClientEvent("scully_leo:shotspotter", -1, location, streetName)
end)

Scully.Functions.CreateCallback("scully_leo:checkGSR", function(source, cb, target)
	if Scully.LEO.GSRList[target] then
        local gsrTime = os.time() - Scully.LEO.GSRList[target]
        if gsrTime < Scully.GSRLasts then
            cb(true)
        end
    end
	cb(false)
end)

Scully.Functions.CreateCallback("scully_leo:getpermissions", function(source, cb)
    local hasPermissions = Scully.Functions.HasPermissions(source, "isLEO")
	cb(hasPermissions)
end)

RegisterNetEvent('scully_leo:tackleplayer', function(target)
    local src = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    if distance < 10.0 then
        TriggerClientEvent("scully_leo:gettackled", target)
        Scully.Functions.DiscordLog(Scully.Webhooks.Tackle, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Target:** " .. target .. " | " .. GetPlayerName(target) .. "\n**Action:** Tackled Player")
    end
end)

RegisterNetEvent('scully_leo:cuff', function(target, playerheading, playerCoords, playerlocation, hardcuff)
    local src = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    if distance < 10.0 then
        TriggerClientEvent('scully_leo:getcuffed', target, playerheading, playerCoords, playerlocation, hardcuff)
        TriggerClientEvent('scully_leo:cuff', src)
        Scully.Functions.DiscordLog(Scully.Webhooks.Cuff, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Target:** " .. target .. " | " .. GetPlayerName(target) .. "\n**Action:** Cuffed Player")
    end
end)

RegisterNetEvent('scully_leo:uncuff', function(target, playerheading, playerCoords, playerlocation)
    local src = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    if distance < 10.0 then
        TriggerClientEvent('scully_leo:getuncuffed', target, playerheading, playerCoords, playerlocation)
        TriggerClientEvent('scully_leo:uncuff', src)
        Scully.Functions.DiscordLog(Scully.Webhooks.Cuff, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Target:** " .. target .. " | " .. GetPlayerName(target) .. "\n**Action:** Uncuffed Player")
    end
end)

RegisterNetEvent('scully_leo:putvehicle', function(target)
    local src = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    if distance < 10.0 then
        TriggerClientEvent('scully_leo:putVehicle', target)
        Scully.Functions.DiscordLog(Scully.Webhooks.Vehicle, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Target:** " .. target .. " | " .. GetPlayerName(target) .. "\n**Action:** Placed In Vehicle")
    end
end)

RegisterNetEvent('scully_leo:drag', function(target)
    local src = source
    local sourceCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    if distance < 10.0 then
        TriggerClientEvent('scully_leo:drag', target, src)
        Scully.Functions.DiscordLog(Scully.Webhooks.Drag, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Target:** " .. target .. " | " .. GetPlayerName(target) .. "\n**Action:** Dragged / Undragged Player")
    end
end)

RegisterNetEvent('scully_leo:dragstatus', function(target)
    TriggerClientEvent('scully_leo:dragstatus', target)
end)

RegisterCommand("unjail", function(source, args, rawCommand)
    local target = tonumber(args[1])
    if Scully.Functions.HasPermissions(source, "isLEO") then
        local targetName = target and GetPlayerName(target)
        if targetName then
            if target .. " | " .. targetName then
                TriggerClientEvent("scully_leo:unjail", target)
                Scully.Functions.DiscordLog(Scully.Webhooks.Jail, "**Player:** " .. source .. " | " .. GetPlayerName(source) .. "\n**Target:** " .. target .. " | " .. targetName .. "\n**Action:** Unjailed Player")
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args={"^1That player doesn't exist!"}
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            args={"^1You don't have permission to use this command!"}
        })
    end
end, false)

RegisterNetEvent("scully_leo:jail",function(target, jailtime)
    local src = source
    if Scully.Functions.HasPermissions(source, "isLEO") then
        TriggerClientEvent("scully_leo:jail", target, jailtime)
        Scully.Functions.DiscordLog(Scully.Webhooks.Jail, "**Player:** " .. src .. " | " .. GetPlayerName(src) .. "\n**Target:** " .. target .. " | " .. GetPlayerName(target) .. "\n**Action:** Jailed Player")
    else
        DropPlayer(src, "Attempted to jail player and isn't an LEO!")
    end
end)

if Scully.InteractSound then
    RegisterNetEvent('scully_leo:playsound', function(soundFile)
        TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, GetEntityCoords(GetPlayerPed(source)), 8.0, soundFile, 0.5)
    end)
end