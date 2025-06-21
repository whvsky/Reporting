Scully.Functions = {
    CallBacks = {},
    TriggerCallback = function(name, cb, ...)
        Scully.Functions.CallBacks[name] = cb
        TriggerServerEvent('scully:functions:triggercallback', name, ...)
    end,
    ShowNotification = function(text)
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(true, true)
    end,
    ShowCharNotification = function(title, text)
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandThefeedPostMessagetext("CHAR_DEFAULT", "CHAR_DEFAULT", true, 4, title)
        EndTextCommandThefeedPostTicker(false, true)
    end,
    ShowHelpNotification = function(text)
        BeginTextCommandDisplayHelp('ScullyHelpNotification')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayHelp(0, 0, 1, -1)
    end,
    MiddleNotification = function(text)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry('STRING')
        AddTextComponentString(text)
        DrawText(0.5, 0.8)
    end,
    GetNearestVehicle = function()
        local pos = GetEntityCoords(PlayerPedId())
        local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 5.0, 5.0, 0.0)
        local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
        local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
        return vehicleHandle
    end,
    GetPlayers = function()
        local players = {}
        for _, player in ipairs(GetActivePlayers()) do
            if NetworkIsPlayerActive(player) then
                table.insert(players, player)
            end
        end
        return players
    end,
    GetClosestPlayer = function()
        local players = Scully.Functions.GetPlayers()
        local closestDistance = -1
        local closestPlayer = -1
        local ply = PlayerPedId()
        local plyCoords = GetEntityCoords(ply, 0)
        for index,value in ipairs(players) do
            local target = GetPlayerPed(value)
            if(target ~= ply) then
                local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
                if(closestDistance == -1 or closestDistance > distance) then
                    closestPlayer = value
                    closestDistance = distance
                end
            end
        end
        return closestPlayer, closestDistance
    end,
    Keyboard = function(textEntry, inputText, maxLength)
        AddTextEntry('FMMC_KEY_TIP1', textEntry)
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", inputText, "", "", "", maxLength)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(0)
        end
        if UpdateOnscreenKeyboard() ~= 2 then
            local result = GetOnscreenKeyboardResult()
            Citizen.Wait(500)
            return result
        else
            Citizen.Wait(500)
            return nil
        end
    end,
    DrawText3D = function(location, text)
        local onScreen, _x, _y = World3dToScreen2d(location.x, location.y, location.z)
        local p = GetGameplayCamCoords()
        local distance = #(vector3(p.x, p.y, p.z) - location)
        local scale = (1 / distance) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        local scale = scale * fov
        if onScreen then
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 215)
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x,_y)
            local factor = (string.len(text)) / 370
            DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
        end
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
    if Scully.Functions.CallBacks[name] then
        Scully.Functions.CallBacks[name](...)
        Scully.Functions.CallBacks[name] = nil
    end
end)

RegisterNetEvent('scully:functions:shownotification', function(text)
    Scully.Functions.ShowNotification(text)
end)

RegisterNetEvent('scully:functions:showcharnotification', function(title, text)
    Scully.Functions.ShowCharNotification(title, text)
end)