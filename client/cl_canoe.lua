-- VORP
local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

function DeleteCanoe(entity)
    Citizen.InvokeNative(0xE20A909D8C4A70F8, Citizen.PointerValueIntInitialized(entity))
end

function PrepareAnim(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Wait(1)
		end
	end
end

RegisterNetEvent('illmat1c-canoe:client:lauchcanoe', function(item)
	local coords = GetEntityCoords(PlayerPedId())
	local water = Citizen.InvokeNative(0x5BA7A68A346A5A91,coords.x + Config.DistanceFromWater, coords.y + Config.DistanceFromWater, coords.z)
	local canLauch = false
	for k,_ in pairs(Config.WaterTypes) do
		if water == Config.WaterTypes[k]["waterhash"]  then
			canLauch = true
			break
		end
	end
	Wait(250)
	if canLauch then
		local model = GetHashKey(Config.Canoes[item].model)
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 4.0, 0.5 ))
		local heading = GetEntityHeading(PlayerPedId())
		RequestModel(model)
		while not HasModelLoaded(model) do
			Wait(500)
		end
		local activecanoe = CreateVehicle(model, x, y, z, heading, true, true)
		SetVehicleOnGroundProperly(activecanoe)
        Wait(200)
		SetPedIntoVehicle(PlayerPedId(), activecanoe, -1)
		SetModelAsNoLongerNeeded(activecanoe)
	else
        local yesman = 'return'
        VORPcore.NotifyRightTip(Config.Language.NeedToBeInWater,4000)
		TriggerServerEvent('illmat1c-canoe:pickupcanoe', yesman, blank, item)
	end
end)

RegisterCommand('pucanoe', function()
    if DoesEntityExist(PlayerPedId()) and not IsEntityDead(PlayerPedId()) then
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            local canoe = GetVehiclePedIsIn(PlayerPedId(), false)
            if GetPedInVehicleSeat(canoe, -1) == PlayerPedId() then
                SetEntityAsMissionEntity(canoe, true, true)
                TaskLeaveVehicle(PlayerPedId(), canoe, 256)
                local yesman = 'pickup'
                Wait(3000)
                SetEntityHeading(PlayerPedId(), GetEntityCoords(PlayerPedId())+90)
                PrepareAnim("amb_work@world_human_farmer_weeding@male_a@idle_a")
                Wait(1000)
                TaskPlayAnim(PlayerPedId(), "amb_work@world_human_farmer_weeding@male_a@idle_a", "idle_a", 3.0, 0.0, -1, 1, 0, true, 0, false, 0, false)
                Wait(3500)
                PrepareAnim("amb_work@world_human_farmer_weeding@male_a@stand_exit")
                Wait(1000)
                TaskPlayAnim(PlayerPedId(), "amb_work@world_human_farmer_weeding@male_a@stand_exit", "exit_front", 3.0, 0.0, -1, 1, 0, true, 0, false, 0, false)
                ClearPedTasksImmediately(PlayerPedId())
                local hash = GetEntityModel(canoe)
                DeleteCanoe(canoe)
                if DoesEntityExist(canoe) then
                    VORPcore.NotifyRightTip(Config.Language.UnableToPickUp,4000)
                else
                    TriggerServerEvent('illmat1c-canoe:pickupcanoe', yesman, hash)
                end
            end
        else
            VORPcore.NotifyRightTip(Config.Language.MustBeInCanoe,4000)
        end
    end
end, false)
