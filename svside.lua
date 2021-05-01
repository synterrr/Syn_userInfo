local vrp = GetResourceState('vrp') == "started"
local esx = GetResourceState('es_extended') == "started"

--- function to get all user identifiers such as discord, license, ip, steam link, steam hex
---@param source number player source
local function getIDS(source)
    local UIDs = {
        steam = '',
        steamhex = '',
        userSource = '',
        discord = '',
        license = '',
        ip = ''
    }
    for i = 0, GetNumPlayerIdentifiers(source) -1 do
        local plyID = GetPlayerIdentifier(source, i)
        if plyID:find("steam") then
            UIDs.steamhex = plyID
            local steamWithoutSteam = plyID:gsub("steam:", "")
            local steamLink = tostring(tonumber(steamWithoutSteam, 16))
            UIDs.steam = "https://steamcommunity.com/profiles/"..steamLink
        elseif plyID:find("license") then
            UIDs.license = plyID
        elseif plyID:find("discord") then
            UIDs.discord = plyID -- discord ID will only work if the user link his discord account to FiveM
        elseif plyID:find("ip") then
            UIDs.ip = plyID
        end
        UIDs.userSource = source
    end
end

local function vRPFramework()
    local Tunnel = module("vrp","lib/Tunnel")
    local Proxy = module("vrp","lib/Proxy")
    local Tools = module("vrp","lib/Tools")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP")

    vRP._prepare('vRP/getUserMoney', "SELECT * FROM vrp_users_moneys WHERE user_id = @id")
    vRP._prepare('vRP/getVehicles', "SELECT * FROM vrp_users_vehicles WHERE user_id = @id")

    local userInfos = {}

    RegisterCommand('UInfo', function(source, args)
        if args[1] then
            table.insert(userInfos, vRP.query('vRP/getUserMoney', { id = args[1] }))
            table.insert(userInfos, vRP.query('vRP/getVehicles', { id = args[1] }))
            print(userInfos)
        end
    end)

end

local function ESXFramework()

end

local function Standalone()

end

CreateThread(function()
    if IsDuplicityVersion() then
        if vrp then
            vRPFramework()
        elseif esx then
            ESXFramework()
        else
            Standalone()
        end
    end
end)

local function SendWebhook(link, title, message, colour)
    if not colour then
        colour = 7274308
    end
    local synterrr = {
        {
            ["title"] = title,
            ["thumbnail"] = {
                ["url"] = 'https://static.wixstatic.com/media/2cd43b_5e8726f159cd446fbf05d1e0959817b3~mv2.png/v1/fill/w_277,h_359,fp_0.50_0.50/2cd43b_5e8726f159cd446fbf05d1e0959817b3~mv2.png',
            },
            ["color"] = colour,
            ["description"] = message,
            ["footer"] = {
                ["text"] = os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S"),
                ["icon_url"] = "https://static.wixstatic.com/media/2cd43b_5e8726f159cd446fbf05d1e0959817b3~mv2.png/v1/fill/w_277,h_359,fp_0.50_0.50/2cd43b_5e8726f159cd446fbf05d1e0959817b3~mv2.png",
            },
        }
    }
    PerformHttpRequest(link, function(err, text, headers) end, 'POST', json.encode({avatar_url = "http://pngimg.com/uploads/monkey/monkey_PNG18727.png", username = "Minty AntiCheat", embeds = synterrr}), { ['Content-Type'] = 'application/json' })
end