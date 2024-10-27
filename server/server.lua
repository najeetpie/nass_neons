installedNeons = json.decode(LoadResourceFile(GetCurrentResourceName(), "./installedNeons.json")) or {}
savedConfigs = json.decode(LoadResourceFile(GetCurrentResourceName(), "./savedConfigs.json"))
framework, core = nil, nil


Citizen.CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        core = exports['es_extended']:getSharedObject()
        framework = "ESX"
    elseif GetResourceState('qb-core') == 'started' then
        core = exports['qb-core']:GetCoreObject() 
        framework = "QB"
    end
    Wait(500)
    if Config.neons.command then
        RegisterCommand(Config.neons.commandName, function(source)
            local src = source
            local ped = GetPlayerPed(src)
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= 0 then
                if Config.mechanicOnly.neonMenu then 
                    if not isMechanic(src) then return end
                end
                if Config.needInstall then
                    local plate = GetVehicleNumberPlateText(vehicle)
                    if installedNeons[plate]?.neonInstalled then
                        TriggerClientEvent("nass_neons:openMenu", src)
                    end
                else
                    TriggerClientEvent("nass_neons:openMenu", src)
                end
            end
        end)
    end

    if Config.neons.item then
        registerUsableItem(Config.neons.itemName, function(source)
            local src = source
            local ped = GetPlayerPed(src)
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= 0 then
                if Config.mechanicOnly.neonMenu then 
                    if not isMechanic(src) then return end
                end
                if Config.needInstall then
                    local plate = GetVehicleNumberPlateText(vehicle)
                    if installedNeons[plate]?.neonInstalled then
                        TriggerClientEvent("nass_neons:openMenu", src)
                    end
                else
                    TriggerClientEvent("nass_neons:openMenu", src)
                end
            end
        end)
    end

    if Config.needInstall then
        if Config.installNeon.command then
            RegisterCommand(Config.installNeon.commandName, function(source)
                local src = source
                local ped = GetPlayerPed(src)
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle ~= 0 then
                    local plate = GetVehicleNumberPlateText(vehicle)
            
                    if plate and plate ~= "" then
                        installNeons(src, plate)
                    end
                end
            end)
        end
        if Config.installNeon.item then
            registerUsableItem(Config.installNeon.itemName, function(source)
                local src = source
                local ped = GetPlayerPed(src)
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle ~= 0 then
                    local plate = GetVehicleNumberPlateText(vehicle)
            
                    if plate and plate ~= "" then
                        installNeons(src, plate)
                        removeItem(source, Config.installNeon.itemName, 1)
                    end
                end
            end)
        end
    end
end)

function getIdentifier(source)
    if framework == 'ESX' then
        local xPlayer = core.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.identifier
        end
    elseif framework == 'QB' then
        local xPlayer = core.Functions.GetPlayer(source)
        if xPlayer then
            return xPlayer.PlayerData.license
        end
    else
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            if string.find(id, "license:") then
                return id
            end
        end
    end
end

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

function installNeons(src, plate)
    if Config.mechanicOnly.installNeons then
        if not isMechanic(src) then return end
    end

    if plate == nil or plate == "" then return end

    if installedNeons[plate] == nil then
        installedNeons[plate] = {}
    end

    installedNeons[plate] = {neonInstalled = true}
end

function isMechanic(src)
    if framework == 'ESX' then
        local xPlayer = core.GetPlayerFromId(src)

        if xPlayer and xPlayer.job and xPlayer.job.name then
            for _, job in ipairs(Config.mechanicOnly.jobs) do
                if xPlayer.job.name == job then
                    return true
                end
            end
        end
    elseif framework == 'QB' then
        local xPlayer = core.Functions.GetPlayer(src)

        if xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job and xPlayer.PlayerData.job.name then
            for _, job in ipairs(Config.mechanicOnly.jobs) do
                if xPlayer.PlayerData.job.name == job then
                    return true
                end
            end
        end
    else
        --Add Mechanic Check
        return true
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    SaveResourceFile(GetCurrentResourceName(), "installedNeons.json", json.encode(installedNeons), -1)
    SaveResourceFile(GetCurrentResourceName(), "savedConfigs.json", json.encode(savedConfigs), -1)
end)

function removeItem(source, item, amount)
    if framework == 'ESX' then
        local xPlayer = core.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeInventoryItem(item, amount)
        end
    elseif framework == 'QB' then
        local xPlayer = core.Functions.GetPlayer(source)
        if xPlayer then
            xPlayer.Functions.RemoveItem(item, amount)
        end
    end
end

function registerUsableItem(item, cb)
    if framework == 'ESX' then
        core.RegisterUsableItem(item, cb)
    elseif framework == 'QB' then
        core.Functions.CreateUseableItem(item, cb)
    end
end