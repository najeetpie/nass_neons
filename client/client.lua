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
        data.vehEnt = VehToNet(vehicle)
        TriggerServerEvent("nass_neons:callback", data)
        rainbowEnabledHeadlights = false
        savedHeadlights = nil
        headlightAnimation = nil
    elseif data.event == "changeAllHeadlightColor" then
        data.vehEnt = VehToNet(vehicle)
        TriggerServerEvent("nass_neons:callback", data)
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
        local neonData = getNeonData(vehicle)
        TriggerServerEvent("nass_neons:savePlayerConfig", data.name, neonData)
    elseif data.event == "applyPreset" then
        setNeonData(vehicle, data.data)
    elseif data.event == "deletePreset" then
        TriggerServerEvent("nass_neons:deleteSavedConfig", data.index)
    end
end

RegisterNetEvent('nass_neons:serverCallback')
AddEventHandler('nass_neons:serverCallback', function(data)
    if data.event == "changeAllHeadlightColor" then
        local veh = NetToVeh(data.vehEnt)
        if not IsToggleModOn(veh, 22) then
            ToggleVehicleMod(veh, 22, true, false)
        end
        SetVehicleXenonLightsCustomColor(veh, data.color.r, data.color.g, data.color.b)
    elseif data.event == "clearHeadlightColor" then
        local veh = NetToVeh(data.vehEnt)
        ClearVehicleXenonLightsCustomColor(veh)
        SetVehicleLights(veh, 3)
    end
end)

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
    if loopRunning then return end
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

                Wait(math.random(50, 200)) 

                SetVehicleNeonLightEnabled(vehicle, 0, false)
                SetVehicleNeonLightEnabled(vehicle, 1, false)
                SetVehicleNeonLightEnabled(vehicle, 2, false)
                SetVehicleNeonLightEnabled(vehicle, 3, false)

                Wait(math.random(50, 100))
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

RegisterNetEvent('nass_neons:notify')
AddEventHandler('nass_neons:notify', function(msg) --Had issues when trying to call directly to the notify function. This seems to work much better
    notify(msg)
end)

function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(0, 1)
end

function getNeonData(veh)
    vehicle = veh
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
    return neonData
end

function setNeonData(veh, data)
    vehicle = veh
    nuiCallback({event="changeAllNeonColor", color={r=data.neonColor[1], g=data.neonColor[2], b=data.neonColor[3]}})
    nuiCallback({event="changeAllHeadlightColor", color={r=data.headlightColor[2], g=data.headlightColor[3], b=data.headlightColor[4]}})
    nuiCallback({event="neonAnimation", type=data.neonAnimation})
    nuiCallback({event="headlightAnimation", type=data.headlightAnimation})
    for k,v in pairs(data.neons) do
        neonData.neons[k] = v
        SetVehicleNeonLightEnabled(vehicle, indexTable[k], neonData.neons[k])
    end
    Citizen.CreateThread(function()
        if data.rainbowEnabled then
            rainbowEnabled = not data.rainbowEnabled
            nuiCallback({event="toggleRainbow"})
        end
    end)
    Citizen.CreateThread(function()
        if data.rainbowEnabledHeadlights then
            SetVehicleLights(vehicle, 3)
            rainbowEnabledHeadlights = not data.rainbowEnabledHeadlights
            nuiCallback({event="toggleRainbowHeadlights"})
        end
    end)
end


local vehicleBones = {
    { label = "Front", bone = "bonnet" },
    { label = "Back", bone = "boot" },
    { label = "Left", bone = "door_dside_f" },
    { label = "Right", bone = "door_pside_f" }
}

function playAnimation(animDict, animName, animFlag)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, -1, animFlag or 1, 0, false, false, false)
end

function installNeon(vehicle, item)
    isInstalling = true
    cornersCompleted = {}
    currentCornerIndex = 1

    for _, corner in pairs(vehicleBones) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, corner.bone)
        if boneIndex ~= -1 then
            local cornerPos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            cornersCompleted[corner.label] = { completed = false, position = cornerPos }
        else
            cornersCompleted[corner.label] = { completed = true }
        end
    end

    Citizen.CreateThread(function()
        while isInstalling do
            Wait(0)
            local currentCornerLabel = vehicleBones[currentCornerIndex].label
            local currentCorner = cornersCompleted[currentCornerLabel]

            if currentCorner and not currentCorner.completed then
                local playerPos = GetEntityCoords(PlayerPedId())
                local distance = #(playerPos - currentCorner.position)

                if distance < Config.installNeon.drawDistance then
                    draw3DText(currentCorner.position.x, currentCorner.position.y, currentCorner.position.z + 0.5, string.format(Config.locale["install_neon"], currentCornerLabel))
                    if IsControlJustPressed(1, 38) and distance < Config.installNeon.interactDistance then
                        playAnimation("anim@amb@business@weed@weed_inspecting_lo_med_hi@", "weed_crouch_checkingleaves_idle_02_inspector", 1)
                        Wait(Config.installNeon.installTime)
                        ClearPedTasks(PlayerPedId())
                        cornersCompleted[currentCornerLabel].completed = true

                        while cornersCompleted[vehicleBones[currentCornerIndex]?.label]?.completed do
                            currentCornerIndex = currentCornerIndex + 1
                            if currentCornerIndex > #vehicleBones then
                                isInstalling = false
                                notify(Config.locale["neons_succ_installed"])
                                TriggerServerEvent("nass_neons:installNeons", GetVehicleNumberPlateText(vehicle), item)
                                vehicle = 0
                            end
                        end
                    end
                end
            end
        end
        vehicle = 0
    end)
end

RegisterNetEvent('nass_neons:installNeons')
AddEventHandler('nass_neons:installNeons', function(item)
    local ped = PlayerPedId()
    vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
        if GetEntitySpeed(vehicle) < 1.0 then
            TaskLeaveVehicle(ped, vehicle, 0)
            Wait(500)
            installNeon(vehicle, item)
        end
    end
end)

function draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end
