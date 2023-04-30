local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- # Modules
local ProfileService = require(ServerScriptService:WaitForChild("ProfileService"))
local Runner = require(script:WaitForChild("Runner"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local Profiles = require(ReplicatedStorage:WaitForChild("Profiles"))
local ProfileStore = ProfileService.GetProfileStore("Player_Data", {})

local Storage = {}
local Bindables = Util.Bindables

local function PlayerAdded(player: Player)
    local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId) -- GDPR compliance
        profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
        profile:ListenToRelease(function()
            Storage[player] = nil
            Profiles[player] = nil
            player:Kick()
        end)
        if player:IsDescendantOf(Players) == true then
            Storage[player] = profile
            Profiles[player] = profile.Data
            Bindables.ProfileLoad:Fire(player, profile.Data)
        else
            profile:Release()
        end
    else
        player:Kick()
    end

end

local function PlayerLeft(Player: Player)
    Profiles[Player] = nil
    if Storage[Player] ~= nil then
        Storage[Player]:Release()
    end
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerLeft)