local QBCore = nil
local ESX = nil
local PlayerJob = {}
local isOpen = false

CreateThread(function()
    if Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
        
        -- 1. Try to get job immediately (in case of resource restart)
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then 
            PlayerJob = playerData.job 
        end

        -- 2. Listen for when player FULLY loads (Fixes the re-log issue)
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            local pd = QBCore.Functions.GetPlayerData()
            if pd and pd.job then PlayerJob = pd.job end
        end)

        -- 3. Listen for Job Changes
        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerJob = JobInfo
        end)

    elseif Config.Framework == 'esx' then
        ESX = exports["es_extended"]:getSharedObject()
        
        -- 1. Try to get job immediately
        if ESX.IsPlayerLoaded() then
            PlayerJob = ESX.GetPlayerData().job
        end

        -- 2. Listen for Player Load
        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerJob = xPlayer.job
        end)

        -- 3. Listen for Job Changes
        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job
        end)
    end
end)

RegisterCommand(Config.Command, function()
    -- JUST-IN-TIME CHECK: If PlayerJob is missing, try to fetch it one last time
    if not PlayerJob or not PlayerJob.name then
        if Config.Framework == 'qbcore' then
            local pd = QBCore.Functions.GetPlayerData()
            if pd then PlayerJob = pd.job end
        elseif Config.Framework == 'esx' then
            PlayerJob = ESX.GetPlayerData().job
        end
    end

    -- Security Check
    if not PlayerJob or not PlayerJob.name or not Config.AllowedJobs[PlayerJob.name] then
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify("Access Denied: Authorized Personnel Only", "error")
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification("Access Denied: Authorized Personnel Only")
        end
        return
    end

    if isOpen then
        CloseUI()
    else
        OpenEditMode()
    end
end)

function OpenEditMode()
    isOpen = true
    TriggerServerEvent('ms-employeelist:server:requestData')
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openEdit"
    })
    
    CreateThread(function()
        while isOpen do
            Wait(5000)
            if isOpen then
                TriggerServerEvent('ms-employeelist:server:requestData')
            end
        end
    end)
end

function CloseUI()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
end

RegisterNetEvent('ms-employeelist:client:receiveData')
AddEventHandler('ms-employeelist:client:receiveData', function(employees, jobLabel)
    SendNUIMessage({
        action = "updateList",
        employees = employees,
        mySource = GetPlayerServerId(PlayerId()),
        jobLabel = jobLabel
    })
end)

RegisterNUICallback('confirmSettings', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('updateSelf', function(data, cb)
    TriggerServerEvent('ms-employeelist:server:updateSelf', data)
    cb('ok')
end)