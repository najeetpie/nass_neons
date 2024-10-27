local vehicle = 0
local neonData, prevVehData = {}, {}
local rainbowEnabled, rainbowEnabledHeadlights, savedNeons, savedHeadlights = false, false, nil, nil
local neonAnimation, headlightAnimation
local indexTable = {
    ["left"] = 0,
    ["right"] = 1,
    ["front"] = 2,
    ["back"] = 3,
}

RegisterNetEvent("nass_neons:openMenu")
AddEventHandler("nass_neons:openMenu", function()
    local ped = PlayerPedId()
    vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
        if Config.allowSavedConfigs then
            TriggerServerEvent("nass_neons:getSavedConfigs")
        end
        neonData = {
            neons = {
                left = IsVehicleNeonLightEnabled(vehicle, 0),
                right = IsVehicleNeonLightEnabled(vehicle, 1),
                front = IsVehicleNeonLightEnabled(vehicle, 2),
                back = IsVehicleNeonLightEnabled(vehicle, 3),
            }
        }
        SendNUIMessage({
            event = "openMenu",
        }) 
        SetNuiFocus(true, true)
    end
end)

RegisterNetEvent("nass_neons:populateSavedConfigs")
AddEventHandler("nass_neons:populateSavedConfigs", function(presets)
	SendNUIMessage({
        event = "populatePresets",
        presets = presets,
    }) 
end)

RegisterNUICallback('closeMenu', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('getVehicleData', function(data, cb)
    cb({
        neons = neonData.neons,
        neonColor = savedNeons ~= nil and savedNeons or {GetVehicleNeonLightsColour(vehicle)},
        headlightColor = savedHeadlights ~= nil and savedHeadlights or {GetVehicleXenonLightsCustomColor(vehicle)}, 
        rainbowEnabled = rainbowEnabled,
        rainbowEnabledHeadlights = rainbowEnabledHeadlights,
        neonAnimation = neonAnimation,
        headlightAnimation = headlightAnimation,
    })
end)

RegisterNUICallback('getConfig', function(data, cb)
    cb(Config)
end)

RegisterNUICallback('callback', function(data)
    nuiCallback(data)
end)

function nuiCallback(data)
    if data.event == "toggleLights" then
        local lightState = not neonData.neons.left
        if not lightState then
            neonAnimation = nil
            rainbowEnabled = false
        end
        neonData.neons.left  = lightState
        neonData.neons.right = lightState
        neonData.neons.front = lightState
        neonData.neons.back  = lightState
        SetVehicleNeonLightEnabled(vehicle, 0, neonData.neons.left)
        SetVehicleNeonLightEnabled(vehicle, 1, neonData.neons.right)
        SetVehicleNeonLightEnabled(vehicle, 2, neonData.neons.front)
        SetVehicleNeonLightEnabled(vehicle, 3, neonData.neons.back)
    elseif data.event == "toggleLight" then
        neonData.neons[string.lower(data.side)] = not neonData.neons[string.lower(data.side)]
        SetVehicleNeonLightEnabled(vehicle, indexTable[data.side], neonData.neons[string.lower(data.side)])
    elseif data.event == "changeAllNeonColor" then 
        SetVehicleNeonLightsColour(vehicle, data.color.r, data.color.g, data.color.b)
        if savedNeons ~= nil then
            savedNeons = {data.color.r, data.color.g, data.color.b}
        end
    elseif data.event == "clearHeadlightColor" then 
        ClearVehicleXenonLightsCustomColor(vehicle)
        rainbowEnabledHeadlights = false
        savedHeadlights = nil
        headlightAnimation = nil
        SetVehicleLights(vehicle, 3)
    elseif data.event == "changeAllHeadlightColor" then
        if not IsToggleModOn(vehicle, 22) then
            ToggleVehicleMod(vehicle, 22, true, false)
        end
        SetVehicleXenonLightsCustomColor(vehicle, data.color.r, data.color.g, data.color.b)
    elseif data.event == "toggleRainbowHeadlights" then 
        local retval, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
        if not lightsOn and not highbeamsOn then return end
        if not IsToggleModOn(vehicle, 22) then
            ToggleVehicleMod(vehicle, 22, true, false)
        end
        rainbowEnabledHeadlights = not rainbowEnabledHeadlights
        if rainbowEnabledHeadlights then
            savedHeadlights = {GetVehicleXenonLightsCustomColor(vehicle)}
            toggleRGB()
        else
            SetVehicleXenonLightsCustomColor(vehicle, savedHeadlights[2], savedHeadlights[3], savedHeadlights[4])
            savedHeadlights = nil
        end
    elseif data.event == "toggleRainbow" then 
        if not neonData.neons.left and not neonData.neons.right and not neonData.neons.front and not neonData.neons.back then
            return
        end

        rainbowEnabled = not rainbowEnabled
        if rainbowEnabled then
            savedNeons = {GetVehicleNeonLightsColour(vehicle)}
            toggleRGB()
        else
            SetVehicleNeonLightsColour(vehicle, savedNeons[1], savedNeons[2], savedNeons[3])
            savedNeons = nil
        end
    elseif data.event == "neonAnimation" then 
        if not neonData.neons.left and not neonData.neons.right and not neonData.neons.front and not neonData.neons.back then return end

        if neonAnimation ~= data.type then
            neonAnimation = nil
            Wait(50)
            neonAnimation = data.type
            if neonAnimation == "breathingNeon" or neonAnimation == "reactiveNeon" then
                savedNeons = {GetVehicleNeonLightsColour(vehicle)}
            elseif neonAnimation == "aroundNeon" or neonAnimation == "ftbNeon" then
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
            end
            if headlightAnimation == nil then
                handleAnimations()
            end
        else
            neonAnimation = nil
            Wait(200)
            SetVehicleNeonLightEnabled(vehicle, 0, true)
            SetVehicleNeonLightEnabled(vehicle, 1, true)
            SetVehicleNeonLightEnabled(vehicle, 2, true)
            SetVehicleNeonLightEnabled(vehicle, 3, true)
            if savedNeons ~= nil then
                SetVehicleNeonLightsColour(vehicle, savedNeons[1], savedNeons[2], savedNeons[3])
            end
        end
    elseif data.event == "headlightAnimation" then 
        if headlightAnimation ~= data.type then
            headlightAnimation = nil
            Wait(50)
            headlightAnimation = data.type
            if neonAnimation == nil then
                handleAnimations()
            end
        else
            headlightAnimation = nil
            Wait(200)
            SetVehicleLights(vehicle, 3)
        end
    elseif data.event == "saveConfigData" then
        local neonData = {
            neons = {
                left = IsVehicleNeonLightEnabled(vehicle, 0),
                right = IsVehicleNeonLightEnabled(vehicle, 1),
                front = IsVehicleNeonLightEnabled(vehicle, 2),
                back = IsVehicleNeonLightEnabled(vehicle, 3),
            },
            neonColor = savedNeons ~= nil and savedNeons or {GetVehicleNeonLightsColour(vehicle)},
            headlightColor = savedHeadlights ~= nil and savedHeadlights or {GetVehicleXenonLightsCustomColor(vehicle)}, 
            rainbowEnabled = rainbowEnabled,
            rainbowEnabledHeadlights = rainbowEnabledHeadlights,
            neonAnimation = neonAnimation,
            headlightAnimation = headlightAnimation,
        }
        TriggerServerEvent("nass_neons:savePlayerConfig", data.name, neonData)
    elseif data.event == "applyPreset" then
        local cfgData = data.data
        nuiCallback({event="changeAllNeonColor", color={r=cfgData.neonColor[1], g=cfgData.neonColor[2], b=cfgData.neonColor[3]}})
        nuiCallback({event="changeAllHeadlightColor", color={r=cfgData.headlightColor[2], g=cfgData.headlightColor[3], b=cfgData.headlightColor[4]}})
        nuiCallback({event="neonAnimation", type=cfgData.neonAnimation})
        nuiCallback({event="headlightAnimation", type=cfgData.headlightAnimation})
        for k,v in pairs(cfgData.neons) do
            neonData.neons[k] = v
            SetVehicleNeonLightEnabled(vehicle, indexTable[k], neonData.neons[k])
        end
        Citizen.CreateThread(function()
            if cfgData.rainbowEnabled then
                rainbowEnabled = not cfgData.rainbowEnabled
                nuiCallback({event="toggleRainbow"})
            end
        end)
        Citizen.CreateThread(function()
            if cfgData.rainbowEnabledHeadlights then
                SetVehicleLights(vehicle, 3)
                rainbowEnabledHeadlights = not cfgData.rainbowEnabledHeadlights
                nuiCallback({event="toggleRainbowHeadlights"})
            end
        end)
    elseif data.event == "deletePreset" then
        TriggerServerEvent("nass_neons:deleteSavedConfig", data.index)
    end
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= "CEventNetworkPlayerEnteredVehicle" then return end
    vehicle = data[2]
    if prevVehData[vehicle] then
        rainbowEnabled = prevVehData[vehicle].rainbowEnabled 
        rainbowEnabledHeadlights = prevVehData[vehicle].rainbowEnabledHeadlights 
        Wait(2000)
        toggleRGB()
    end
end)

local loopRunning = false
function toggleRGB()
    local rainbow = {}
    if loopRunning then return print("stopeed double") end
    loopRunning = true
    while rainbowEnabled or rainbowEnabledHeadlights do
        Wait(80) -- Faster updates for smooth transitions
        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
            prevVehData[vehicle] = {}
            prevVehData[vehicle].rainbowEnabled = rainbowEnabled
            prevVehData[vehicle].rainbowEnabledHeadlights = rainbowEnabledHeadlights
            rainbowEnabled = false
            rainbowEnabledHeadlights = false
            vehicle = 0
        end

        local frequency = 1.0
        local currTime = GetGameTimer() / 1000
        rainbow.r = math.floor(math.sin(currTime * frequency) * 127 + 128)
        rainbow.g = math.floor(math.sin(currTime * frequency + 2) * 127 + 128)
        rainbow.b = math.floor(math.sin(currTime * frequency + 4) * 127 + 128)

        if rainbowEnabled then
            SetVehicleNeonLightsColour(vehicle, rainbow.r, rainbow.g, rainbow.b)
        end

        if rainbowEnabledHeadlights then
            local retval, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
            if not lightsOn and not highbeamsOn then
                rainbowEnabledHeadlights = false
            end
            SetVehicleXenonLightsCustomColor(vehicle, rainbow.r, rainbow.g, rainbow.b)
        end
    end
    loopRunning = false
end

function handleAnimations()
    while neonAnimation ~= nil or headlightAnimation ~= nil do
        Wait(80)

        if neonAnimation ~= nil then
            if neonAnimation == "flashNeon" then
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
                Wait(500)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
                SetVehicleNeonLightEnabled(vehicle, 3, true)
                Wait(500)
            elseif neonAnimation == "breathingNeon" then
                local currTime = GetGameTimer() / 1000
                local intensity = (math.sin(currTime * 1.5) + 1) / 2

                SetVehicleNeonLightsColour(vehicle,
                    math.floor(savedNeons[1] * intensity),
                    math.floor(savedNeons[2] * intensity),
                    math.floor(savedNeons[3] * intensity)
                )
            elseif neonAnimation == "aroundNeon" then
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 3, true)
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
            elseif neonAnimation == "ftbNeon" then
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 3, true)
                Wait(200)
                SetVehicleNeonLightEnabled(vehicle, 3, false)
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
            elseif neonAnimation == "reactiveNeon" then
                local rpm = GetVehicleCurrentRpm(vehicle)
                local brightnessFactor = rpm * 255

                SetVehicleNeonLightsColour(vehicle,
                    math.floor(savedNeons[1] * (brightnessFactor / 255)),
                    math.floor(savedNeons[2] * (brightnessFactor / 255)),
                    math.floor(savedNeons[3] * (brightnessFactor / 255))
                )
            elseif neonAnimation == "raveNeon" then
                local leftEnabled = math.random(0, 1) == 1
                local rightEnabled = math.random(0, 1) == 1
                local frontEnabled = math.random(0, 1) == 1
                local backEnabled = math.random(0, 1) == 1

                SetVehicleNeonLightEnabled(vehicle, 0, leftEnabled)  
                SetVehicleNeonLightEnabled(vehicle, 1, rightEnabled) 
                SetVehicleNeonLightEnabled(vehicle, 2, frontEnabled) 
                SetVehicleNeonLightEnabled(vehicle, 3, backEnabled)  

                Citizen.Wait(math.random(50, 200)) 

                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 3, false)

                Citizen.Wait(math.random(50, 100))
            end
        end

        if headlightAnimation ~= nil then
            if headlightAnimation == "flashHeadlights" then
                SetVehicleLights(vehicle, 3)
                Wait(250)
                SetVehicleLights(vehicle, 4)
                Wait(250)
            end
        end
    end
end