framework, core = nil, nil

Citizen.CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        core = exports['es_extended']:getSharedObject()
        framework = "ESX"
    elseif GetResourceState('qb-core') == 'started' then
        core = exports['qb-core']:GetCoreObject() 
        framework = "QB"
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
        return GetPlayerIdentifierByType(source, 'license')
    end
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
        --Add mechanic check for your own server if you want it
        return true
    end
end

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