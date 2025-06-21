--===========================================================================--
-- DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING --
--===========================================================================--
Scully.LEO = {
	JailTime = GetResourceKvpInt('scully_leo_jail') or 0,
	isLEO = false,
	onDuty = false,
	isCuffed = false,
	isHardCuffed = false,
	isDragged = false,
	draggingPlayer = false,
	DutyBlips = {}
}

Scully.Menus = {
	ProcessMenus = false,
    MenuPool = NativeUI.CreatePool(),
    LEOMenu = NativeUI.CreateMenu("LEO Menu", "")
}

RegisterCommand("leomenu", function()
    if Scully.LEO.onDuty then
        Scully.Menus.LEOMenu:Visible(true)
    end
end)

RegisterKeyMapping("leomenu", "LEO Menu", "keyboard", Scully.MenuKeybind)

CreateThread(function()
	Scully.Functions.TriggerCallback("scully_leo:getpermissions", function(isLEO)
		Scully.LEO.isLEO = isLEO
	end)
    Scully.Menus.MenuPool:Add(Scully.Menus.LEOMenu)
    Scully.Menus.SetLEOOptions()
    Scully.Menus.MenuPool:RefreshIndex()
	while true do
        Wait(0)
        if Scully.Menus.ProcessMenus then
            Scully.Menus.MenuPool:ProcessMenus()
        else
            Wait(100)
        end
    end
end)

CreateThread(function()
	for k, v in ipairs(Scully.DutyLocations) do
		if v.blip.enable then
			local zoneblip = AddBlipForRadius(v.location, 600.0)
			SetBlipSprite(zoneblip, 1)
			SetBlipColour(zoneblip, v.blip.colour)
			SetBlipAlpha(zoneblip, 75)

			local blip = AddBlipForCoord(v.location)
			SetBlipSprite(blip, v.blip.id)
			SetBlipScale(blip, 0.8)
			SetBlipColour(blip, v.blip.colour)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.blip.title)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

if Scully.EnableDutyLocations then
	CreateThread(function()
		while true do
			Wait(0)
			local letSleep = true
			local playerPed = PlayerPedId()
			for k, v in ipairs(Scully.DutyLocations) do
				local playerPos = GetEntityCoords(playerPed)
				local distance = #(playerPos - v.location)
				if distance < 3.0 and Scully.LEO.isLEO then
					letSleep = false
					if Scully.LEO.onDuty then
						Scully.Functions.DrawText3D(v.location, "~w~Press ~g~E ~w~to go ~r~off duty~w~!")
					else
						Scully.Functions.DrawText3D(v.location, "~w~Press ~g~E ~w~to go ~g~on duty~w~!")
					end
					if IsControlJustPressed(0, 38) then
						PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						if Scully.LEO.onDuty then
							Scully.LEO.onDuty = false
							if Scully.DutyLoadout then
								RemoveAllPedWeapons(playerPed)
							end
						else
							Scully.LEO.onDuty = true
							if Scully.DutyLoadout then
								for k, v in ipairs(Scully.DutyWeapons) do
									GiveWeaponToPed(playerPed, v.weapon, v.ammo, false)
									for index, component in ipairs(v.components) do
										GiveWeaponComponentToPed(playerPed, v.weapon, component)
									end
								end
							end
						end
						TriggerServerEvent("scully_leo:setdutystatus", Scully.LEO.onDuty)
					end
				end
			end
			if letSleep then
				Wait(500)
			end
		end
	end)
else
	RegisterCommand(Scully.DutyCommand, function()
		local playerPed = PlayerPedId()
		if Scully.LEO.isLEO then
			Scully.LEO.onDuty = not Scully.LEO.onDuty
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			Scully.Functions.ShowNotification("~b~You toggled your duty status!")
			TriggerServerEvent("scully_leo:setdutystatus", Scully.LEO.onDuty)
			if Scully.DutyLoadout then
				if Scully.LEO.onDuty then
					for k, v in ipairs(Scully.DutyWeapons) do
						GiveWeaponToPed(playerPed, v.weapon, v.ammo, false)
						for index, component in ipairs(v.components) do
							GiveWeaponComponentToPed(playerPed, v.weapon, component)
						end
					end
				else
					RemoveAllPedWeapons(playerPed)
				end
			end
		end
	end)
end

Scully.Menus.SetLEOOptions = function()
	local namecheck = NativeUI.CreateItem("Name Check", "Run a name check.")
	local platecheck = NativeUI.CreateItem("Plate Check", "Run a plate check.")
	if Scully.HamzCadFeatures then
		local information = Scully.Menus.MenuPool:AddSubMenu(Scully.Menus.LEOMenu, "Check Information")
		Scully.Menus.LEOMenu.Items[1]:RightLabel('>>>')
		information:AddItem(namecheck)
		information:AddItem(platecheck)
		information.OnItemSelect = function(sender, item, index)
			if item == namecheck then
				local nameEntry = Scully.Functions.Keyboard("What name would you like to check?", "", 25)
				if nameEntry then
					Scully.Functions.TriggerCallback("scully:cad:hamz:callback", function(success) end, {type = "namecheck", info = nameEntry})
				end
			elseif item == platecheck then
				local plateEntry = Scully.Functions.Keyboard("What plate would you like to check?", "", 10)
				if plateEntry then
					Scully.Functions.TriggerCallback("scully:cad:hamz:callback", function(success) end, {type = "platecheck", info = plateEntry})
				end
			end
		end
	end
    local jail = NativeUI.CreateItem("Jail", "Jail the nearest player.")
	local gsr = NativeUI.CreateItem("GSR Test", "GSR test the nearest player.")
    local handcuff = NativeUI.CreateListItem("Cuff", {"Soft Cuff", "Hard Cuff"}, 1, "Cuff the nearest player.")
    local uncuff = NativeUI.CreateItem("Uncuff", "Uncuff the nearest player.")
    local drag = NativeUI.CreateItem("Drag", "Drag the nearest player.")
    local piov = NativeUI.CreateItem("Place In/Out Of Vehicle", "Place the nearest player inside/out of the nearest vehicle.")
    Scully.Menus.LEOMenu:AddItem(jail)
	if Scully.EnableShotSpotterAndGSR then
		Scully.Menus.LEOMenu:AddItem(gsr)
	end
    Scully.Menus.LEOMenu:AddItem(handcuff)
    Scully.Menus.LEOMenu:AddItem(uncuff)
    Scully.Menus.LEOMenu:AddItem(drag)
    Scully.Menus.LEOMenu:AddItem(piov)
	Scully.Menus.LEOMenu.OnListChange = function(sender, item, index)
        if item == handcuff then
            handcuff:IndexToItem(index)
        end
    end
    Scully.Menus.LEOMenu.OnItemSelect = function(sender, item, index)
        local playerPed = PlayerPedId()
        local closestPlayer, closestDistance = Scully.Functions.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance >= 3.0 then
			if item ~= Scully.Menus.LEOMenu.Items[1] then
				Scully.Functions.ShowNotification("~r~No players nearby!")
			end
        elseif item == jail then
            local keyboard = Scully.Functions.Keyboard("How long should the player be jailed for?", "", 3)
			if not keyboard then return end
			if not tonumber(keyboard) then return end
            TriggerServerEvent("scully_leo:jail", GetPlayerServerId(closestPlayer), tonumber(keyboard))
		elseif item == gsr then
			Scully.Functions.TriggerCallback("scully_leo:checkGSR", function(isPositive)
                if isPositive then
					Scully.Functions.ShowNotification("~w~Subject came back ~g~positive ~w~for GSR!")
				else
					Scully.Functions.ShowNotification("~w~Subject came back ~r~negative ~w~for GSR!")
				end
			end, GetPlayerServerId(closestPlayer))
        elseif item == revive then
            TriggerServerEvent("scully:death:revive", GetPlayerServerId(closestPlayer))
        elseif item == handcuff then
			local isHardcuff = false
			if handcuff:IndexToItem(handcuff:Index()) == "Hard Cuff" then
				isHardcuff = true
			end
            TriggerServerEvent('scully_leo:cuff', GetPlayerServerId(closestPlayer), GetEntityHeading(playerPed), GetEntityCoords(playerPed), GetEntityForwardVector(playerPed), isHardcuff)
        elseif item == uncuff then
            TriggerServerEvent('scully_leo:uncuff', GetPlayerServerId(closestPlayer), GetEntityHeading(playerPed), GetEntityCoords(playerPed), GetEntityForwardVector(playerPed))
        elseif item == drag then
            TriggerServerEvent('scully_leo:drag', GetPlayerServerId(closestPlayer))
        elseif item == piov then
            TriggerServerEvent('scully_leo:putvehicle', GetPlayerServerId(closestPlayer))
        end
    end
end

if Scully.TackleSystem.enable then
	RegisterCommand("tackle", function()
		if Scully.LEO.onDuty then
			local playerPed = PlayerPedId()
			if IsPedSprinting(playerPed) or IsPedRunning(playerPed) then
				local closestPlayer, closestDistance = Scully.Functions.GetClosestPlayer()
				if closestDistance ~= -1 and closestDistance < 1.6 then
					if not IsPedInAnyVehicle(playerPed) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
						TriggerServerEvent("scully_leo:tackleplayer", GetPlayerServerId(closestPlayer))
						RequestAnimDict("swimming@first_person@diving")
						while not HasAnimDictLoaded("swimming@first_person@diving") do
							Wait(0)
						end
						TaskPlayAnim(playerPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop" ,3.0, 3.0, -1, 49, 0, false, false, false)
						Wait(250)
						ClearPedTasks(playerPed)
						SetPedToRagdoll(playerPed, 150, 150, 0, 0, 0, 0)
						RemoveAnimDict("swimming@first_person@diving")
					end
				end
			end
		end
	end)

	RegisterKeyMapping("tackle", "Tackle (LEO)", "keyboard", Scully.TackleSystem.keybind)

	RegisterNetEvent("scully_leo:gettackled", function()
		SetPedToRagdoll(PlayerPedId(), 7000, 7000, 0, 0, 0, 0)
	end)
end

RegisterNetEvent("scully_leo:jail", function(jailTime)
    local playerPed = PlayerPedId()
    Scully.LEO.JailTime = jailTime
    RemoveAllPedWeapons(playerPed)
	DoScreenFadeOut(100)
    while not IsScreenFadedOut() do
	    Wait(0)
	end
	if Scully.EnablePrisonScene then
		while not HasModelLoaded(`pbus`) do
			RequestModel(`pbus`)
			Wait(0)
		end
		while not HasModelLoaded(`s_m_m_prisguard_01`) do
			RequestModel(`s_m_m_prisguard_01`)
			Wait(0)
		end
		SetFollowVehicleCamViewMode(4)
		SetFollowPedCamViewMode(4)
		local prisonbus = CreateVehicle(`pbus`, 2040.44, 2692.85, 47.20, 126.94, false, true)
		local prisonguard = CreatePed(4, `s_m_m_prisguard_01`, 2040.44, 2692.85, 47.20, 126.94, false, true)
		SetVehicleOnGroundProperly(prisonbus)
		TaskWarpPedIntoVehicle(prisonguard, prisonbus, -1)
		Wait(200)
		TaskWarpPedIntoVehicle(PlayerPedId(), prisonbus, 3)
		TaskVehicleDriveToCoord(prisonguard, prisonbus, 1854.36, 2607.50, 44.67, 8.0, 1, prisonbus, 786603, 1.0, true)
		Wait(2000)
		DoScreenFadeIn(250)
		Wait(25500)
		TaskVehicleDriveToCoord(prisonguard, prisonbus, 1832.28, 2608.11, 44.59, 5.0, 1, prisonbus, 786603, 1.0, true)
		Wait(3000)
		DoScreenFadeOut(100)
		while not IsScreenFadedOut() do
			Wait(0)
		end
		while DoesEntityExist(prisonguard) do
			Wait(0)
			DeleteEntity(prisonguard)
		end
		while DoesEntityExist(prisonbus) do
			Wait(0)
			DeleteEntity(prisonbus)
		end
		Wait(2000)
		SetFollowVehicleCamViewMode(1)
		SetFollowPedCamViewMode(1)
	end
    RequestCollisionAtCoord(vector3(1691.62, 2564.76, 45.56))
    while not HasCollisionLoadedAroundEntity(playerPed) do
        Wait(0)
    end
    SetEntityCoords(playerPed, 1691.62, 2564.76, 45.56)
	DoScreenFadeIn(250)
    Scully.Functions.ShowNotification("~r~You have been sent to prison!")
end)

RegisterNetEvent("scully_leo:unjail", function(skipCheck)
	if (Scully.LEO.JailTime <= 0) and not skipCheck then return end

	local playerPed = PlayerPedId()
	Scully.LEO.JailTime = 0
	SetResourceKvpInt("scully_leo_jail", Scully.LEO.JailTime)
	if not Scully.EnablePrisonScene then
		SetEntityCoords(playerPed, 1849.07, 2608.40, 45.59)
	else
		SetEntityCoords(playerPed, 1809.16, 2608.10, 45.59)
		local prisoncam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 1855.24, 2608.81, 48.67, 300.00, 0.00, 0.00, 92.00, false, 0)
		SetCamActive(prisoncam, true)
		RenderScriptCams(true, false, 1, true, true)
		PointCamAtCoord(prisoncam, 1809.16, 2608.10, 45.59)
		TaskGoStraightToCoord(playerPed, 1849.07, 2608.40, 45.59, 1.0, 100000, 270.49, 2.0)
		Wait(20000)
		RenderScriptCams(false, true, 500, true, true)
		Wait(500)
		SetCamActive(prisoncam, false)
		DestroyCam(prisoncam, true)
	end
	Scully.Functions.ShowNotification("~g~You have been released, don't be getting into anymore trouble out there!")
end)

CreateThread(function()
	while true do
		Wait(60000)
		if Scully.LEO.JailTime > 0 then
			Scully.LEO.JailTime = Scully.LEO.JailTime - 1
			SetResourceKvpInt("scully_leo_jail", Scully.LEO.JailTime)
            local playerPed = PlayerPedId()
			local pos = GetEntityCoords(playerPed)
			if #(pos - vector3(1690.62, 2592.66, 45.70)) > 100.0 then
				SetEntityCoords(playerPed, 1691.62, 2564.76, 45.56)
				Scully.Functions.ShowNotification("~r~You have been sent back to jail for ~y~" .. Scully.LEO.JailTime .. " ~r~minutes, don't try to escape!")
			end
			if Scully.LEO.JailTime == 0 then
                TriggerEvent("scully_leo:unjail", true)
			end
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		if Scully.LEO.JailTime > 0 then
            Scully.Functions.MiddleNotification("\n~b~Time Left: ~w~" .. Scully.LEO.JailTime .. " minute(s)")
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('scully_leo:cuff', function()
    local playerPed = PlayerPedId()
	Wait(250)
	RequestAnimDict('mp_arrest_paired')
	while not HasAnimDictLoaded('mp_arrest_paired') do
		Wait(0)
	end
	TriggerServerEvent("scully_leo:playsound", "cuff")
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
	Wait(3000)
	RemoveAnimDict('mp_arrest_paired')
end)

RegisterNetEvent('scully_leo:getcuffed', function(playerheading, playercoords, playerlocation, hardcuff)
	local playerPed = PlayerPedId()
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(playerPed, x, y, z - 1)
	SetEntityHeading(playerPed, playerheading)
	SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
	Wait(250)
	RequestAnimDict('mp_arrest_paired')
	while not HasAnimDictLoaded('mp_arrest_paired') do
		Wait(0)
	end
	TriggerServerEvent("scully_leo:playsound", "cuff")
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0)
	Wait(3760)
	Scully.LEO.isCuffed = true
	Scully.LEO.isHardCuffed = hardcuff
	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Wait(0)
	end
	TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
	SetEnableHandcuffs(playerPed, true)
	DisablePlayerFiring(playerPed, true)
	SetPedCanPlayGestureAnims(playerPed, false)
	SetPedPathCanUseLadders(playerPed, false)
	Wait(3000)
	RemoveAnimDict('mp_arrest_paired')
	RemoveAnimDict('mp_arresting')
end)

RegisterNetEvent('scully_leo:uncuff', function()
    local playerPed = PlayerPedId()
	Wait(250)
	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Wait(0)
	end
	TaskPlayAnim(playerPed, 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Wait(1200)
	TriggerServerEvent("scully_leo:playsound", "uncuff")
	Wait(4300)
	ClearPedTasks(playerPed)
	RemoveAnimDict('mp_arresting')
end)

RegisterNetEvent('scully_leo:getuncuffed', function(playerheading, playercoords, playerlocation)
    local playerPed = PlayerPedId()
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(playerPed, x, y, z - 1)
	SetEntityHeading(playerPed, playerheading)
	Wait(250)
	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Wait(0)
	end
	TaskPlayAnim(playerPed, 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Wait(1200)
	TriggerServerEvent("scully_leo:playsound", "uncuff")
	Wait(4300)
	Scully.LEO.isCuffed = false
	Scully.LEO.isHardCuffed = false
	ClearPedSecondaryTask(playerPed)
	SetEnableHandcuffs(playerPed, false)
	DisablePlayerFiring(playerPed, false)
	SetPedCanPlayGestureAnims(playerPed, true)
	SetPedPathCanUseLadders(playerPed, true)
	ClearPedTasks(playerPed)
	RemoveAnimDict('mp_arresting')
end)

local dragCop = 0

RegisterNetEvent('scully_leo:drag', function(target)
	Scully.LEO.isDragged = not Scully.LEO.isDragged
	dragCop = target
end)

RegisterNetEvent('scully_leo:dragstatus', function()
	local playerPed = PlayerPedId()
    if Scully.LEO.draggingPlayer then
	    Scully.LEO.draggingPlayer = false
		Wait(100)
		ClearPedTasks(playerPed)
	else
		RequestAnimDict('switch@trevor@escorted_out')
		while not HasAnimDictLoaded('switch@trevor@escorted_out') do
			Wait(0)
		end
		TaskPlayAnim(playerPed, 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
		Scully.LEO.draggingPlayer = true
		CreateThread(function()
			while Scully.LEO.draggingPlayer do
				Wait(0)
				if not IsEntityPlayingAnim(playerPed, 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 3) then
					TaskPlayAnim(playerPed, 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				end
			end
		end)
		Wait(100)
		RemoveAnimDict('switch@trevor@escorted_out')
	end
end)

RegisterNetEvent('scully_leo:putVehicle', function()
	local playerPed = PlayerPedId()
	local closestVehicle = Scully.Functions.GetNearestVehicle()
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	if IsPedSittingInAnyVehicle(playerPed) then
		TaskLeaveVehicle(playerPed, vehicle, 64)
	else
	    if DoesEntityExist(closestVehicle) then
		    if IsVehicleSeatFree(closestVehicle, 1) then
			    TaskWarpPedIntoVehicle(playerPed, closestVehicle, 1)
				Scully.LEO.isDragged = false
		    elseif IsVehicleSeatFree(closestVehicle, 2) then
			    TaskWarpPedIntoVehicle(playerPed, closestVehicle, 2)
				Scully.LEO.isDragged = false
		    end
        end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		local playerPed = PlayerPedId()
		if Scully.LEO.isCuffed and not IsEntityDead(playerPed) then
		    DisableAllControlActions(0)
			EnableControlAction(0, 1)
			EnableControlAction(0, 2)
			if not Scully.LEO.isHardCuffed then
				EnableControlAction(0, 32)
				EnableControlAction(0, 34)
				EnableControlAction(0, 31)
				EnableControlAction(0, 30)
			end
			EnableControlAction(0, 38)
            EnableControlAction(0, 47)
			EnableControlAction(0, 245)
			EnableControlAction(0, 249)
			if not IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) then
			    RequestAnimDict('mp_arresting')
	            while not HasAnimDictLoaded('mp_arresting') do
		            Wait(0)
	            end
				TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				Wait(100)
				RemoveAnimDict('mp_arresting')
			end
		else
			Wait(500)
		end
	end
end)

local wasDragged = false

CreateThread(function()
	while true do
		Wait(0)
		local letSleep = true
		if Scully.LEO.isDragged then
			letSleep = false
			local playerPed = PlayerPedId()
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragCop))
			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) then
				if not wasDragged then
					AttachEntityToEntity(playerPed, targetPed, 11816, -0.06, 0.65, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					TriggerServerEvent('scully_leo:dragstatus', dragCop)
					wasDragged = true
				else
					if not IsPedOnFoot(playerPed) then
						wasDragged = false
						Scully.LEO.isDragged = false
						DetachEntity(playerPed, true, false)
						TriggerServerEvent('scully_leo:dragstatus', dragCop)
						ClearPedTasks(playerPed)
					else
						Wait(500)
					end
				end
			else
				wasDragged = false
				Scully.LEO.isDragged = false
				DetachEntity(playerPed, true, false)
				TriggerServerEvent('scully_leo:dragstatus', dragCop)
				ClearPedTasks(playerPed)
			end
		elseif wasDragged then
			letSleep = false
			wasDragged = false
			DetachEntity(PlayerPedId(), true, false)
			TriggerServerEvent('scully_leo:dragstatus', dragCop)
			ClearPedTasks(PlayerPedId())
		end
		if letSleep then
			Wait(1000)
		end
	end
end)

Call = {
    activeCall = false,
    steetName = "",
    location = vector3(0.0, 0.0, 0.0)
}

RegisterNetEvent('scully_leo:911', function(x, y, z, callerName, callerCall)
	if Scully.LEO.onDuty then
		TriggerEvent("chat:addMessage", {
            args={"^5911:", callerName .. " | ^7" .. callerCall}
        })
		Call.location = vector3(x, y, z)
		local streetHash = GetStreetNameAtCoord(x, y, z)
		local streetName = GetStreetNameFromHashKey(streetHash)
		if streetName then
			Call.streetName = streetName
		else
			Call.streetName = "Unknown"
		end
		Call.activeCall = true
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		if Call.activeCall then
			Scully.Functions.MiddleNotification("~b~911 Call\nLocation: ~w~" .. Call.streetName .. "\n~w~~b~ENTER: ~w~Accept\n~b~BACKSPACE: ~w~Decline")
            if IsControlJustPressed(0, 191) then
				SetNewWaypoint(Call.location.x, Call.location.y)
				PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				Call.activeCall = false
            elseif IsControlJustPressed(0, 194) then
                PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				Call.activeCall = false
            end
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('scully_leo:panic', function(x, y, z, leoName)
    local blip = nil
    if Scully.LEO.onDuty then
		TriggerEvent("chat:addMessage", {
            args={"^110-99:", leoName .. " | ^7A panic button has been pressed!"}
        })
		PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        if not DoesBlipExist(blip) then
            blip = AddBlipForCoord(vector3(x, y, z))
            SetBlipSprite(blip, 161)
            SetBlipScale(blip, 2.0)
            SetBlipColour(blip, 1)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Panic Button")
			EndTextCommandSetBlipName(blip)

            PulseBlip(blip)
            Wait(90000)
            RemoveBlip(blip)
        end
    end
end)

if Scully.EnableShotSpotterAndGSR then
	CreateThread(function()
		while true do
			Wait(0)
			local letSleep = true
			local playerPed = PlayerPedId()
			if IsPedArmed(playerPed, 4) then
				local shouldAlert = not IsPedCurrentWeaponSilenced(playerPed)
				local currentWeapon = GetSelectedPedWeapon(playerPed)
				for k, v in pairs(Scully.IgnoreWeapons) do
					if currentWeapon == v then
						shouldAlert = false
						break
					end
				end
				if shouldAlert and not Scully.LEO.onDuty then
					letSleep = false
					if IsPedShooting(playerPed) then
						local playerPos = GetEntityCoords(playerPed)
						local streetHash = GetStreetNameAtCoord(playerPos.x, playerPos.y, playerPos.z)
						local streetName = GetStreetNameFromHashKey(streetHash)
						if streetName then
							TriggerServerEvent("scully_leo:shotspotterGSR", playerPos, streetName)
							Wait(30000)
						end
					end
				end
			end
			if letSleep then
				Wait(500)
			end
		end
	end)
end

RegisterNetEvent('scully_leo:shotspotter', function(location, streetName)
    local blip = nil
    if Scully.LEO.onDuty then
		TriggerEvent("chat:addMessage", {
            args={"^110-13:", "^7Shots fired on " ..streetName}
        })
		PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        if not DoesBlipExist(blip) then
            blip = AddBlipForCoord(location)
            SetBlipSprite(blip, 161)
            SetBlipScale(blip, 2.0)
            SetBlipColour(blip, 21)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Shots Fired")
			EndTextCommandSetBlipName(blip)

            PulseBlip(blip)
            Wait(60000)
            RemoveBlip(blip)
        end
    end
end)

RegisterNetEvent("scully_leo:updateblips", function(dutyBlips)
    for k, v in ipairs(Scully.LEO.DutyBlips) do
        if DoesBlipExist(v) then
            RemoveBlip(v)
			table.remove(Scully.LEO.DutyBlips, k)
        end
    end
    local myId = GetPlayerServerId(PlayerId())
	for k, v in pairs(dutyBlips) do
		if k ~= myId then
			if v ~= nil then
                if Scully.LEO.onDuty then
                    local blip = AddBlipForCoord(v.location)
                    SetBlipSprite(blip, 1)
                    SetBlipColour(blip, 57)
                    SetBlipAsShortRange(blip, true)
                    SetBlipDisplay(blip, 4)
                    SetBlipShowCone(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(v.name)
                    EndTextCommandSetBlipName(blip)
                    table.insert(Scully.LEO.DutyBlips, blip)
                end
			end
		end
	end
end)

if Scully.EnableDisableDispatch then
    CreateThread(function()
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)
        SetScenarioTypeEnabled("WORLD_HUMAN_COP_IDLES", false)
        SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_BIKE", false)
        SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_CAR", false)
        SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_NEXT_TO_CAR", false)
        SetScenarioTypeEnabled("CODE_HUMAN_POLICE_CROWD_CONTROL", false)
        SetScenarioTypeEnabled("CODE_HUMAN_POLICE_INVESTIGATE", false)
        SetScenarioTypeEnabled("WORLD_VEHICLE_AMBULANCE", false)
        SetScenarioTypeEnabled("WORLD_VEHICLE_FIRE_TRUCK", false)
        for dispatchService=1, 25 do
            EnableDispatchService(dispatchService, false)
            Wait(1)
        end
    end)
end