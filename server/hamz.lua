--===========================================================================--
-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING --
--===========================================================================--

if Scully.HamzCad.enable then
    RegisterNetEvent("scully:cad:hamz", function(data)
        local _source = source
        if data.type == "send911" then
            if Scully.HamzCad.callPanel then
                PerformHttpRequest(Scully.HamzCad.url .. "/actions/911notification.php?get911=" .. string.gsub(data.call, "%s", "%%20"), function(err, text, headers) 
                    Scully.Functions.DiscordLog(Scully.HamzCad.Webhook, "**ID:** " .. data.sender .. "\n**Name:** " .. GetPlayerName(data.sender) .. "\n**Action:** Sent 911 call\n**Call:** " .. data.call)
                end)
            end
        elseif data.type == "createCharacter" then
            local identifier = Scully.Functions.GetIdentifier(_source, "discord")
            if identifier then
                PerformHttpRequest(Scully.HamzCad.url .. "/api/createcharacter/?discordid=" .. identifier .. "&name=" .. data.firstname .. "%20" .. data.lastname .. "&dob=" .. data.dob .. "&gender=" .. data.gender .. "&secret=" .. Scully.HamzCad.secret, value, 'POST')
                Scully.Functions.DiscordLog(Scully.HamzCad.Webhook, "**ID:** " .. _source .. "\n**Name:** " .. GetPlayerName(_source) .. "\n**Action:** Created character\n**Name:** " .. data.firstname .. " " .. data.lastname)
            end
        elseif data.type == "editCharacter" then
            local identifier = Scully.Functions.GetIdentifier(_source, "discord")
            if identifier then
                PerformHttpRequest(Scully.HamzCad.url .. "/api/updatecharacter/?discordid=" .. identifier .. "&oldname=" .. data.firstnamePrev .. "%20" .. data.lastnamePrev .. "&newname=" .. data.firstname .. "%20" .. data.lastname .. "&dob=" .. data.dob .. "&gender=" .. data.gender .. "&secret=" .. Scully.HamzCad.secret, value, 'POST')
                Scully.Functions.DiscordLog(Scully.HamzCad.Webhook, "**ID:** " .. _source .. "\n**Name:** " .. GetPlayerName(_source) .. "\n**Action:** Edited character\n**Old Name:** " .. data.firstnamePrev .. " " .. data.lastnamePrev .. "\n**New Name:** " .. data.firstname .. " " .. data.lastname)
            end
        elseif data.type == "deleteCharacter" then
            local identifier = Scully.Functions.GetIdentifier(_source, "discord")
            if identifier then
                PerformHttpRequest(Scully.HamzCad.url .. "/api/deletecharacter/?discordid=" .. identifier .. "&name=" .. data.firstname .. "%20" .. data.lastname .. "&secret=" .. Scully.HamzCad.secret, value, 'POST')
                Scully.Functions.DiscordLog(Scully.HamzCad.Webhook, "**ID:** " .. _source .. "\n**Name:** " .. GetPlayerName(_source) .. "\n**Action:** Deleted character\n**Name:** " .. data.firstname .. " " .. data.lastname)
            end
        end
    end)

    Scully.HamzCad.GetColour = function(status)
        if status == "Valid" then
            return "~g~Valid~w~"
        elseif status == "Canceled" then
            return "~r~Canceled~w~"
        elseif status == "Expired" then
            return "~r~Expired~w~"
        elseif status == "Suspended" then
            return "~r~Suspended~w~"
        elseif status == "Invalid" then
            return "~r~Invalid~w~"
        elseif status == "Unobtained" then
            return "~w~Unobtained~w~"
        elseif status == "Unknown" then
            return "~w~Unknown~w~"
        elseif status == "Wanted" then
            return "~r~Wanted~w~"
        elseif status == "Stolen" then
            return "~r~Stolen~w~"
        elseif status == "Suspended Reg" then
            return "~r~Suspended Reg~w~"
        elseif status == "Cancelled Reg" then
            return "~r~Canceled Reg~w~"
        elseif status == "Driver Flag" then
            return "~y~Driver Flag~w~"
        elseif status == "Expired Reg" then
            return "~r~Expired Reg~w~"
        elseif status == "Insurance Flag" then
            return "~y~Insurance Flag~w~"
        elseif status == "No Insurance" then
            return "~r~No Insurance~w~"
        elseif status == "None" then
            return "~w~None~w~"
        end
    end

    Scully.Functions.CreateCallback("scully:cad:hamz:callback", function(source, cb, data)
        local search = string.gsub(data.info, "%s", "%%20")
        if data.type == "namecheck" then
            PerformHttpRequest(Scully.HamzCad.url .. "/api/namecheck?q=" .. search, function(err, text, headers)
                local result = json.decode(text)
                if result.status == "Found" then
                    Scully.Functions.ShowCharNotification(source, "~b~Name Check:", "~b~Name: ~w~" .. result.info.name .. "\n~b~DOB: ~w~" .. result.info.dob .. "\n~b~Gender: ~w~" .. result.info.gender)
                    Scully.Functions.ShowNotification(source, "~b~Address: ~b~" .. result.info.address .. "\n~b~Blood Type: ~w~" .. result.medical.bloodtype)
                    Scully.Functions.ShowNotification(source, "~b~Drivers License: " .. Scully.HamzCad.GetColour(result.permits.drivers) .. "\n~b~Boat License: " .. Scully.HamzCad.GetColour(result.permits.boating) .. "\n~b~Pilots License: " .. Scully.HamzCad.GetColour(result.permits.aviation))
                    Scully.Functions.ShowNotification(source, "~b~Firearms License: " .. Scully.HamzCad.GetColour(result.permits.weapons) .. "\n~b~Fishing License: " .. Scully.HamzCad.GetColour(result.permits.fishing) .. "\n~b~Hunting License: " .. Scully.HamzCad.GetColour(result.permits.hunting))
                    cb(true)
                else
                    Scully.Functions.ShowNotification(source, "~r~The player could not be found.")
                    cb(false)
                end
            end)
        elseif data.type == "platecheck" then
            PerformHttpRequest(Scully.HamzCad.url .. "/api/platecheck?q=" .. search, function(err, text, headers)
                local result = json.decode(text)
                if result.status == "Found" then
                    Scully.Functions.ShowNotification(source, "~b~Plate Check:\n~b~Plate: ~w~" .. result.info.plate .. "\n~b~Owner: ~w~" .. result.info.owner .. "\n~b~Model: " .. result.info.makemodel)
                    Scully.Functions.ShowNotification(source, "~b~Colour: ~w~" .. result.info.vehcolor .. "\n~b~Insurance: ~w~" .. Scully.HamzCad.GetColour(result.info.insurance) .. "\n~b~Flags: ~w~" .. Scully.HamzCad.GetColour(result.info.flags))
                    cb(true)
                else
                    Scully.Functions.ShowNotification(source, "~r~No vehicle was found with that plate.")
                    cb(false)
                end
            end)
        end
        cb(false)
    end)
end