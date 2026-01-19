local QBCore = nil
local ESX = nil

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
end

-- DATA PERSISTENCE SETUP
local DataFile = "custom_data.json"
local CustomData = {}

-- Function to Load Data
local function LoadData()
    local fileContent = LoadResourceFile(GetCurrentResourceName(), DataFile)
    if fileContent then
        CustomData = json.decode(fileContent)
    else
        CustomData = {}
    end
end

-- Function to Save Data
local function SaveData()
    SaveResourceFile(GetCurrentResourceName(), DataFile, json.encode(CustomData, { indent = true }), -1)
end

-- Load data when resource starts
LoadData()

RegisterServerEvent('ms-employeelist:server:requestData')
AddEventHandler('ms-employeelist:server:requestData', function()
    local src = source
    local employees = {}
    local jobName = "unknown"
    local jobLabel = "Unknown"

    -- IMPORTANT: QBCore/ESX Fetch Logic
    if Config.Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if not xPlayer then return end
        
        jobName = xPlayer.PlayerData.job.name
        jobLabel = xPlayer.PlayerData.job.label

        if Config.AllowedJobs[jobName] then
            local players = QBCore.Functions.GetQBPlayers()
            for _, v in pairs(players) do
                if v.PlayerData.job.name == jobName then
                    
                    local status = 'off_duty'
                    
                    if v.PlayerData.job.onduty then
                        status = 'on_duty'
                        -- Use saved CitizenID/License to check status if player reconnected
                        local id = v.PlayerData.citizenid
                        if CustomData[id] and CustomData[id].status == 'break' then
                            status = 'afk'
                        end
                    end
                    
                    local radio = Player(v.PlayerData.source).state['radioChannel'] or 0
                    if radio == 0 then radio = "-" end

                    local callsign = v.PlayerData.metadata['callsign'] or "000"
                    local name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname
                    
                    -- Check Custom Data using CitizenID (Unique to character)
                    local id = v.PlayerData.citizenid
                    if CustomData[id] then
                        if CustomData[id].callsign then callsign = CustomData[id].callsign end
                        if CustomData[id].name then name = CustomData[id].name end
                    end

                    table.insert(employees, {
                        source = v.PlayerData.source,
                        callsign = callsign,
                        name = name,
                        radio = radio,
                        status = status
                    })
                end
            end
        end

    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and Config.AllowedJobs[xPlayer.job.name] then
            jobName = xPlayer.job.name
            jobLabel = xPlayer.job.label
            local xPlayers = ESX.GetPlayers()
            
            for i=1, #xPlayers, 1 do
                local xTarget = ESX.GetPlayerFromId(xPlayers[i])
                if xTarget and xTarget.job.name == jobName then
                    local radio = Player(xTarget.source).state['radioChannel'] or 0
                    local status = 'on_duty' 
                    
                    local id = xTarget.identifier
                    if CustomData[id] and CustomData[id].status == 'break' then
                        status = 'afk'
                    end
                    
                    local callsign = "000"
                    local name = xTarget.getName()

                    if CustomData[id] then
                        if CustomData[id].callsign then callsign = CustomData[id].callsign end
                        if CustomData[id].name then name = CustomData[id].name end
                    end
                    
                    table.insert(employees, {
                        source = xTarget.source,
                        callsign = callsign,
                        name = name,
                        radio = radio,
                        status = status
                    })
                end
            end
        end
    end

    TriggerClientEvent('ms-employeelist:client:receiveData', src, employees, jobLabel)
end)

RegisterNetEvent('ms-employeelist:server:updateSelf')
AddEventHandler('ms-employeelist:server:updateSelf', function(data)
    local src = source
    local id = nil

    -- Get Unique ID based on framework
    if Config.Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer then id = xPlayer.PlayerData.citizenid end
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then id = xPlayer.identifier end
    end

    if not id then return end
    if not CustomData[id] then CustomData[id] = {} end
    
    if data.type == 'callsign' then
        CustomData[id].callsign = data.value
        -- Sync with QBCore metadata if applicable
        if Config.Framework == 'qbcore' then
            local xPlayer = QBCore.Functions.GetPlayer(src)
            xPlayer.Functions.SetMetaData("callsign", data.value)
        end
    elseif data.type == 'name' then
        CustomData[id].name = data.value
    elseif data.type == 'status' then
        CustomData[id].status = data.value
    end

    SaveData() -- Save to JSON file immediately
end)