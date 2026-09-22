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
function showNotif(section, msg)
    return WindUI:Notify({
        Title = section,
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

local InstantFishingState = {
    Enabled = false,
    Hooked = false,
    MiniGameHandler = nil,
    OriginalStart = nil,
    OriginalStop = nil,
    LastResolveAt = 0,
    CurrentRod = nil,
    CharacterConnection = nil,
    BackpackConnection = nil
}

local function getCurrentFishingRod()
    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Mechanics") then
                return child
            end
        end
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Mechanics") then
                return child
            end
        end
    end

    return nil
end

local function resolveInstantCatch()
    if not InstantFishingState.Enabled then
        return
    end

    local rod = getCurrentFishingRod()
    if not rod then
        return
    end

    local mechanics = rod:FindFirstChild("Mechanics")
    if not mechanics then
        return
    end

    local status = mechanics:FindFirstChild("Status")
    if not status then
        return
    end

    local fishingActive = status:FindFirstChild("FishingActive")
    local miniGameActive = status:FindFirstChild("MiniGameActive")
    if not fishingActive and not miniGameActive then
        return
    end

    if fishingActive and fishingActive.Value ~= true and miniGameActive and miniGameActive.Value ~= true then
        return
    end

    local now = os.clock()
    if now - (InstantFishingState.LastResolveAt or 0) < 0.12 then
        return
    end

    InstantFishingState.LastResolveAt = now
    InstantFishingState.CurrentRod = rod

    local remotes = mechanics:FindFirstChild("Remotes")
    local miniGameRemote = remotes and remotes:FindFirstChild("MiniGame")
    if not miniGameRemote then
        return
    end

    task.spawn(function()
        if InstantFishingState.MiniGameHandler and InstantFishingState.MiniGameHandler.Stop then
            pcall(function()
                InstantFishingState.MiniGameHandler.Stop()
            end)
        end

        task.wait(0.04)

        pcall(function()
            miniGameRemote:FireServer(true)
        end)
    end)
end

local function attachInstantFishingHooks()
    if InstantFishingState.Hooked then
        return
    end

    local ModulesFolder = ReplicatedStorage:FindFirstChild("Modules")
    local FishingFolder = ModulesFolder and ModulesFolder:FindFirstChild("Fishing")
    if not FishingFolder then
        return
    end

    local MiniGameModule = FishingFolder:FindFirstChild("MiniGameHandler")
    if not MiniGameModule then
        return
    end

    local MiniGameHandler = require(MiniGameModule)
    if not MiniGameHandler then
        return
    end

    InstantFishingState.MiniGameHandler = MiniGameHandler
    InstantFishingState.OriginalStart = MiniGameHandler.Start
    InstantFishingState.OriginalStop = MiniGameHandler.Stop

    MiniGameHandler.Start = function(difficulty, speed, fishData)
        if not InstantFishingState.Enabled then
            if InstantFishingState.OriginalStart then
                return InstantFishingState.OriginalStart(difficulty, speed, fishData)
            end
            return
        end

        task.defer(function()
            resolveInstantCatch()
        end)

        return
    end

    InstantFishingState.Hooked = true
end

local function detachInstantFishingHooks()
    if not InstantFishingState.Hooked or not InstantFishingState.MiniGameHandler then
        return
    end

    if InstantFishingState.OriginalStart then
        InstantFishingState.MiniGameHandler.Start = InstantFishingState.OriginalStart
    end

    if InstantFishingState.OriginalStop then
        InstantFishingState.MiniGameHandler.Stop = InstantFishingState.OriginalStop
    end

    InstantFishingState.MiniGameHandler = nil
    InstantFishingState.OriginalStart = nil
    InstantFishingState.OriginalStop = nil
    InstantFishingState.CurrentRod = nil
    InstantFishingState.Hooked = false
end

local function setInstantFishingEnabled(state)
    InstantFishingState.Enabled = state

    if state then
        attachInstantFishingHooks()
        showNotif("Instant Fishing", "Enabled")
    else
        detachInstantFishingHooks()
        showNotif("Instant Fishing", "Disabled")
    end
end

-- */ Main Tab /* --
do
    local InstantFishingSection = Tabs.MainTab:Section({
        Title = "Instant Fishing",
        Box = false,
        Opened = true
    })

    local InstantFishingToggle = InstantFishingSection:Toggle({
        Title = "Enable Instant Fishing",
        Desc = "Auto-finish the fishing minigame instantly while active.",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            setInstantFishingEnabled(state)
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
