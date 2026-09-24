local VERSION = "0.1.0"
local HUB_NAME = "Everzt"
local games = {
    [10547430486] = "https://raw.githubusercontent.com/xia0nai/Everzt/refs/heads/master/Soreya/loader.lua",
    [10767019164] = "https://raw.githubusercontent.com/xia0nai/Everzt/refs/heads/master/Gevriel/loader.lua",
}
local universeId = game.GameId
local placeId = game.PlaceId
local scriptURL = games[universeId]
print(string.format("[%s v%s] PlaceId: %d | UniverseId: %d", HUB_NAME, VERSION, placeId, universeId))
if scriptURL then
    print(string.format("[%s] Game supported! UniverseId: %d", HUB_NAME, universeId))
    print(string.format("[%s] Loading script...", HUB_NAME))
    local ok, err = pcall(function()
        loadstring(game:HttpGet(scriptURL))()
    end)
    if not ok then
        warn(string.format("[%s] Gagal load script: %s", HUB_NAME, tostring(err)))
    end
else
    local msg =
        string.format("\n[%s] Game belum didukung!\nPlaceId: %d\nUniverseId: %d!", HUB_NAME, placeId, universeId)
    warn(msg)
    print(msg)
end
