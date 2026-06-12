local CONFIG_FILE = "C:/Users/" .. os.getenv("USERNAME") .. "/AppData/Local/Growtopia/scripts/radiantConfig.lua"

local commands = {}
local routes = {}
local controller = {}
local aliases = {}
local info = {}
local utils = {}
local dialog = {}

local version = "1.0.0"

local config = {
    spin = {
        real = 1,
        leme = 0,
        reme = 1,
        qeme = 0,
        sspin = 0,
    },

    wrench = {
        pull = 0,
        kick = 0,
        ban = 0,
        smodal = 0,
        text = {
            pull = "Gas? MIN 5 BGL - BLACK",
            kick = "BYE",
            ban = "BYE"
        }
    },

    
    auto = {
        spam = {
            status = 0
        },
        pull = {
            status = 0,
            setTileStatus = 0,
            webhook = 0,
            webhookURL = "https://discord.com/api/webhooks/1514781525760147466/Coxui_FPaK9HjxshyMUnGHaXv70A8yDveaNCJGo2FsZUtPII1lCq_Pthy3TRnQuRdgZd",
            discordId = "",
            x = 0,
            y = 0,
            delay = 100,
            blacklist = {
                [582039] = "ceiling",
            },
        },
        cv = 0,
    }
}



local const = {
    itemId = {
        bgl = GetItemByName("CreativePS Blue Gem Lock").id,
        black = GetItemByName("CreativePS Black Gem Lock").id,
        dl = GetItemByName("CreativePS Diamond Lock").id,
        wl = GetItemByName("CreativePS World Lock").id,
        champagne = GetItemByName("Champagne").id,
        roulette = 758,
        wrench = 32,
        holographicSign = 2586,
        superSpeed = 2322,
        txmom = 4626,
        calculator = 16072,
        telephone = 3898,
        fireWand = 276,
        curseWand = 278,
        growtopianBean = 11394
    },
    color = {
        success = "`2",
        fail = "`4",
        header = "`c",
        text = "`0",
        info = "`5"
    }
}

local function say(msg, public)
    if public then
        SendPacket(2, "action|input\n|text|" .. const.color.text .. "[" .. const.color.header .. "Radiant" .. const.color.text .. "] ``````" .. msg)
    else
        SendVariantList({
            [0] = "OnTalkBubble",
            [1] = GetLocal().netid,
            [2] = info.wm .. " " .. msg
        })
    end
end

local function print(msg)
    LogToConsole(msg)
end

local function sendDialog(dialog)
    local dialog = {
        "set_bg_color|45,45,45,200|",
        "set_border_color|100,100,100,255|",
        dialog,
    }

    SendVariantList({
        [0] = "OnDialogRequest",
        [1] = table.concat(dialog, "\n")
    })

    -- print(table.concat(dialog, "\n"))
end

local function sendOverlay(msg)
    SendVariantList({[0] = "OnTextOverlay", [1] = msg}, -1)
end

local function drop(itemId, amount)
    if amount <= 0 then
        return
    end

    SendPacket(
        2,
        "action|dialog_return\n" ..
        "dialog_name|drop\n" ..
        "item_drop|" .. itemId .. "|\n" ..
        "item_count|" .. amount
    )
end

local function wear(id)
    SendPacketRaw(false, {
        type = 10,
        value = id
    })
end



function utils.convertLocksCount(amount)
    local WL = amount

    local black = math.floor(WL / 1000000)
    WL = WL % 1000000

    local bgl = math.floor(WL / 10000)
    WL = WL % 10000

    local dl = math.floor(WL / 100)
    WL = WL % 100

    local wl = WL

    return {
        wl = wl,
        dl = dl,
        bgl = bgl,
        black = black
    }
end

function utils.calculate(expr)
    local expr = tostring(expr)
        :gsub("%s+", "")
        :gsub("[xX]", "*")
        :gsub(":", "/")

    if not expr:match("^[%d%.%+%-%*/]+$") then
        return false
    end

    local numbers = {}
    local operators = {}

    for num, op in expr:gmatch("(%d+%.?%d*)([%+%-%*/]?)") do
        table.insert(numbers, tonumber(num))
        if op ~= "" then
            table.insert(operators, op)
        end
    end

    -- Kerjakan * dan /
    local i = 1
    while i <= #operators do
        local op = operators[i]

        if op == "*" or op == "/" then
            local a = numbers[i]
            local b = numbers[i + 1]

            numbers[i] = (op == "*") and (a * b) or (a / b)

            table.remove(numbers, i + 1)
            table.remove(operators, i)
        else
            i = i + 1
        end
    end

    -- Kerjakan + dan -
    local result = numbers[1]

    for i = 1, #operators do
        if operators[i] == "+" then
            result = result + numbers[i + 1]
        else
            result = result - numbers[i + 1]
        end
    end

    return result
end

function utils.wrenchAction(type, netid)

    if type == "smodal" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. netid .. "|\nbuttonClicked|viewinv")
    elseif type == "pull" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. netid .. "|\nbuttonClicked|pull")
        say(config.wrench.text.pull, true)
    elseif type == "kick" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. netid .. "|\nbuttonClicked|kick")
        say(config.wrench.text.kick, true)
    elseif type == "ban" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. netid .. "|\nbuttonClicked|world_ban")
        say(config.wrench.text.ban, true)
    else
        print(const.color.fail .. "404 Action Wrench Not Found")
    end
end

-- function utils.sendWebhook(url, content, username, avatarUrl)
--     if not url or url == "" then
--         print(const.color.fail .. "[Webhook] URL kosong!")
--         return false
--     end

--     -- build JSON body manual (tanpa library)
--     local parts = {}
--     parts[#parts + 1] = '"content":"' .. tostring(content):gsub('"', '\\"') .. '"'

--     if username then
--         parts[#parts + 1] = '"username":"' .. tostring(username):gsub('"', '\\"') .. '"'
--     end
--     if avatarUrl then
--         parts[#parts + 1] = '"avatar_url":"' .. tostring(avatarUrl) .. '"'
--     end

--     local body = "{" .. table.concat(parts, ",") .. "}"

--     local res = MakeRequest(url, "POST", {
--         ["Content-Type"] = "application/json"
--     }, body)

--     if res.error then
--         print(const.color.fail .. "[Webhook] Request gagal!")
--         return false
--     end

--     -- Discord success = 204 No Content
--     if res.status == 204 or res.status == 200 then
--         print(const.color.success .. "[Webhook] Terkirim!")
--         return true
--     else
--         print(const.color.fail .. "[Webhook] Status: " .. tostring(res.status))
--         return false
--     end
-- end



local function serialize(tbl, indent)

    indent = indent or 0

    local spacing = string.rep("    ", indent)

    local result = "{\n"

    for key, value in pairs(tbl) do

        local keyString =
            "[" ..
            string.format("%q", key) ..
            "]"

        if type(value) == "table" then

            result =
                result ..
                spacing ..
                "    " ..
                keyString ..
                " = " ..
                serialize(value, indent + 1) ..
                ",\n"

        elseif type(value) == "string" then

            result =
                result ..
                spacing ..
                "    " ..
                keyString ..
                " = " ..
                string.format("%q", value) ..
                ",\n"

        else

            result =
                result ..
                spacing ..
                "    " ..
                keyString ..
                " = " ..
                tostring(value) ..
                ",\n"

        end

    end

    result =
        result ..
        spacing ..
        "}"

    return result
end

local function mergeConfig(current, defaults)

    for key, value in pairs(defaults) do

        if current[key] == nil then

            if type(value) == "table" then

                current[key] = {}

                mergeConfig(
                    current[key],
                    value
                )

            else

                current[key] = value

            end

        elseif
            type(value) == "table"
            and
            type(current[key]) == "table"
        then

            mergeConfig(
                current[key],
                value
            )

        end

    end
end

local function saveConfig()

    local file =
        io.open(
            CONFIG_FILE,
            "w"
        )

    if not file then
        return false
    end

    file:write(
        "return " ..
        serialize(config)
    )

    file:close()

    return true
end

local function loadConfig()

    local success, data =
        pcall(
            dofile,
            CONFIG_FILE
        )

    if not success then

        saveConfig()

        return false

    end

    mergeConfig(
        data,
        config
    )

    config = data

    return true
end

local function toggle(tbl, key, bubble, text)

    tbl[key] =
        tbl[key] == 0
        and 1
        or 0

    local status =
        tbl[key] == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    if text ~= nil then
        print(
            const.color.text ..
            text:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
            status
        )
        if bubble then
            say(
                const.color.text ..
                text:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
                status,
                true
            )
        end
    else
        print(
            const.color.text ..
            key:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
            status
        )
        if bubble then
            say(
                const.color.text ..
                key:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
                status,
                true
            )
        end
    end

    saveConfig()

    return tbl[key]
end

local function setExclusive(tbl, key, others, bubble, text)
    -- matikan semua dulu
    for _, k in ipairs(others) do
        tbl[k] = 0
    end

    -- toggle key utama
    tbl[key] = (tbl[key] == 1 and 0 or 1)



    local status =
        tbl[key] == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    if text ~= nil then
        print(
            const.color.text ..
            text:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
            status
        )
        if bubble then
            say(
                const.color.text ..
                text:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
                status,
                true
            )
        end
    else
        print(
            const.color.text ..
            key:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
            status
        )
        if bubble then
            say(
                const.color.text ..
                key:gsub("(%f[%a]%a)", string.upper) .. " Mode " ..
                status,
                true
            )
        end
    end

    saveConfig()
    return tbl[key]
end







local auto_pull_state = {
    thread_running = false,
    queue = {},
    last_pull = 0,
    pulled_set = {},       -- netid yg sudah di-pull, skip sampai ada player baru
    last_pulled_netid = nil
}

local function queuePull(uid)
    -- skip jika sudah pernah di-pull (belum ada player baru yg di-pull)
    if auto_pull_state.pulled_set[uid] then
        return
    end
    -- hindari duplikat di queue
    for _, v in ipairs(auto_pull_state.queue) do
        if v == uid then return end
    end
    table.insert(auto_pull_state.queue, uid)
end

local function isBlacklisted(uid)
    return config.auto.pull.blacklist[uid] ~= nil
end

local function scanPlayersAtTile(x, y)
    local result = {}

    for _, player in pairs(GetPlayerList()) do
        if player.pos then
            local px = math.floor(player.pos.x / 32)
            local py = math.floor(player.pos.y / 32)

            if px == x and py == y then
                local uid = tonumber(player.userid)

                if uid and not isBlacklisted(uid) then
                    table.insert(result, player.netid)

                end
            end
        end
    end
    
    return result
end

local function StartAutoPullThread()

    if auto_pull_state.thread_running then
        return
    end
    
    auto_pull_state.thread_running = true
    
    RunThread(function()
        
        while config.auto.pull.status == 1 do
            
            Sleep(config.auto.pull.delay or 3000)
            if #auto_pull_state.queue > 0 then
                local uid = table.remove(auto_pull_state.queue, 1)
                
                if not isBlacklisted(uid) then
                    utils.wrenchAction("pull", uid)
                    auto_pull_state.last_pull = os.time() * 1000
                    
                    -- kalau ini player BARU (beda dari sebelumnya), reset pulled_set
                    if auto_pull_state.last_pulled_netid ~= uid then
                        auto_pull_state.pulled_set = {}
                    end
                    -- if config.auto.pull.webhook == 1 and config.auto.pull.webhookURL ~= "" then
                    --     RunThread(function()
                    --         utils.sendWebhook(
                    --             config.auto.pull.webhookURL,
                    --             "<@" .. tostring(config.auto.pull.discordId) .. ">Ada player baru di-pull!",
                    --             GetLocal().name,
                    --             "https://cdn.discordapp.com/avatars/492655477210087435/archived/1500296560750362707/8b39374292165de660ed0f8472d88684.webp?size=96"
                    --         )
                    --     end)
                    -- end

                    -- tandai player ini sudah di-pull
                    auto_pull_state.pulled_set[uid] = true
                    auto_pull_state.last_pulled_netid = uid
                end
            end

            local ok, localPlayer = pcall(GetLocal)
            if not ok or not localPlayer then
                goto continue
            end

            local tx = config.auto.pull.x
            local ty = config.auto.pull.y

            if tx == 0 and ty == 0 then
                goto continue
            end

            local targets = scanPlayersAtTile(tx, ty)

            for _, netid in ipairs(targets) do
                -- anti spam pull
                if auto_pull_state.last_pull + 500 < os.time() * 1000 then

                    queuePull(netid)

                    auto_pull_state.last_pull = os.time() * 1000
                end
            end

            ::continue::
        end

        auto_pull_state.thread_running = false
    end)
end

local function StopAutoPullThread()
    config.auto.pull.status = 0
    auto_pull_state.thread_running = false
end






local function getBlacklistDialog()

    local result = {}

    for k, v in pairs(config.auto.pull.blacklist) do
        local uid = k
        local username = v

        local text = "add_button|removeBlacklist" .. uid .. "|" .. username .. " #" .. uid .. "|noflags|0|0|"
        table.insert(result, text)
    end

    return table.concat(result, "\n")
end

local function addBlacklistDialog()
    local result = {}

    for _, player in pairs(GetPlayerList()) do
        local uid = tonumber(player.userid)

        local username = player.name:gsub("`.", "")
        username = username:gsub("%((%d+)%)", "")
        username = username:gsub(" ", "")
        if not config.auto.pull.blacklist[uid] and not username:lower():find("spammerslave", 1, true) then
            table.insert(result,
                "add_button_with_icon|addBlacklist" .. uid ..
                "|" .. const.color.text .. username .. " #" .. uid ..
                "|staticPurpleFrame|" .. const.itemId.growtopianBean .. "|||"
            )

            table.insert(result,
                "embed_data|" .. uid .. "|" .. username
            )
        end
    end

    return table.concat(result, "\n")
end



function dialog.autoPull()
    local dialog = {
        "add_label_with_icon|big|" .. const.color.header .. "Auto Pull Settings|left|" .. const.itemId.fireWand,
        "add_spacer|small",
        "add_smalltext|" .. const.color.header .. " Auto Pull Tile: (" .. const.color.text .. config.auto.pull.x .. ", " .. config.auto.pull.y .. const.color.header .. ")|left",
        "add_button|setAutoPullTileBtn|" .. const.color.header .. "Set Auto Pull Tile|noflags|0|0|",
        "add_button|hrefBlacklistAutoPullDialog|`bBlacklist Auto Pull Settings|noflags|0|0|",
        "add_checkbox|enableWebhookAutoPull|" .. const.color.success .. "Enable " .. const.color.text .. "Send Webhook|" .. config.auto.pull.webhook,   
        "add_text_input|discordIdInput|" .. const.color.header .. "Discord ID:|" .. config.auto.pull.discordId .. "|120|",
        "add_spacer|small",
        "add_label|small|" .. const.color.header .. "Click To Add Player Into Blacklist:|left",
        addBlacklistDialog(),
        "add_button_with_icon||END_LIST|noflags|0||",
        "end_dialog|autoPullDialog|Cancel|Save"
    }

    sendDialog(table.concat(dialog, "\n"))
end



local function registerCommand(category, command, desc, icon, args, usage)

    local funcName = command:gsub("/", "")

    if type(controller[funcName]) ~= "function" then
        print("" .. const.color.fail .. "Controller not found: " .. const.color.text .. funcName)
        return false
    end

    routes[command] = controller[funcName]

    for _, data in ipairs(commands) do
        if data.category == category then

            table.insert(data.items, {
                cmd = command,
                desc = desc,
                args = args or false,
                usage = usage
            })

            print("" .. const.color.text .. "Registered command: " .. const.color.header .. "" .. command)
            return true
        end
    end

    table.insert(commands, {
        category = category,
        icon = icon,
        items = {
            {
                cmd = command,
                desc = desc,
                args = args or false,
                usage = usage
            }
        }
    })

    print("" .. const.color.text .. "Registered command: " .. const.color.header .. "" .. command)
    return true
end

local function registerAlias(alias, command)

    aliases[alias] = command

    print(
        "" .. const.color.text .. "Registered alias: " .. const.color.header .. "" ..
        alias ..
        " " .. const.color.text .. "-> " .. const.color.header .. "" ..
        command
    )

    return true
end

local function getCommands()

    local result = {}

    for _, categoryData in ipairs(commands) do

        table.insert(result,
            "add_spacer|small"
        )

        table.insert(result,
            "add_label_with_icon|small|" .. const.color.header .. "" ..
            categoryData.category ..
            ":|left|" ..
            categoryData.icon
        )

        for _, commandData in ipairs(categoryData.items) do

            local text =
                "add_smalltext|" .. const.color.header .. "" ..
                commandData.cmd ..
                " " .. const.color.text .. "(" ..
                commandData.desc ..
                ")|left"

            table.insert(result, text)
        end
    end

    return table.concat(result, "\n")
end

local function commandHandler(type, packet)

    if type == 2 and packet:find("action|input\n|text|/") then

        local fullText = packet:match("|text|([^\n]+)")
        local command, args = fullText:match("^(%S+)%s*(.*)$")

        -- alias redirect
        if aliases[command] then
            command = aliases[command]
        end

        for _, categoryData in ipairs(commands) do
            for _, commandData in ipairs(categoryData.items) do

                if command == commandData.cmd then

                    -- command tidak menerima argumen
                    if not commandData.args and args ~= "" then
                        return false
                    end

                    -- command membutuhkan argumen
                    if commandData.args and args == "" then

                        if commandData.usage then
                            print(
                                "" .. const.color.header .. "Usage: " .. const.color.text .. "" ..
                                command ..
                                " " ..
                                commandData.usage
                            )
                        else
                            print(
                                "" .. const.color.fail .. "This command requires arguments."
                            )
                        end

                        return true
                    end

                    if not routes[command] then
                        print("" .. const.color.fail .. "Controller not found.")
                        return true
                    end

                    LogToConsole("`6" .. command)

                    if commandData.args then
                        routes[command](args)
                    else
                        routes[command]()
                    end

                    return true
                end

            end
        end

        return false
    end
end



function controller.proxy()
    local proxyDialog = {
        "add_label_with_icon|big|" .. const.color.header .. "Radiant Commands List|left|" .. const.itemId.bgl .. "",
        getCommands(),
        "add_quick_exit"
    }

    sendDialog(table.concat(proxyDialog, "\n"))
end

function controller.news()
    local newsDialog = {
        "add_label_with_icon|big|" .. const.color.header .. "Radiant Proxy " .. const.color.text .. "By @lv3not7221|left|" .. const.itemId.bgl .. "",
        "add_spacer|small",
        "add_label_with_icon|small|" .. const.color.header .. "Proxy Info:|left|16448",
        "add_smalltext|" .. const.color.header .. "Developer: " .. const.color.text .. info.author .. "|left",
        "add_smalltext|" .. const.color.header .. "Version: " .. const.color.text .. info.version .. "|left",
        "add_smalltext|" .. const.color.header .. "Last Update: " .. const.color.text .. info.updated .. "|left",
        "add_smalltext|" .. const.color.header .. "Discord: " .. const.color.text .. info.discord .. "|left",
        "add_spacer|small",
        "add_label_with_icon|small|" .. const.color.header .. "Changelog:|left|6292",
        "add_smalltext|" .. const.color.text .. "[" .. const.color.success .. "+" .. const.color.text .. "] " .. const.color.text .. "Proxy Realeased|left",
        "add_spacer|big",
        "add_label_with_icon|big|" .. const.color.header .. "Radiant Commands List|left|" .. const.itemId.bgl .. "",
        getCommands(),
        "add_quick_exit"
    }

    sendDialog(table.concat(newsDialog, "\n"))
end

function controller.gazette()
    SendPacket(2, "action|input\n|text|/news")
end

function controller.spin()
    local  spinDialog = {
        "add_label_with_icon|big|" .. const.color.header .. "Roulette Wheel Settings|left|" .. const.itemId.roulette .. "",
        "add_spacer|small",
        "add_smalltext|" .. const.color.info .. "Detect Real Or Fake Spin|left",
        "add_checkbox|real|" .. const.color.success .. "Enable " .. const.color.text .. "Real Spin Detector|" .. tostring(config.spin.real) .. "|",
        "add_smalltext|" .. const.color.info .. "Shows Reme ON Number|left",
        "add_checkbox|reme|" .. const.color.success .. "Enable " .. const.color.text .. "Reme Mode|" .. tostring(config.spin.reme) .. "|",
        "add_smalltext|" .. const.color.info .. "Shows Leme Number + X|left",
        "add_checkbox|leme|" .. const.color.success .. "Enable " .. const.color.text .. "Leme Mode|" .. tostring(config.spin.leme) .. "|",
        "add_smalltext|" .. const.color.info .. "Shows Qeme Number|left",
        "add_checkbox|qeme|" .. const.color.success .. "Enable " .. const.color.text .. "Qeme Mode|" .. tostring(config.spin.qeme) .. "|",
        "add_smalltext|" .. const.color.info .. "Only Shows Number In Spin Bubble|left",
        "add_checkbox|sspin|" .. const.color.success .. "Enable " .. const.color.text .. "Short Spin|" .. tostring(config.spin.sspin) .. "|",
        "end_dialog|spinDialog|Cancel|Save"
    }

    sendDialog(table.concat(spinDialog, "\n"))
end

function controller.real()
    toggle(
        config.spin,
        "real",
        true,
        "real spin"
    )
end

function controller.reme()
    toggle(
        config.spin,
        "reme",
        true
    )
end

function controller.leme()
    toggle(
        config.spin,
        "leme",
        true
    )
end

function controller.qeme()
    toggle(
        config.spin,
        "qeme",
        true
    )
end

function controller.sspin()
    toggle(
        config.spin,
        "sspin",
        true,
        "short spin"
    )
end

function controller.wrm()
    local dialog = {
        "text_scaling_string|roleassets1234",
        "add_label_with_icon|big|" .. const.color.header .. "Wrench Settings|left|" .. const.itemId.wrench,
        "add_spacer|small",
        "add_checkbox|wrenchSModal|" .. const.color.success .. "Enable " .. const.color.text .. "Show Modal/Balance Player|" .. config.wrench.smodal,
        "add_label|small|" .. const.color.header .. "Fast Wrench:|left",
        "add_smalltext|" .. const.color.success .. "Green " .. const.color.info .. "Text And `9Yellow " .. const.color.info .. " Button Mean Currently Selected. Click Wrench Buttons To Choose Mode|left",
        "add_button_with_icon|wrenchPull|" .. (config.wrench.pull == 1 and const.color.success or const.color.info) .. "Pull|" .. (config.wrench.pull == 1 and "staticYellowFrame" or "staticPurpleFrame") .. "|" .. const.itemId.wrench .. "|||",
        "add_button_with_icon|wrenchKick|" .. (config.wrench.kick == 1 and const.color.success or const.color.fail) .. "Kick|" .. (config.wrench.kick == 1 and "staticYellowFrame" or "staticPurpleFrame") .. "|" .. const.itemId.wrench .. "|||",        
        "add_button_with_icon|wrenchBan|" .. (config.wrench.ban == 1 and const.color.success or const.color.fail) .. "Ban|" .. (config.wrench.ban == 1 and "staticYellowFrame" or "staticPurpleFrame") .. "|" .. const.itemId.wrench .. "|||purple",
        "add_button_with_icon||END_LIST|noflags|0||",
        "add_spacer|small",
        "add_text_input|pullText|" .. const.color.header .. "On Pull Text:|" .. config.wrench.text.pull .. "|98|",
        "add_text_input|kickText|" .. const.color.header .. "On Kick Text:|" .. config.wrench.text.kick .. "|98|",
        "add_text_input|banText|" .. const.color.header .. "On Ban Text:|" .. config.wrench.text.ban .. "|98|",
        
        "end_dialog|wrenchDialog|Cancel|Save"
    }


    sendDialog(table.concat(dialog, "\n"))
end

function controller.smodal()
    toggle(
        config.wrench,
        "smodal",
        true,
        "show modal"
    )
end

function controller.wrp()
    setExclusive(config.wrench, "pull", { "kick", "ban" }, true, "wrench pull")
end

function controller.wrk()
    setExclusive(config.wrench, "kick", { "pull", "ban" }, true, "wrench kick")

end

function controller.wrb()
    setExclusive(config.wrench, "ban", { "kick", "pull" }, true, "wrench kick")
end

function controller.w(amount)
    RunThread(function()
        local dl = math.floor(amount / 100)
        local wl = amount % 100
        local bgl = math.floor(dl / 100)
        dl = dl % 100

        if bgl > 0 and GetItemCount(const.itemId.bgl) < bgl then
            say(const.color.text .. "Not enough BGL, crafting...")
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            Sleep(100)
        end

        if bgl > 0 then
            if GetItemCount(const.itemId.bgl) >= bgl then
                drop(const.itemId.bgl, bgl)
                Sleep(100)
            else
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. bgl .. " `eBGL" .. const.color.text .. ")")
                return
            end
        end

        if dl > 0 and GetItemCount(const.itemId.dl) < dl then
            wear(const.itemId.bgl)
            Sleep(200)
        end

        if dl > 0 then
            if GetItemCount(const.itemId.dl) >= dl then
                drop(const.itemId.dl, dl)
                Sleep(100)
            else
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. dl .. " `1DL" .. const.color.text .. ")")
                return
            end
        end

        if wl > 0 and GetItemCount(const.itemId.wl) < wl then
            wear(const.itemId.dl)
            local wait_time = 0
            while GetItemCount(const.itemId.wl) < wl and wait_time < 2000 do
                Sleep(100)
                wait_time = wait_time + 100
            end
        end

        if wl > 0 then
            if GetItemCount(const.itemId.wl) >= wl then
                drop(const.itemId.wl, wl)
            else
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. wl .. " `9WL" .. const.color.text .. ")")
                return
            end
        end

        local msg = const.color.header .. "Dropped "
        if bgl > 0 then msg = msg .. "`w" .. bgl .. " `eBGL " end
        if dl > 0 then msg = msg .. "`w" .. dl .. " `1DL " end
        if wl > 0 then msg = msg .. "`w" .. wl .. " `9WL " end
        say(msg, true)
    end)
end

function controller.d(amount)
    RunThread(function()
        local bgl = math.floor(amount / 100)
        local dl = amount % 100

        if bgl > 0 and GetItemCount(const.itemId.bgl) < bgl then
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            Sleep(100)
        end

        if bgl > 0 then
            if GetItemCount(const.itemId.bgl) >= bgl then
                drop(const.itemId.bgl, bgl)
                Sleep(100)
            else
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. bgl .. " `eBGL" .. const.color.text .. ")")
                return
            end
        end

        if dl > 0 then
            if GetItemCount(const.itemId.dl) < dl then
                wear(const.itemId.bgl)
                local wait_time = 0
                while GetItemCount(const.itemId.dl) < dl and wait_time < 2000 do
                    Sleep(100)
                    wait_time = wait_time + 100
                end
            end

            if GetItemCount(const.itemId.dl) >= dl then
                drop(const.itemId.dl, dl)
            else
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. dl .. " `1DL" .. const.color.text .. ")")                return
            end
        end

        local msg = const.color.header .. "Dropped "
        if bgl > 0 then msg = msg .. "`w" .. bgl .. " `eBGL " end
        if dl > 0 then msg = msg .. "`w" .. dl .. " `1DL " end
        say(msg, true)
    end)
end

function controller.b(amount)
    RunThread(function()
        local black_needed = math.floor(amount / 100)
        local bgl_needed = amount % 100

        local have_black = GetItemCount(const.itemId.black)
        local have_bgl = GetItemCount(const.itemId.bgl)

        if black_needed > have_black then
            local bgl_to_convert = (black_needed - have_black) * 100
            if have_bgl >= bgl_to_convert then
                SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
                Sleep(1000)
                have_black = GetItemCount(const.itemId.black)
            end
        end

        if bgl_needed > have_bgl and have_black > black_needed then
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            Sleep(1000)
            have_bgl = GetItemCount(const.itemId.bgl)
        end

        if have_black < black_needed or have_bgl < bgl_needed then
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. amount .. " `eBGL" .. const.color.text .. ")")
            return
        end

        if black_needed > 0 then
            drop(const.itemId.black, black_needed)
            Sleep(100)
        end
        if bgl_needed > 0 then
            drop(const.itemId.bgl, bgl_needed)
            Sleep(100)
        end

        local msg = const.color.header .. "Dropped "
        if black_needed > 0 then msg = msg .. "`w" .. black_needed .. " `bBLACK " end
        if bgl_needed > 0 then msg = msg .. "`w" .. bgl_needed .. " `eBGL " end
        say(msg, true)
    end)
end

function controller.bb(amount)
    local amount = tonumber(amount)
    RunThread(function()
        if GetItemCount(const.itemId.black) < amount then
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            Sleep(100)
        end

        if GetItemCount(const.itemId.black) >= amount then
            helpers.OnDroppedItem(const.itemId.black, amount)
        else
                say(const.color.fail .. "You Dont Have That Much Locks!")
                print(const.color.fail .. "You Dont Have That Much Locks! " .. const.color.text .. "(" .. amount .. " `bBLACK" .. const.color.text .. ")")
            return
        end

        local msg = const.color.header .. "Dropped " .. const.color.text .. amount .. " `bBLACK"
        say(msg, true)
    end)
end

function controller.res()
    SendPacket(2, "action|respawn")
end

function controller.relog()
    local world_name = GetWorld().name

    SendPacket(3, "action|join_request\nname|" .. world_name .. "\ninvitedWorld|0")
end

function controller.exit()
    SendPacket(3, "action|quit_to_exit")
end

function controller.auto()
    local dialog = {
        "add_label_with_icon|big|" .. const.color.header .. "Auto Settings|left|" .. const.itemId.fireWand,
        "add_spacer|small",
        "add_button|hrefAutoPullDialog|" .. const.color.info .. "Auto Pull Settings|noflags|0|0|",
        "add_button|hrefAutoBanDiloag|" .. const.color.fail .. "Auto Ban Settings|noflags|0|0|",
        "add_spacer|small",
        "add_smalltext|" .. const.color.info .. "Auto Converting Locks To Higher Currency When Collected Locks.|left",
        "add_checkbox|autocv|" .. const.color.success .. "Enable " .. const.color.text .. "Auto Convert|" .. config.auto.cv,
        "add_smalltext|" .. const.color.info .. "Another Way To Start Spam|left",
        "add_checkbox|autocv|" .. const.color.success .. "Enable " .. const.color.text .. "Spam|" .. config.auto.spam.status,
        "end_dialog|autoDialog|Cancel|Save"
    }

    sendDialog(table.concat(dialog, "\n"))
end

function controller.autopull()
    dialog.autoPull()
end

function controller.setap()
    config.auto.pull.x = math.floor(GetLocal().pos.x / 32)
    config.auto.pull.y = math.floor(GetLocal().pos.y / 32)
    sendOverlay(const.color.success .. "Successfully " .. const.color.text .. "Set Auto Pull Tile On (" .. config.auto.pull.x .. ", " .. config.auto.pull.y .. ")")
    SendPacketRaw(true, {
        type = 38,
        netid = utils.xyToIndex(config.auto.pull.x, config.auto.pull.y),
        snetid = -1,
        state = 8,
        extDataSize = 100
    })

    saveConfig()
end

function controller.ap()
    toggle(config.auto.pull, "status", false, "Auto Pull")

    if config.auto.pull.status == 1 then
        StartAutoPullThread()
    else
        StopAutoPullThread()
    end

    saveConfig()
end


function controller.option()
    print(const.color.fail("Maintenance"))
end

function controller.calc(args)
    local result = utils.calculate(args)

    if not result then
        print(const.color.fail .. "Please Input Math Problem Only. " .. const.color.header .. "Ur Input: " .. const.color.text .. args)
    else
        print(const.color.text .. args .. " = "  .. result)
        say(const.color.text .. args .. " = "  .. result, true)
    end
end

function controller.logs()
    print(const.color.fail("Maintenance"))
end

function controller.blue()
    print(const.color.fail("Maintenance"))
end

function controller.buychamp()
    print(const.color.fail("Maintenance"))
end

function controller.black()
    print(const.color.fail("Maintenance"))
end

function controller.spam()
    print(const.color.fail("Maintenance"))
end

function controller.startspam()
    print(const.color.fail("Maintenance"))
end

function controller.autocv()
    print(const.color.fail("Maintenance"))
end

function controller.fcv()
    print(const.color.fail("Maintenance"))
end

function controller.wd(amount)
    print(const.color.fail("Maintenance"))
end

function controller.depo(amount)
    print(const.color.fail("Maintenance"))
end


function utils.xyToIndex(x, y)
    return y * 100 + x
end


-- AUTO SECTION
-- Auto Dialog
local function autoDialogHandlerPacket(type, packet)
    if packet:find("action|dialog_return\ndialog_name|autoDialog") then

        if packet:find("buttonClicked|hrefAutoPullDialog") then
            dialog.autoPull()
        end
    end
end

-- AutoPull

local function autoPullHandlerPacket(type, packet)

    if packet:find("action|dialog_return\ndialog_name|autoPullDialog") then
        local enableWebhook = packet:match("enableWebhookAutoPull|(%d)")
        local discordId = packet:match("discordIdInput|([^\r\n|]+)")
        
        if tonumber(enableWebhook) == 1 then
            config.auto.pull.webhook = 1
        else
            config.auto.pull.webhook = 0
        end

        config.auto.pull.discordId = discordId




        if packet:find("buttonClicked|hrefBlacklistAutoPullDialog") then
            local dialog = {
                "add_label_with_icon|big|" .. const.color.header .. "Blacklisted Player|left|" .. const.itemId.curseWand,
                "add_button|removeAllBlacklist|" .. const.color.fail .. "Remove All|noflags|0|0|",
                getBlacklistDialog(),
                "add_quick_exit",
                "add_button|backToAutoPullDialog|" .. const.color.text .. "Back|noflags|0|0|",
                "end_dialog|blacklistDialog|Close|"
            }

            sendDialog(table.concat(dialog, "\n"))
        end

        if packet:find("buttonClicked|setAutoPullTileBtn") then
            config.auto.pull.setTileStatus = 1
            sendOverlay(const.color.text .. "Click Tile To Set Auto Pull Tile")
        end

        if packet:find("buttonClicked|addBlacklist") then
            local uid = packet:match("buttonClicked|addBlacklist(%d+)")

            for playerUid, playerName in packet:gmatch("(%d+)|([^\r\n|]+)|") do
                if playerUid == uid then
                    local uid = tonumber(uid)
                    config.auto.pull.blacklist[uid] = playerName
                    break
                end
            end

            dialog.autoPull()
        end
        saveConfig()
    end

end

local function autoPullSetTile(pos)

    if config.auto.pull.setTileStatus == 1 then
        config.auto.pull.setTileStatus = 0

        config.auto.pull.x = math.floor(pos.x / 32)
        config.auto.pull.y = math.floor(pos.y / 32)
        sendOverlay(const.color.success .. "Successfully " .. const.color.text .. "Set Auto Pull Tile On (" .. config.auto.pull.x .. ", " .. config.auto.pull.y .. ")")
        SendPacketRaw(true, {
            type = 38,
            netid = utils.xyToIndex(config.auto.pull.x, config.auto.pull.y),
            snetid = -1,
            state = 8,
            extDataSize = 100
        })

        saveConfig()
    end
end

local function autoPullBlacklist(type, packet)

    if packet:find("action|dialog_return\ndialog_name|blacklistDialog") then

        if packet:find("buttonClicked|backToAutoPullDialog") then
            dialog.autoPull()
        end

        if packet:find("buttonClicked|removeBlacklist") then
            local uid = packet:match("buttonClicked|removeBlacklist(%d+)")
            local uid = tonumber(uid)

            config.auto.pull.blacklist[uid] = nil
            local dialog = {
                "add_label_with_icon|big|" .. const.color.header .. "Blacklisted Player|left|" .. const.itemId.curseWand,
                "add_button|removeAllBlacklist|" .. const.color.fail .. "Remove All|noflags|0|0|",
                getBlacklistDialog(),
                "add_quick_exit",
                "add_button|backToAutoPullDialog|" .. const.color.text .. "Back|noflags|0|0|",
                "end_dialog|blacklistDialog|Close|"
            }

            sendDialog(table.concat(dialog, "\n"))
        end

        if packet:find("buttonClicked|removeAllBlacklist") then
            config.auto.pull.blacklist = {}
            local dialog = {
                "add_label_with_icon|big|" .. const.color.header .. "Blacklisted Player|left|" .. const.itemId.curseWand,
                "add_button|removeAllBlacklist|" .. const.color.fail .. "Remove All|noflags|0|0|",
                getBlacklistDialog(),
                "add_quick_exit",
                "add_button|backToAutoPullDialog|" .. const.color.text .. "Back|noflags|0|0|",
                "end_dialog|blacklistDialog|Close|"
            }

            sendDialog(table.concat(dialog, "\n"))
        end

        saveConfig()
    end

end








-- SPIN HANDLER
local function remeNum(number)
    local number = tonumber(number)
    if not number then return "", "" end

    local num1 = math.floor(number / 10)
    local num2 = number % 10
    local sum = num1 + num2
    local result = tostring(sum):sub(-1)

    return result
end

local function qemeNum(number)
    local number = tonumber(number)
    if number == 0 then
        number = 1
    end
    if not number then return "", "" end
    
    local result = (number >= 10) and tostring(number):sub(-1) or tostring(number)
    
    return result
end

local function rules(game, number)
    local lowest1 = "" .. const.color.fail .. ""
    local lowest2 = "`8"
    local middle = "`6"
    local highest2 = "`9"
    local highest1 = "" .. const.color.success .. ""

    
    if game == "reme" then
        local num = tonumber(remeNum(number))
        local remeColors = {
            [0] = highest1,
            [1] = lowest1,
            [2] = lowest1,
            [3] = lowest2,
            [4] = lowest2,
            [5] = middle,
            [6] = middle,
            [7] = highest2,
            [8] = highest2,
            [9] = highest1
        }
        
        if num == 0 then
            return "`^REME " .. remeColors[0] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X3" .. const.color.text .. "] "
        end
        
        return "`^REME " .. remeColors[num] .. num .. " "
    end

    if game == "leme" then
        local num = tonumber(remeNum(number))
        local lemeColors = {
            [0] = highest1,
            [1] = highest1,
            [2] = lowest1,
            [3] = lowest1,
            [4] = lowest2,
            [5] = lowest2,
            [6] = middle,
            [7] = middle,
            [8] = highest2,
            [9] = highest2
        }

        if num == 0 then
            return "" .. const.color.info .. "LEME " .. lemeColors[0] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X4" .. const.color.text .. "] "
        end

        if num == 1 then
            return "" .. const.color.info .. "LEME " .. lemeColors[1] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X3" .. const.color.text .. "] "
        end

        return "" .. const.color.info .. "LEME " .. lemeColors[num] .. num .. " "
    end

    if game == "qeme" then
        local num = tonumber(qemeNum(number))
        local qemeColors = {
            [0] = highest1,
            [1] = lowest1,
            [2] = lowest1,
            [3] = lowest2,
            [4] = lowest2,
            [5] = middle,
            [6] = middle,
            [7] = highest2,
            [8] = highest2,
            [9] = highest1
        }
        
        if num == 0 then
            return const.color.header .. "QEME " .. qemeColors[0] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X3" .. const.color.text .. "] "
        end

        return const.color.header .. "QEME " .. qemeColors[num] .. num .. " "
    end

end


local function spinHandlerPacket(type, packet)  

    if packet:find("action|dialog_return\ndialog_name|spinDialog") then
        local real = tonumber(packet:match("real%|(%d+)"))
        local reme = tonumber(packet:match("reme%|(%d+)"))
        local leme = tonumber(packet:match("leme%|(%d+)"))
        local qeme = tonumber(packet:match("qeme%|(%d+)"))
        local sspin = tonumber(packet:match("sspin%|(%d+)"))
        local lastSpin = tonumber(packet:match("lastSpin%|(%d+)"))

        if real == 0 then
            config.spin.real = 0
        else
            config.spin.real = 1
        end

        if reme == 0 then
            config.spin.reme = 0
        else
            config.spin.reme = 1
        end

        if leme == 0 then
            config.spin.leme = 0
        else
            config.spin.leme = 1
        end    
        
        if qeme == 0 then
            config.spin.qeme = 0
        else
            config.spin.qeme = 1
        end 

        if sspin == 0 then
            config.spin.sspin = 0
        else
            config.spin.sspin = 1
        end

        saveConfig()
    end
end

local function spinHandlerVariant(var, netid)
    
    local fake = "" .. const.color.fail .. "[FAKE]"
    local real = "" .. const.color.success .. "[REAL]"
    
    if var[0] == "OnTalkBubble" and var[2]:find("spun the wheel and got") then
        local is_fake = var[2]:find("<") and var[2]:find(">")
        local prefix = is_fake and fake .. " " or real .. " "
        local prefix = (config.spin.real == 1 and prefix or "")

        local bubble_netid = tonumber(var[1]) or -1

        if bubble_netid == -1 then
            return false
        end
        
        local num_str = var[2]:match("and got (.+)")
        
        if num_str then
            local num = string.gsub(string.gsub(num_str, "!%]", ""), "`", "")
            local onlynumber = string.sub(num, 2)
            local clearspace = string.gsub(onlynumber, " ", "")
            local h = string.gsub(string.gsub(clearspace, "!7", ""), "]", "")
            local num_parsed = tonumber(h)

            local suffix = 
            (config.spin.reme == 1 and rules("reme", num_parsed) or "") ..
            (config.spin.leme == 1 and rules("leme", num_parsed) or "") ..
            (config.spin.qeme == 1 and rules("qeme", num_parsed) or "")

            local mid = (config.spin.sspin == 1 and "" .. const.color.text .. num_parsed or var[2])
            
            if num_parsed then
                SendVariantList({
                    [0] = "OnTalkBubble",
                    [1] = var[1],
                    [2] = prefix .. mid .. " " .. suffix
                })
                return true
            end
        end

    end

    if var[0] == "OnConsoleMessage" and var[1]:find("spun the wheel and got") then
        SendVariantList({
            [0] = "OnConsoleMessage",
            [1] = info.wm .. " " .. var[1] .. " " .. real
        })
        return true
    end
end

-- Wrench Handler
local pendingWrench = {
    netid = nil,
    smodal = false
}


function utils.queueSModal(netid)
    pendingWrench.netid = tonumber(netid)
    pendingWrench.smodal = true
end

function utils.clearQueue()
    pendingWrench.netid = nil
    pendingWrench.smodal = false
end

local function processWrenchQueue()

    if not pendingWrench.smodal then
        return
    end

    utils.wrenchAction(
        "smodal",
        pendingWrench.netid
    )

    utils.clearQueue()
end

local function wrenchHandlerPacket(type, packet)
    if packet:find("action|dialog_return\ndialog_name|wrenchDialog") then
        local smodal = tonumber(packet:match("wrenchSModal|(%d)"))
        local pullText = packet:match("pullText|([^\r\n]+)")
        local kickText = packet:match("kickText|([^\r\n]+)")
        local banText = packet:match("banText|([^\r\n]+)")

        if smodal == 0 then
            config.wrench.smodal = 0
        else
            config.wrench.smodal = 1
        end
        
        config.wrench.text.pull = pullText
        config.wrench.text.kick = kickText
        config.wrench.text.ban = banText

        if packet:find("buttonClicked|wrenchPull") then
            setExclusive(config.wrench, "pull", { "kick", "ban" }, false, "wrench pull")
        elseif packet:find("buttonClicked|wrenchKick") then
            setExclusive(config.wrench, "kick", { "pull", "ban" }, false, "wrench kick")
        elseif packet:find("buttonClicked|wrenchBan") then
            setExclusive(config.wrench, "ban", { "kick", "pull"}, false, "wrench ban")
        end

        saveConfig()
    end

    
    if packet:find("action|wrench\n|netid|") then
        
        local netid =
            tonumber(
                packet:match("|netid|(%d+)")
            )
            
        if not netid then
            return false
        end
        
        local fastAction = false
        
        if config.wrench.pull == 1 then
            fastAction = true
            utils.wrenchAction("pull", netid)
            
        elseif config.wrench.kick == 1 then
            fastAction = true
            utils.wrenchAction("kick", netid)
            
        elseif config.wrench.ban == 1 then
            fastAction = true
            utils.wrenchAction("ban", netid)
        end
        
        if config.wrench.smodal == 1 then
            utils.queueSModal(netid)
            if config.wrench.pull == 1 or config.wrench.kick == 1 or config.wrench.ban == 1 then
                RunThread(function()
                    Sleep(50)
                    processWrenchQueue()
                end)
            else
                processWrenchQueue()
            end
        end

        if fastAction then
            return true
        end
    end

end

local function wrenchHandlerVariant(var, netid)
    

    if var[0] == "OnDialogRequest" and var[1]:find("embed_data|netID|") then
        local netid = tonumber(var[1]:match("embed_data|netID|(%d+)"))

        if netid == GetLocal().netid then
            return false
        else
            for k, v in pairs(config.wrench) do
                if v == 1 then
                    return true
                end
            end

        end
    end

    
    if var[0] == "OnDialogRequest" and var[1]:find("embed_data|userID") and config.wrench.smodal == 1 then
        local wl = tonumber(var[1]:match("staticframe|" .. const.itemId.wl .. "|(%d+)|")) or 0
        local dl = tonumber(var[1]:match("staticframe|" .. const.itemId.dl .. "|(%d+)|")) or 0
        local bglInven = tonumber(var[1]:match("staticframe|" .. const.itemId.bgl .. "|(%d+)|")) or 0
        local bglBank = tonumber(var[1]:match("Blue Gem Locks in the Bank: `$(%d+)``")) or 0
        local bgl = bglInven+bglBank
        local black = tonumber(var[1]:match("staticframe|" .. const.itemId.black .. "|(%d+)|")) or 0
        local champ = tonumber(var[1]:match("staticframe|" .. const.itemId.champagne .. "|(%d+)|")) or 0
        local name = var[1]:match("big|(.+)'s Inventory``") or "Unknown"
    
        local total =
        wl +
        (dl * 100) +
        (bgl * 10000) +
        (black * 1000000)

        local locks =
            utils.convertLocksCount(total)

        if locks.wl == 0 and locks.dl == 0 and locks.bgl == 0 and locks.bgl == 0 then
            sendOverlay("`0MISKUY DIE KGK ADA WL 1 PUN")
        else
            print(info.wm .. " " .. name .. " `aBLACK: " .. locks.black .. " `eBGL: " .. locks.bgl .. " `1DL: " .. locks.dl .. " `9WL: " .. locks.wl .. " `rCHAMPAGNE: " .. champ)
            sendOverlay(name .. " `aBLACK: " .. locks.black .. " `eBGL: " .. locks.bgl .. " `1DL: " .. locks.dl .. " `9WL: " .. locks.wl .. " `rCHAMPAGNE: " .. champ)
        end

        utils.clearQueue()

        return true

    end

end


local function wm(var)
    if var[0] == "OnConsoleMessage" and not var[1]:find("spun the wheel and got") then
        print(info.wm .. " " .. var[1])

        return true
    end

    if var[0] == "OnDialogRequest" and not var[1]:find("embed_data|netID|") and not var[1]:find("embed_data|userID|") then
        local dialog = {}

        for line in var[1]:gmatch("[^\r\n]+") do
            table.insert(dialog, line)
        end

        sendDialog(table.concat(dialog, "\n"))

        return true
    end
end



local function execute()

    loadConfig()

    local infoUrl = "https://raw.githubusercontent.com/Lawvy3/Proxy-Helper-Creative-PS/refs/heads/main/radiant/bothaxPC/info.txt"

    local res = MakeRequest(infoUrl, "GET").content

    for line in res:gmatch("[^\r\n]+") do
        local key, value = line:match("([^|]+)|(.+)")
            
        if key and value then
            info[key] = value
        end
    end
    if version == info.version then
        AddHook("OnSendPacket", "wrenchHandler", wrenchHandlerPacket)
        AddHook("OnVariant", "wrenchHandler", wrenchHandlerVariant)
        AddHook("OnSendPacket", "spinHandler", spinHandlerPacket)
        AddHook("OnVariant", "spinHandler", spinHandlerVariant)
        AddHook("OnSendPacket", "commandHandler", commandHandler)
        AddHook("OnVariant", "watermark", wm)
        AddHook("OnVariant", "playerWrench", playerWrench)
        AddHook("OnSendPacket", "autoDialogHandler", autoDialogHandlerPacket)
        AddHook("OnSendPacket", "autoPullHandler", autoPullHandlerPacket)
        AddHook('OnWorldTouch', 'autoPullHander', autoPullSetTile)
        AddHook("OnSendPacket", "autoPullBlackListHandler", autoPullBlacklist)

        print("" .. const.color.text .. "Registering Commands...")
        Sleep(500)

        registerCommand("Info", "/proxy", "Shows Proxy Commands List", const.itemId.holographicSign)
        registerCommand("Info", "/news", "Shows Radiant Proxy News Update")
        registerCommand("Info", "/gazette", "Shows CreativePS Gazette")

        registerCommand("Main Features", "/option", "Opens Many Features Options Dialog [alias: /options]", const.itemId.txmom)
        registerAlias("/options", "/option")
        registerCommand("Main Features", "/auto", "Opens Auto Pull Dialog Settings")
        registerCommand("Main Features", "/autopull", "Opens Auto Pull Settings Dialog")
        registerCommand("Main Features", "/logs", "Opens Action Dialog Like Roulette, Drop Etc [alias: /log]")
        registerAlias("/log", "/logs")
        registerCommand("Main Features", "/calc", "Solve Simple Math Problem [alias: /calcu]", nil, true, "<Math Problem>")
        registerAlias("/calcu", "/calc")
        registerCommand("Main Features", "/buychamp", "Auto Buy Champ When Wrenching Telephone [default: buy using dl] [disabling fast cv]")
        registerCommand("Main Features", "/spam", "Opens Spam Dialog Menu")

        registerCommand("Convertion", "/blue", "Convert Black Gem Lock To Blue Gem Lock [alias: /bgl]", const.itemId.telephone)
        registerAlias("/bgl", "/blue")
        registerCommand("Convertion", "/black", "Convert Blue Gem Lock To Black Gem Lock")
        registerCommand("Convertion", "/autocv", "Auto Cv Any Locks To Higher Currency When Collected Locks & Near Telephone")
        registerCommand("Convertion", "/fcv", "Fast Cv DL To Blue Gem Lock When Wrenching Telephone [alias: /fastcv]")
        registerAlias("/fastcv", "/fcv")
        registerCommand("Convertion", "/wd", "Withdraw Bgl From Bank [note: /wd all for withdraw all locks from banks]", nil, true , "<amount>")
        registerCommand("Convertion", "/depo", "Deposit Bgl To Bank [note: /depo all for depo all locks to banks] [alias: /dp]", nil, true , "<amount>")
        registerAlias("/dp", "/depo")

        registerCommand("Roulette", "/spin", "Opens Spin Settings Dialog [alias: /roulette, /game]", const.itemId.roulette)
        registerAlias("/roulette", "/spin")
        registerAlias("/game", "/spin")
        registerCommand("Roulette", "/real", "Enable Real or Fake Spin Detector")
        registerCommand("Roulette", "/reme", "Enable Reme Game")
        registerCommand("Roulette", "/leme", "Enable leme Game")
        registerCommand("Roulette", "/qeme", "Enable qeme Game")
        registerCommand("Roulette", "/sspin", "Enable Short Spin Roulette Wheel")
        
        registerCommand("Wrench", "/smodal", "Show Modal Player When Pull [alias: /showmodal]", const.itemId.wrench)
        registerAlias("/showmodal", "/smodal")
        registerCommand("Wrench", "/wrm", "Opens Wrench Settings Dialog [alias: /wrenchmode]")
        registerAlias("/wrenchmode", "/wrm")
        registerCommand("Wrench", "/wrp", "Enable Wrench Pull / Fast Pull Mode [alias: /wrpull]")
        registerAlias("/wrpull", "/wrp")
        registerCommand("Wrench", "/wrk", "Enable Wrench Kick / Fast Kick Mode [alias: /wrkick]")
        registerAlias("/wrkick", "/wrk")
        registerCommand("Wrench", "/wrb", "Enable Wrench Ban / Fast Ban Mode [alias: /wrban]")
        registerAlias("/wrban", "/wrb")

        registerCommand("Drop", "/w", "Drop World Lock [ex: /w 9]", const.itemId.dl, true, "<amount>")
        registerCommand("Drop", "/d", "Drop Diamond Lock [ex: /d 9]", const.itemId.dl, true, "<amount>")
        registerCommand("Drop", "/b", "Drop Blue Gem Lock [ex: /b 9]", const.itemId.dl, true, "<amount>")
        registerCommand("Drop", "/bb", "Drop Black Gem Lock [ex: /b 9]", const.itemId.dl, true, "<amount>")

        registerCommand("Shortcut", "/res", "Respawn", const.itemId.superSpeed)
        registerCommand("Shortcut", "/relog", "Rejoin World / Relog World", const.itemId.superSpeed)
        registerCommand("Shortcut", "/exit", "Exit World", const.itemId.superSpeed)
        registerCommand("Shortcut", "/startspam", "Start Spam Shortcut [alias: /sspam]")
        registerAlias("/sspam", "/startspam")
        registerCommand("Shortcut", "/ap", "Enable Auto PUll Shortcut")
        registerCommand("Shortcut", "/setap", "Set Auto Pull Tile On Current Position")

    if config.auto.pull.status == 1 then
        StartAutoPullThread()
    else
        StopAutoPullThread()
    end
        -- controller.news()
    else
        print("" .. const.color.fail .. "Please Update Proxy")
    end
end

execute()
