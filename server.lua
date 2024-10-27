lib.callback.register('mosleys:server:SpawnJobVeh', function(source, model, coords)
    local ped = GetPlayerPed(source)
    local id, vehicle = qbx.spawnVehicle({
        model = tonumber(model) or joaat(model),
        spawnSource = coords,
        warp = false,

        props = {
            fuelLevel = 100.00,
        }

    })
    exports.qbx_vehiclekeys:GiveKeys(source, vehicle)
    return id
end)

RegisterNetEvent("mosleys:server:removeItem", function (item)
    local src = source
    exports.ox_inventory:RemoveItem(src, item, 1)
end)

RegisterServerEvent("mosleys:server:reward", function(reward)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    Player.Functions.AddMoney(Config.PaymentType, reward)
    TriggerClientEvent('ox_lib:notify', src, {
        description = "You have succesfully fixed the vehicle received $" .. reward,
    })
end)