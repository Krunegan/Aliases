local alias_data = {}
local storage_file = minetest.get_worldpath() .. "/calias.txt"

local function load_aliases()
    local file = io.open(storage_file, "r")
    if file then
        for line in file:lines() do
            local name, alias = line:match("^(%S+)%s+(%S+)$")
            if name and alias then
                alias_data[name] = alias
            end
        end
        file:close()
    end
end

local function save_aliases()
    local file = io.open(storage_file, "w")
    if file then
        for name, alias in pairs(alias_data) do
            file:write(name .. " " .. alias .. "\n")
        end
        file:close()
    end
end

local function update_nametag(player, alias)
    if alias then
        player:set_nametag_attributes({ text = alias, color = { a = 255, r = 255, g = 255, b = 255 } })
    else
        player:set_nametag_attributes({ text = player:get_player_name(), color = { a = 255, r = 255, g = 255, b = 255 } })
    end
end

minetest.register_chatcommand("calias", {
    params = "<newname>|off",
    description = "Change your chat alias",
    privs = { shout = true },
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        if param == "off" then
            alias_data[name] = nil
            update_nametag(player, nil)
            save_aliases()
            return true, "Alias removed."
        elseif param ~= "" then
            alias_data[name] = param
            update_nametag(player, param)
            save_aliases()
            return true, "Alias set to '" .. param .. "'."
        else
            return false, "Invalid usage. Use /calias <newname>|off"
        end
    end,
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local alias = alias_data[name]
    update_nametag(player, alias)
end)

minetest.register_on_mods_loaded(function()
    minetest.register_on_chat_message(function(name, message)
        local alias = alias_data[name]
        if alias then
            minetest.chat_send_all("<" .. alias .. "> " .. message)
            return ""
        end
    end)
end)

load_aliases()