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
        MapName = "Mount Soreya"
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
        WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Const.WindUI.Version .. "/main.lua"))()
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
    local ListCheckpoints = {"Cp 01;463.7599;444.9600;-8945.7236;-0.0000;0.0000;-0.0000",
                             "Cp 02;449.5000;489.3040;-9568.0000;0.0000;0.0000;0.0000",
                             "Cp 03;398.2754;629.3039;-10113.5293;0.0000;0.0000;0.0000",
                             "Cp 04;486.5005;637.3039;-10681.0000;-3.1416;-1.4921;-3.1416",
                             "Cp 05;1088.5012;725.3039;-11156.4990;-0.0000;0.0000;-0.0000",
                             "Cp 06;973.6875;733.3039;-11808.9043;-0.0000;1.4402;0.0000",
                             "Cp 07;390.2701;885.3039;-11839.1084;0.0000;1.5191;-0.0000",
                             "Cp 08;-325.8742;849.3039;-11738.4873;0.0000;1.5177;-0.0000",
                             "Cp 09;-869.7002;853.3039;-11737.4004;-0.0000;1.5447;0.0000",
                             "Cp 10;-1281.5297;857.3039;-12093.6221;-0.0000;0.0000;-0.0000",
                             "Cp 11;-1310.5959;889.3039;-12834.4150;-0.0000;1.5532;0.0000",
                             "Cp 12;-2326.6870;913.3039;-12672.8594;3.1416;-0.0085;-3.1416",
                             "Cp 13;-2309.0996;917.3039;-11856.9004;-3.1416;-0.0000;-3.1416",
                             "Cp 14;-2444.7588;961.3039;-11057.5000;-0.0000;1.5532;0.0000",
                             "Cp 15;-3480.1536;981.1478;-11014.8867;-0.0000;1.5621;0.0000",
                             "Cp 16;-4225.6997;1001.3039;-11018.0068;3.1416;1.5614;-3.1416",
                             "Cp 17;-4650.5503;1081.3037;-11665.2578;-3.1416;1.5360;3.1416",
                             "Cp 18;-5543.9072;1101.3037;-11651.7510;-0.0000;1.5615;0.0000",
                             "Cp 19;-6766.4370;1097.3037;-11512.1367;-3.1416;0.0261;3.1416",
                             "Cp 20;-6761.0996;1102.5223;-10802.5566;3.1416;0.0093;-3.1416",
                             "Summit;-6764.0317;1321.1573;-10100.9102;-3.1416;0.0500;-3.1416"}
    local ListSpotCore = {"Spot 1;-6891.1274;1327.9509;-9796.7715;-3.1416;-1.2807;-3.1416",
                          "Spot 2;-8139.1079;1239.3344;-6196.1689;3.1416;-0.0022;-3.1416",
                          "Spot Core;-9050.6523;1250.8180;-6508.4370;-0.0000;0.1158;0.0000"}
    local SavedCoords = {}
    local CoreCoords = {}
    local selectedCheckpoint = nil
    local selectedCoreSpot = nil

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

    local function TeleportTo(lst, key)
        local cframe = lst[key]
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

    local function GetCoordinateKeys(lst)
        local keys = {}
        for key, _ in pairs(lst) do
            table.insert(keys, key)
        end
        table.sort(keys) -- opsional, biar urut alfabetis
        return keys
    end

    for idx, value in ipairs(ListCheckpoints) do
        local key, cframe = StringToCFrame(value)
        SavedCoords[key] = cframe
    end

    for idx, value in ipairs(ListSpotCore) do
        local key, cframe = StringToCFrame(value)
        CoreCoords[key] = cframe
    end

    local TeleportSection = Tabs.MainTab:Section({
        Title = "Teleport To Checkpoint",
        Box = false,
        Opened = true
    })
    local TeleportSpotSection = Tabs.MainTab:Section({
        Title = "Teleport to Spot Fishing",
        Box = false,
        Opened = false
    })

    -- */ Teleport Checkpoint /* --
    local CheckPointDropdown = TeleportSection:Dropdown({
        Title = "Checkpoint",
        Values = GetCoordinateKeys(SavedCoords),
        Callback = function(selected)
            selectedCheckpoint = selected
        end
    })

    local TPButton = TeleportSection:Button({
        Title = "Teleport",
        Callback = function()
            if selectedCheckpoint then
                TeleportTo(SavedCoords, selectedCheckpoint)
            end
        end
    })

    -- */ Teleport Checkpoint /* --
    local SpotFishingDropdown = TeleportSpotSection:Dropdown({
        Title = "Spot Fishing",
        Values = GetCoordinateKeys(CoreCoords),
        Callback = function(selected)
            selectedCoreSpot = selected
        end
    })

    local TPSpotButton = TeleportSpotSection:Button({
        Title = "Teleport",
        Callback = function()
            if selectedCoreSpot then
                TeleportTo(CoreCoords, selectedCoreSpot)
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
