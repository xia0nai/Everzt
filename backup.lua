local InstantFishingState = {
    Enabled = false,
    Hooked = false,
    MiniGameHandler = nil,
    LastResolveAt = 0,
    CurrentRod = nil,
    CharacterConnection = nil,
    BackpackConnection = nil,
    RodConnections = {}
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

local function attachHookToRod(rod)
    if not rod or InstantFishingState.RodConnections[rod] then
        return
    end

    local mechanics = rod:FindFirstChild("Mechanics")
    if not mechanics then
        return
    end

    local remotes = mechanics:FindFirstChild("Remotes")
    local miniGameRemote = remotes and remotes:FindFirstChild("MiniGame")
    if not miniGameRemote then
        return
    end

    local connection = miniGameRemote.OnClientEvent:Connect(function(eventName)
        if not InstantFishingState.Enabled or eventName ~= "Start" then
            return
        end

        if os.clock() - (InstantFishingState.LastResolveAt or 0) < 0.15 then
            return
        end

        InstantFishingState.LastResolveAt = os.clock()
        InstantFishingState.CurrentRod = rod

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
    end)

    InstantFishingState.RodConnections[rod] = connection
end

local function refreshRodHooks()
    local seen = {}

    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Mechanics") then
                seen[child] = true
                attachHookToRod(child)
            end
        end
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Mechanics") then
                seen[child] = true
                attachHookToRod(child)
            end
        end
    end

    for rod, connection in pairs(InstantFishingState.RodConnections) do
        if not seen[rod] and connection then
            connection:Disconnect()
            InstantFishingState.RodConnections[rod] = nil
        end
    end
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
    refreshRodHooks()

    if player.Character then
        InstantFishingState.CharacterConnection = player.CharacterAdded:Connect(function()
            task.defer(refreshRodHooks)
        end)
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        InstantFishingState.BackpackConnection = backpack.ChildAdded:Connect(function()
            task.defer(refreshRodHooks)
        end)
    end

    InstantFishingState.Hooked = true
end

local function detachInstantFishingHooks()
    for _, connection in pairs(InstantFishingState.RodConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    InstantFishingState.RodConnections = {}

    if InstantFishingState.CharacterConnection then
        InstantFishingState.CharacterConnection:Disconnect()
        InstantFishingState.CharacterConnection = nil
    end

    if InstantFishingState.BackpackConnection then
        InstantFishingState.BackpackConnection:Disconnect()
        InstantFishingState.BackpackConnection = nil
    end

    InstantFishingState.MiniGameHandler = nil
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