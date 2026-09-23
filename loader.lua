local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local player = Players.LocalPlayer
local WindUI
local Const = {
    Config = {
        Author = "xia0nai",
        Project = "Everzt",
        Folder = "xia0nai",
    },
    WindUI = {
        Theme = "Crimson"
    }
}

do
    if cloneref(game:GetService("RunService")):IsStudio() then
        WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
    else
        WindUI = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/xia0nai/Everzt/refs/heads/master/dist/main.lua"))()
    end
end

-- */ Show Notification init /* --
function showNotif(ttl, msg)
    return WindUI:Notify({
        Title = ttl,
        Content = msg,
        Duration = 3,
        Icon = "lucide:info"
    })
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = Const.Config.Project,
    Author = "by " .. Const.Config.Author,
    Folder = Const.Config.Folder,
    Icon = "solar:atom-bold-duotone",
    Theme = Const.WindUI.Theme,
    NewElements = true,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    OpenButton = {
        Title = Const.Config.Project,
        Icon = "solar:atom-bold-duotone",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.8,
        Color = ColorSequence.new( -- gradient
        Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f"))
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default" -- Default or Mac
    },
    User = {
        Enabled = true
    }
})
-- */  Scale window  /* --
Window:SetUIScale(.75)
-- */  Tags  /* --
do
    Window:Tag({
        Title = "v0.0.1-alpha.1",
        Icon = "github",
        Color = Color3.fromHex("#1c1c1c"),
        Border = true
    })
end

local Tabs = {
    MainTab = Window:Tab({
        Title = "Main",
        Icon = "lucide:house"
    }),
    SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "lucide:settings"
    })
}

-- */ Instant Fishing init /* --
-- */ TODO: Add a toggle to enable/disable instant fishing
-- */ END Instant Fishing init /* --

-- */ Main Tab /* --
do
    local InstantFishingSection = Tabs.MainTab:Section({
        Title = "Instant Fishing",
        Box = false,
        Opened = true
    })

    local InstantFishingToggle = InstantFishingSection:Toggle({
        Title = "Enable Instant Fishing",
        Value = false,
        Callback = function(state)
            shwNotif("Instant Fishing", state and "Enabled" or "Disabled")
        end
    })
end
-- */ END Main Tab /* --

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
