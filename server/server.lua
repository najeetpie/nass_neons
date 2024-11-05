installedNeons = json.decode(LoadResourceFile(GetCurrentResourceName(), "./installedNeons.json")) or {}
savedConfigs = json.decode(LoadResourceFile(GetCurrentResourceName(), "./savedConfigs.json"))

Citizen.CreateThread(function()
    Wait(500)
    if Config.neons.command then
        RegisterCommand(Config.neons.commandName, function(source)
            openNeonsMenu(source)
        end)
    end

    if Config.neons.item then
        registerUsableItem(Config.neons.itemName, function(source)
            openNeonsMenu(source)
        end)
    end

    if Config.needInstall then
        if Config.installNeon.command then
            RegisterCommand(Config.installNeon.commandName, function(source)
                installNeons(source, false)
            end)
        end
        if Config.installNeon.item then
            registerUsableItem(Config.installNeon.itemName, function(source)
                installNeons(source, true)
            end)
        end
    end
end)

RegisterNetEvent("nass_neons:getSavedConfigs")
AddEventHandler("nass_neons:getSavedConfigs", function()
    local src = source
	TriggerClientEvent("nass_neons:populateSavedConfigs", src, savedConfigs[getIdentifier(src)])
end)

RegisterNetEvent("nass_neons:savePlayerConfig")
AddEventHandler("nass_neons:savePlayerConfig", function(name, data)
    local src = source
    local ident = getIdentifier(src)
	if savedConfigs[ident] == nil then
        savedConfigs[ident] = {}
    end
    table.insert(savedConfigs[ident], {name=name, data=data})
    Wait(200)
    TriggerClientEvent("nass_neons:populateSavedConfigs", src, savedConfigs[ident])
end)

RegisterNetEvent("nass_neons:deleteSavedConfig")
AddEventHandler("nass_neons:deleteSavedConfig", function(index)
    local src = source
    local ident = getIdentifier(src)
    table.remove(savedConfigs[ident], index+1);
    Wait(200)
    TriggerClientEvent("nass_neons:populateSavedConfigs", src, savedConfigs[ident])
end)

RegisterNetEvent("nass_neons:installNeons")
AddEventHandler("nass_neons:installNeons", function(plate, item)
    local src = source

    if plate == nil or plate == "" then return end

    if installedNeons[plate] == nil then
        installedNeons[plate] = {}
    end

    installedNeons[plate] = {neonInstalled = true}
    TriggerClientEvent("nass_neons:notify", src, Config.locale["neons_succ_installed"])
    if item then
        removeItem(source, Config.installNeon.itemName, 1)
    end
end)

RegisterNetEvent("nass_neons:callback")
AddEventHandler("nass_neons:callback", function(data)
    local src = source
    TriggerClientEvent("nass_neons:serverCallback", -1, data)
end)

function installNeons(src, item)
    if Config.mechanicOnly.installNeons then
        if not isMechanic(src) then 
            TriggerClientEvent("nass_neons:notify", src, Config.locale["isnt_mech"])
            return 
        end
    end

    local ped = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        if installedNeons[plate]?.neonInstalled then
            TriggerClientEvent("nass_neons:notify", src, Config.locale["neons_succ_installed"])
        else
            TriggerClientEvent("nass_neons:installNeons", src, item)
        end
    end
end


function openNeonsMenu(src)
    local ped = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        if Config.mechanicOnly.neonMenu then 
            if not isMechanic(src) then
                TriggerClientEvent("nass_neons:notify", src, Config.locale["isnt_mech"])
                return 
            end
        end
        if Config.needInstall then
            local plate = GetVehicleNumberPlateText(vehicle)
            if installedNeons[plate]?.neonInstalled then
                TriggerClientEvent("nass_neons:openMenu", src)
            else
                TriggerClientEvent("nass_neons:notify", src, Config.locale["neons_not_installed"])
            end
        else
            TriggerClientEvent("nass_neons:openMenu", src)
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    SaveResourceFile(GetCurrentResourceName(), "installedNeons.json", json.encode(installedNeons), -1)
    SaveResourceFile(GetCurrentResourceName(), "savedConfigs.json", json.encode(savedConfigs), -1)
end)