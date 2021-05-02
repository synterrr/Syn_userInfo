local vrp = GetResourceState('vrp') == "started"
local esx = GetResourceState('es_extended') == "started"

local function vRPFramework()
    local Tunnel = module("vrp","lib/Tunnel")
    local Proxy = module("vrp","lib/Proxy")
    local Tools = module("vrp","lib/Tools")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP")

    --- function to get all user identifiers such as discord, license, ip, steam link, steam hex
    ---@param source number player source
    local function getIDS(source)
        local UIDs = {
            steam = '',
            steamhex = '',
            userID = '',
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
        end
        UIDs.userID = vRP.getUserId(source)
        return UIDs
    end

    vRP._prepare('vRP/getUserMoney', "SELECT * FROM vrp_user_moneys WHERE user_id = @id")
    vRP._prepare('vRP/getVehicles', "SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @id")
    vRP._prepare('vRP/getIdentifiers', "SELECT * FROM vrp_user_ids WHERE user_id = @id")

    --- Get user wallet and bank
    ---@param UID number User ID
    local function getMoney(UID)
        local rows = vRP.query('vRP/getUserMoney', { id = UID })
        for _, v in ipairs(rows) do
            return v
        end
    end
    --- get user vehicles
    ---@param UID number User ID
    local function getVehicles(UID)
        local rows = vRP.query('vRP/getVehicles', { id = UID })
        for i = 1, #rows do
            local vehicles = rows[i].vehicle
            return vehicles
        end
    end

    RegisterCommand('UInfo', function(source, args)
        if vRP.hasPermission(vRP.getUserId(source), cfg.permission) then
            if args[1] then
                local userSource = vRP.getUserSource(parseInt(args[1]))
                local identity = vRP.getUserIdentity(parseInt(args[1]))
                local weapons = vRPclient.getWeapons(userSource)
                local inventory = vRP.getInventory(userSource)
                SendWebhook(cfg.webhook, "> **__Information from "..identity.name.." "..identity.firstname..":__**", "> **__ABOUT USER:__**\n```as\nPlayer Age: "..identity.age.."\nPlayer Registration: "..identity.registration.."\nPlayer ID: "..identity.user_id.."\nPlayer Phone: "..identity.phone.."```\n> **__Player Economy:__**\n```delphi\nPlayer Wallet: "..getMoney(args[1]).wallet.."\nPlayer Bank: "..getMoney(args[1]).bank.."```\n > **__User Vehicles:__**\n```py\nPlayer Vehicles: "..json.encode(getVehicles(args[1]), {indent = true}).."```\n> **__Player Weapons:__**\n```prolog\n"..json.encode(weapons).."```\n> **__Player Status:__**\n```py\nPlayer Health: "..vRPclient.getHealth(userSource).."\nPlayer Armour: "..vRPclient.getArmour(userSource).."```\n> **__Inventory Info:__**\n```py\n Inventory Items: "..json.encode(inventory).."```\n> **__User Identifiers:__**\n```prolog\nSteam Hex: "..getIDS(userSource).steamhex.."\nSteam Link: "..getIDS(userSource).steam.."\nDiscord: "..getIDS(userSource).discord.."\nLicense: "..getIDS(userSource).license.."\nIP: "..getIDS(userSource).ip.."```")
            end
        end
    end)
end

local function ESXFramework()

end

CreateThread(function()
    if IsDuplicityVersion() then
        if vrp then
            vRPFramework()
        end
        if esx then
            ESXFramework()
        end
    end
end)

function SendWebhook(link, title, message, colour)
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
                ["text"] = os.date("\n[Date]: %m/%d/%Y [Hour]: %H:%M:%S"),
                ["icon_url"] = "https://static.wixstatic.com/media/2cd43b_5e8726f159cd446fbf05d1e0959817b3~mv2.png/v1/fill/w_277,h_359,fp_0.50_0.50/2cd43b_5e8726f159cd446fbf05d1e0959817b3~mv2.png",
            },
        }
    }
    PerformHttpRequest(link, function(err, text, headers) end, 'POST', json.encode({avatar_url = "http://pngimg.com/uploads/monkey/monkey_PNG18727.png", username = "SynTer User Info", embeds = synterrr}), { ['Content-Type'] = 'application/json' })
end

