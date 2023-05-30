-- Inventory 
local VorpInv
VorpInv = exports.vorp_inventory:vorp_inventoryApi()

-- VORP
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

CreateThread(function()
	for k,_ in pairs(Config.Canoes) do
		VorpInv.RegisterUsableItem(k, function(data)
			VorpInv.subItem(data.source, k, 1)
			TriggerClientEvent('illmat1c-canoe:client:lauchcanoe', data.source, k)
			VorpInv.CloseInv(data.source)
		end)
	end
end)

RegisterNetEvent('illmat1c-canoe:pickupcanoe', function(bool, hash, item)
	local _source = source
	if bool == 'pickup' then
		for k,v in pairs(Config.Canoes) do
			if tonumber(hash) == tonumber(v.hash) then
				VorpInv.addItem(_source, k, 1)
				VORPcore.NotifyRightTip(_source, "Picked up a "..Config.Canoes[k].name, 4000)
				break
			end
		end
	elseif bool == 'return' then
		VorpInv.addItem(_source, item, 1)
	end
end)
