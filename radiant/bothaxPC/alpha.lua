local CONFIG_FILE = "C:/Users/" .. os.getenv("USERNAME") .. "/AppData/Local/Growtopia/scripts/radiantConfig.lua"

local commands = {}
local routes = {}
local controller = {}
local aliases = {}
local info = {}
local utils = {}

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
        superSpeed = 2322
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
            [2] = info.wm .. msg
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

    spin = config.spin
    wrench = config.wrench

    return true
end

local function toggle(tbl, key)

    tbl[key] =
        tbl[key] == 0
        and 1
        or 0

    saveConfig()

    return tbl[key]
end

local function setExclusive(tbl, key, others)
    -- matikan semua dulu
    for _, k in ipairs(others) do
        tbl[k] = 0
    end

    -- toggle key utama
    tbl[key] = (tbl[key] == 1 and 0 or 1)

    saveConfig()
    return tbl[key]
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
    local state =
        toggle(
            config.spin,
            "real"
        )

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Real Mode " ..
        status
    )

    say(
        const.color.text ..
        "Real Mode " ..
        status,
        true)
end

function controller.reme()
    local state =
        toggle(
            config.spin,
            "reme"
        )

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Reme Mode " ..
        status
    )

    say(
        const.color.text ..
        "Reme Mode " ..
        status,
        true)
end

function controller.leme()
    local state =
        toggle(
            config.spin,
            "reme"
        )

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Leme Mode " ..
        status
    )

    say(
        const.color.text ..
        "Leme Mode " ..
        status,
        true)
end

function controller.qeme()
    local state =
        toggle(
            config.spin,
            "qeme"
        )

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Qeme Mode " ..
        status
    )

    say(
        const.color.text ..
        "Qeme Mode " ..
        status,
        true)
end

function controller.sspin()
    local state =
        toggle(
            config.spin,
            "sspin"
        )

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Short Spin Mode " ..
        status
    )

    say(
        const.color.text ..
        "Short Spin Mode " ..
        status,
        true)
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
    local state =
        toggle(
            config.wrench,
            "smodal"
        )

    local status =
        state == 1
        and const.color.success .. " On"
        or const.color.fail .. " Off"

    print(
        const.color.text ..
        "Show Modal Player" ..
        status
    )

    say(
        const.color.text ..
        "Show Modal Player " ..
        status,
        true)
end

function controller.wrp()
    local state = setExclusive(config.wrench, "pull", { "kick", "ban" })

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Wrench Pull Mode " ..
        status
    )

    say(
        const.color.text ..
        "Wrench Pull Mode " ..
        status,
        true)
end

function controller.wrk()
    local state = setExclusive(config.wrench, "kick", { "pull", "ban" })

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Wrench Kick Mode " ..
        status
    )

    say(
        const.color.text ..
        "Wrench Kick Mode " ..
        status,
        true)
end

function controller.wrb()
    local state = setExclusive(config.wrench, "ban", { "pull", "kick" })

    local status =
        state == 1
        and const.color.success .. "On"
        or const.color.fail .. "Off"

    print(
        const.color.text ..
        "Wrench Ban Mode " ..
        status
    )

    say(
        const.color.text ..
        "Wrench Ban Mode " ..
        status,
        true)
end

function controller.w()

end

function controller.d()

end

function controller.b()

end

function controller.bb()

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


        saveConfig()
    end
end

local function wrenchHandlerVariant(var, netid)
    

    if var[0] == "OnDialogRequest" and var[1]:find("'s Inventory") then
        local wl = tonumber(var[1]:match("staticframe|" .. const.itemId.wl .. "|(%d+)|"))
        local dl = tonumber(var[1]:match("staticframe|" .. const.itemId.dl .. "|(%d+)|"))*100
        local bgl = tonumber(var[1]:match("staticframe|" .. const.itemId.bgl .. "|(%d+)|"))*10000
        local black = tonumber(var[1]:match("staticframe|" .. const.itemId.black .. "|(%d+)|"))*1000000
        local champ = tonumber(var[1]:match("staticframe|" .. const.itemId.champagne .. "|(%d+)|"))
    
        print("True")
        return true
    end
    

    if var[0] == "OnDialogRequest" and var[1]:find("embed_data|netID|") then
        local netid = tonumber(var[1]:match("embed_data|netID|(%d+)"))

        if netid == GetLocal().netid then
            return true
        else
            if config.wrench.pull == 1 or config.wrench.ban == 1 or config.wrench.kick == 1 or config.wrench.smodal == 1 then
                if config.wrench.smodal == 1 then
                    SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. netid .. "|\nbuttonClicked|viewinv")

                end
                return true
            end
        end
    end

end

local function playerWrench(var, netid)

    -- if config.wrench.smodal == 0 then
    --     if var[0] == "OnDialogRequest" and var[1]:find("embed_data|netID|") then
    --         netid = var[1]:match("embed_data|netID|(%d+)")

    --         local dialog = {}

    --         for line in var[1]:gmatch("[^\r\n]+") do
    --             table.insert(dialog, line)
    --         end

    --         table.insert(dialog, 3, "add_button|blacklistViaWrench|" .. const.color.text .. "Blacklist|0|0")
    --         table.insert(dialog, 4, "add_button|focusViaWrench|" .. const.color.text .. "Lock Focus|0|0")
    --         table.insert(dialog, 5, "add_button|blockChatViaWrench|" .. const.color.text .. "Block Chat|0|0")

    --         sendDialog(table.concat(dialog, "\n"))

    --         return true
    --     end
    -- end

end


local function wm(var)
    if var[0] == "OnConsoleMessage" and not var[1]:find("spun the wheel and got") then
        print(info.wm .. " " .. var[1])

        return true
    end

    if var[0] == "OnDialogRequest" and not var[1]:find("add_button|friend_add|`wAdd as friend``|noflags|0|0|") then
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

        print("" .. const.color.text .. "Registering Commands...")
        Sleep(500)

        registerCommand("Info", "/proxy", "Shows Proxy Commands List", const.itemId.holographicSign)
        registerCommand("Info", "/news", "Shows Radiant Proxy News Update")
        registerCommand("Info", "/gazette", "Shows CreativePS Gazette")

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


        -- controller.news()
    else
        print("" .. const.color.fail .. "Please Update Proxy")
    end
end

execute()

