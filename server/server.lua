-- ██     ██ ███████ ██████  ██   ██  ██████   ██████  ██   ██
-- ██     ██ ██      ██   ██ ██   ██ ██    ██ ██    ██ ██  ██
-- ██  █  ██ █████   ██████  ███████ ██    ██ ██    ██ █████
-- ██ ███ ██ ██      ██   ██ ██   ██ ██    ██ ██    ██ ██  ██
--  ███ ███  ███████ ██████  ██   ██  ██████   ██████  ██   ██

Config.Webhook = 'CHANGEME'
---------------------------------------------------------------------------------------------------------------------------------------------


local QBCore = exports['qb-core']:GetCoreObject()
local onDutyTimes = {}

AddEventHandler('playerDropped', function(reason)
    local src = source
    if onDutyTimes[src] then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        sendDutyTimeWebhook(src, playerName)
        onDutyTimes[src] = nil
    end
end)

function sendDutyTimeWebhook(src, playerName)
    local endTime = os.time()
    local timeOnDuty = os.difftime(endTime, onDutyTimes[src])
    local hours = math.floor(timeOnDuty / 3600)
    local minutes = math.floor((timeOnDuty % 3600) / 60)
    local seconds = timeOnDuty % 60
    sendToDiscord(playerName ..
        " went off duty. Total time on duty: " .. hours .. "H " .. minutes .. "M " .. seconds .. "S")
end

RegisterNetEvent('QBCore:ToggleDuty')
AddEventHandler('QBCore:ToggleDuty', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
    local metadata = xPlayer.PlayerData.metadata
    if metadata and metadata.callsign then
        playerName = playerName .. " (Callsign: " .. metadata.callsign .. ")"
    end
    if xPlayer.PlayerData.job and xPlayer.PlayerData.job.name == Config.PoliceJob or xPlayer.PlayerData.job and xPlayer.PlayerData.job.type == Config.PoliceJobType then
        if onDutyTimes[src] then
            sendDutyTimeWebhook(src, playerName)
            onDutyTimes[src] = nil
        else
            onDutyTimes[src] = os.time()
            sendToDiscord(playerName .. " went on duty.")
        end
    end
end)


function sendToDiscord(message)
    local webhook = Config.Webhook
    if webhook == '' or webhook == 'CHANGEME' then
        print('Please put webhook into editableserver.lua')
        return
    end
    local currentDateTime = os.date("%m-%d-%Y %H:%M:%S")
    local connect = {
        {
            ["color"] = 255,
            ["title"] = "Police Duty Log",
            ["description"] = message,
            ["footer"] = {
                ["icon_url"] = "https://media.discordapp.net/attachments/1077462714902917171/1077462755625418862/96Logo.png",
                ["text"] = "www.nemesisGD.com | " .. currentDateTime,
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
        json.encode({
            username = 'Nemesis Gaming Development | Police Duty',
            embeds = connect,
            avatar_url = 'https://media.discordapp.net/attachments/1077462714902917171/1077462755625418862/96Logo.png'
        }),
        { ['Content-Type'] = 'application/json' })
end
