local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local player = Players.LocalPlayer
local WindUI
local Const = {
    Config = {
        HubName = "Everzt",
        Author = "xia0nai",
        Folder = "Everzt",
        Version = "0.0.1-alpha.1",
        MapName = "GEVRIEL OBSTACLE"
    },
    WindUI = {
        Theme = "Crimson",
        Icon = "https://raw.githubusercontent.com/xia0nai/Everzt/refs/heads/master/ic_everzt_logo.svg",
        Version = "1.6.66",
        Scale = {
            Small = 0.7,
            Default = 0.8,
            Normal = 1,
            Large = 1.1
        }
    }
}

do
    if cloneref(game:GetService("RunService")):IsStudio() then
        WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
    else
        WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
                                             Const.WindUI.Version .. "/main.lua"))()
    end
end

-- */ Show Notification init /* --
function showNotif(section, msg)
    return WindUI:Notify({
        Title = section,
        Content = msg,
        Duration = 3,
        Icon = "lucide:info"
    })
end
-- */ END Show Notification init /* --

-- */ Welcome notification /* --
if player then
    showNotif("Welcome!", "Hello " .. player.Name .. "!")
end
-- */ END Welcome notification /* --

-- */  Window /* --
local Window = WindUI:CreateWindow({
    Title = Const.Config.HubName,
    -- Author = "by " .. Const.Config.Author,
    Folder = Const.Config.Folder,
    Icon = "sfsymbols:mountain2Circle",
    Theme = Const.WindUI.Theme,
    NewElements = true,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    OpenButton = {
        Title = Const.Config.HubName,
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.8,
        Color = ColorSequence.new( -- gradient
        Color3.fromHex("#831843"), Color3.fromHex("#4c0519"))
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default" -- Default or Mac
    },
    User = {
        Enabled = true
    }
})
Window:SetUIScale(Const.WindUI.Scale.Default)

-- */ Window Tag /* --
do
    Window:Tag({
        Title = "v" .. Const.Config.Version,
        Icon = "github",
        Color = Color3.fromHex("#262021"),
        Border = true
    })

    Window:Tag({
        Title = Const.Config.MapName,
        Color = Color3.fromHex("#881337"),
        Border = true
    })
    showNotif("WindUI", "Loaded WindUI v" .. Const.Config.Version .. "!")
end
-- */ END Window Tag /* --

-- */ Init Tabs /* --
local Tabs = {
    AboutTab = Window:Tab({
        Title = "About",
        Icon = "lucide:info"
    }),
    MainTab = Window:Tab({
        Title = "Main",
        Icon = "lucide:house"
    }),
    SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "lucide:settings"
    })
}
-- */ END Init Tabs /* --

-- */ Teleport Tab /* --
do
    local ListCheckpoints = {"Cp 00;26.9227;596.1063;-361.6679;-3.1416;-0.0165;3.1416",
                            "Cp 01;49.9158;700.2957;317.4852;3.1416;-0.0296;3.1416",
                            "Cp 02;-230.7647;850.0650;845.7830;-3.1416;1.5248;3.1416",
                            "Cp 03;-636.3995;960.0650;424.9523;0.0000;0.0728;-0.0000",
                            "Cp 04;-490.1528;1515.0648;113.3070;3.1416;-0.1364;-3.1416",
                            "Cp 05;-747.0215;1908.0649;982.6733;3.1416;0.0030;-3.1416",
                            "Cp 06;-762.2143;2062.0647;1534.1711;3.1416;-0.0582;-3.1416",
                            "Cp 07;-1154.6451;2020.0649;2527.0024;-3.1416;0.3352;-3.1416",
                            "Cp 15;-8595.2197;3104.2107;2195.7993;-0.0000;1.2150;0.0000",
                            "Summit;-8984.4326;3726.0884;1299.0790;-0.0000;-0.3237;-0.0000"}
    local ListCoordString = ""
    local TeleportSection = Tabs.MainTab:Section({
        Title = "Teleport",
        Box = true,
        Opened = true
    })

    local SavedCoords = {}
    local selectedCheckpoint = nil

    local function CFrameToString(key, cf)
        local x, y, z = cf.Position.X, cf.Position.Y, cf.Position.Z
        local rx, ry, rz = cf:ToEulerAnglesXYZ()

        return string.format("%s;%.4f;%.4f;%.4f;%.4f;%.4f;%.4f", key, x, y, z, rx, ry, rz)
    end

    local function StringToCFrame(str)
        local parts = {}
        for value in str:gmatch("[^;]+") do
            table.insert(parts, value)
        end

        local key = parts[1]
        local x, y, z, rx, ry, rz = tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]), tonumber(parts[5]),
            tonumber(parts[6]), tonumber(parts[7])
        local pos = Vector3.new(x, y, z)
        local rot = Vector3.new(rx, ry, rz)

        cframe = CFrame.new(pos) * CFrame.fromEulerAnglesXYZ(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
        return key, cframe
    end

    local function SaveCoordinate(key)
        local character = player.Character
        if not character then
            return false
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return false
        end

        SavedCoords[key] = rootPart.CFrame
        return true
    end

    local function GetCoordinate(key)
        return SavedCoords[key]
    end

    local function TeleportTo(key)
        local cframe = SavedCoords[key]
        if not cframe then
            return
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = cframe
            showNotif("Teleported", "Teleported to '" .. key .. "'")
        end
    end

    local function GetCoordinateKeys()
        local keys = {}
        for key, _ in pairs(SavedCoords) do
            table.insert(keys, key)
        end
        table.sort(keys) -- opsional, biar urut alfabetis
        return keys
    end

    for idx, value in ipairs(ListCheckpoints) do
        local key, cframe = StringToCFrame(value)
        SavedCoords[key] = cframe
    end

    local CheckPointDropdown = TeleportSection:Dropdown({
        Title = "Checkpoint",
        Values = GetCoordinateKeys(),
        Callback = function(selected)
            selectedCheckpoint = selected
        end
    })

    local TPButton = TeleportSection:Button({
        Title = "Teleport",
        Callback = function()
            if selectedCheckpoint then
                TeleportTo(selectedCheckpoint)
            end
        end
    })
end
-- */ END Teleport Tab /* --

-- */ Settings Tab /* --
do
    local MiscSection = Tabs.SettingsTab:Section({
        Title = "Miscellaneous",
        Box = true,
        Opened = true
    })

    -- */ Anti-AFK init /* --
    local AntiAFK = {}
    AntiAFK.Enabled = false
    AntiAFK.IdleThreshold = 15 * 60
    local lastInput = tick()
    local heartbeatConn = nil
    local inputConns = {}

    local function resetTimer()
        lastInput = tick()
    end

    function AntiAFK.Toggle(state)
        AntiAFK.Enabled = state
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
        for _, conn in ipairs(inputConns) do
            conn:Disconnect()
        end
        inputConns = {}
        if not state then
            return
        end
        lastInput = tick()
        table.insert(inputConns, UserInputService.InputBegan:Connect(resetTimer))
        table.insert(inputConns, UserInputService.InputChanged:Connect(resetTimer))

        task.spawn(function()
            while AntiAFK.Enabled do
                task.wait(50)
                if AntiAFK.Enabled and tick() - lastInput >= AntiAFK.IdleThreshold then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    lastInput = tick()
                end
            end
        end)
    end

    local AFKToggle = MiscSection:Toggle({
        Title = "Anti-AFK",
        Type = "Checkbox",
        Value = true, -- default value
        Flag = "Settings_Misc_AntiAFK",
        Callback = function(state)
            AntiAFK.Toggle(state)
            if state then
                showNotif("Settings changes", "Anti-AFK enabled")
            else
                showNotif("Settings changes", "Anti-AFK disabled")
            end
        end
    })
    -- */ END Anti-AFK init /* --
end
-- */ END Settings Tab /* --
