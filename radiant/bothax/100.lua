local commands = {}
local routes = {}
local controller = {}
local aliases = {}
local info = {}

local version = "1.0.0"

local spin = {
    real = 1,
    leme = 0,
    reme = 1,
    qeme = 0,
    sspin = 0
}

local wrench = {
    mode = 0, -- 0 off. 1 pull. 2 kick. 3 ban
    smodal = 0
}

local const = {
    itemId = {
        bgl = GetItemByName("CreativePS Blue Gem Lock").id,
        black = GetItemByName("CreativePS Black Gem Lock").id,
        dl = GetItemByName("CreativePS Diamond Lock").id,
        wl = GetItemByName("CreativePS World Lock").id,
        roulette = 758,
        wrench = 32,
        holographicSign = 2586,
        superSpeed = 2322
    },
    color = {
        success = "`2",
        fail = "`4",
        header = "`c",
        text = "`0"
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
                                "" .. const.color.text .. "Usage: " .. const.color.header .. "" ..
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
        "add_smalltext|`5Detect Real Or Fake Spin|left",
        "add_checkbox|real|" .. const.color.success .. "Enable " .. const.color.text .. "Real Spin Detector|" .. tostring(spin.real) .. "|",
        "add_smalltext|`5Shows Reme ON Number|left",
        "add_checkbox|reme|" .. const.color.success .. "Enable " .. const.color.text .. "Reme Mode|" .. tostring(spin.reme) .. "|",
        "add_smalltext|`5Shows Leme Number + X|left",
        "add_checkbox|leme|" .. const.color.success .. "Enable " .. const.color.text .. "Leme Mode|" .. tostring(spin.leme) .. "|",
        "add_smalltext|`5Shows Qeme Number|left",
        "add_checkbox|qeme|" .. const.color.success .. "Enable " .. const.color.text .. "Qeme Mode|" .. tostring(spin.qeme) .. "|",
        "add_smalltext|`5Only Shows Number In Spin Bubble|left",
        "add_checkbox|sspin|" .. const.color.success .. "Enable " .. const.color.text .. "Short Spin|" .. tostring(spin.sspin) .. "|",
        "end_dialog|spinDialog|Cancel|Save"
    }

    sendDialog(table.concat(spinDialog, "\n"))
end

function controller.real()
    if spin.real == 0 then
        spin.real = 1
    else
        spin.real = 0
    end
end

function controller.reme()
    if spin.reme == 0 then
        spin.reme = 1
        print("" .. const.color.text .. "Reme Mode " .. const.color.success .. "On")
        say("" .. const.color.text .. "Reme Mode " .. const.color.success .. "On", true)
    else
        spin.reme = 0
        print("" .. const.color.text .. "Reme Mode " .. const.color.fail .. "Off")
        say("" .. const.color.text .. "Reme Mode " .. const.color.fail .. "Off", true)
    end
end

function controller.leme()
    if spin.leme == 0 then
        spin.leme = 1
        print("" .. const.color.text .. "Leme Mode " .. const.color.success .. "On")
        say("" .. const.color.text .. "Leme Mode " .. const.color.success .. "On", true)
    else
        spin.leme = 0
        print("" .. const.color.text .. "Leme Mode " .. const.color.fail .. "Off")
        say("" .. const.color.text .. "Leme Mode " .. const.color.fail .. "Off", true)
    end
end

function controller.qeme()
    if spin.qeme == 0 then
        spin.qeme = 1
        print("" .. const.color.text .. "Qeme Mode " .. const.color.success .. "On")
        say("" .. const.color.text .. "Qeme Mode " .. const.color.success .. "On", true)
    else
        spin.qeme = 0
        print("" .. const.color.text .. "Qeme Mode " .. const.color.fail .. "Off")
        say("" .. const.color.text .. "Qeme Mode " .. const.color.fail .. "Off", true)
    end
end

function controller.sspin()
    if spin.sspin == 0 then
        spin.sspin = 1
        print("" .. const.color.text .. "Short Spin Mode " .. const.color.success .. "On")
        say("" .. const.color.text .. "Short Spin Mode " .. const.color.success .. "On", true)
        
    else
        spin.sspin = 0
        print("" .. const.color.text .. "Short Spin Mode " .. const.color.fail .. "Off")
        say("" .. const.color.text .. "Short Spin Mode " .. const.color.fail .. "Off", true)
    end
end

function controller.wrm()

end

function controller.wrp()

end

function controller.wrk()

end

function controller.wrb()

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
            return " `^REME " .. remeColors[0] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X3" .. const.color.text .. "] "
        end

        return " `^REME " .. remeColors[num] .. num .. " "
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
            return " `5LEME " .. lemeColors[0] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X4" .. const.color.text .. "] "
        end

        if num == 1 then
            return " `5LEME " .. lemeColors[1] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X3" .. const.color.text .. "] "
        end

        return " `5LEME " .. lemeColors[num] .. num .. " "
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
            return " " .. const.color.header .. "QEME " .. qemeColors[0] .. num .. "" .. const.color.text .. "[" .. const.color.success .. "X3" .. const.color.text .. "] "
        end

        return " " .. const.color.header .. "QEME " .. qemeColors[num] .. num .. " "
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
            spin.real = 0
        else
            spin.real = 1
        end

        if reme == 0 then
            spin.reme = 0
        else
            spin.reme = 1
        end

        if leme == 0 then
            spin.leme = 0
        else
            spin.leme = 1
        end    
        
        if qeme == 0 then
            spin.qeme = 0
        else
            spin.qeme = 1
        end 

        if sspin == 0 then
            spin.sspin = 0
        else
            spin.sspin = 1
        end

        if lastSpin == 0 then
            spin.lastSpin = 0
        else
            spin.lastSpin = 1
        end 
        
    end
end

local function spinHandlerVariant(var, netid)

    local fake = "" .. const.color.fail .. "[FAKE]"
    local real = "" .. const.color.success .. "[REAL]"
    
    if var[0] == "OnTalkBubble" and var[2]:find("spun the wheel and got") then
        local is_fake = var[2]:find("<") and var[2]:find(">")
        local prefix = is_fake and fake .. " " or real .. " "
        local prefix = (spin.real == 1 and prefix or "")

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
            (spin.reme == 1 and rules("reme", num_parsed) or "") ..
            (spin.leme == 1 and rules("leme", num_parsed) or "") ..
            (spin.qeme == 1 and rules("qeme", num_parsed) or "")

            local mid = (spin.sspin == 1 and "" .. const.color.text .. num_parsed or var[2])
            
            if num_parsed then
                SendVariantList({
                    [0] = "OnTalkBubble",
                    [1] = var[1],
                    [2] = prefix .. mid .. suffix
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

local function playerWrench(var, netid)

    if wrench.mode == 0 and wrench.smodal == 0 then
        if var[0] == "OnDialogRequest" and var[1]:find("add_button|friend_add|`wAdd as friend``|noflags|0|0|") then
            netid = var[1]:match("embed_data|netID|(%d+)")

            local dialog = {}

            for line in var[1]:gmatch("[^\r\n]+") do
                table.insert(dialog, line)
            end

            table.insert(dialog, 5, "add_button|blacklistViaWrench|" .. const.color.text .. "Blacklist|0|0")
            table.insert(dialog, 6, "add_button|focusViaWrench|" .. const.color.text .. "Lock Focus|0|0")
            table.insert(dialog, 7, "add_button|blockChatViaWrench|" .. const.color.text .. "Block Chat|0|0")

            sendDialog(table.concat(dialog, "\n"))

            return true
        end
    end

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

    local infoUrl = "https://raw.githubusercontent.com/Lawvy3/Proxy-Helper-Creative-PS/refs/heads/main/bothax/radiant%20model/info.txt"

    local res = MakeRequest(infoUrl, "GET").content

    for line in res:gmatch("[^\r\n]+") do
        local key, value = line:match("([^|]+)|(.+)")
            
        if key and value then
            info[key] = value
        end
    end
    if version == info.version then
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

        registerCommand("Wrench", "/wrm", "Opens Wrench Settings Dialog [alias: /wrenchmode]", const.itemId.wrench)
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

