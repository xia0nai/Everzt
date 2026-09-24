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
