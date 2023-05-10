local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Events = {}

local EventsFolder = ReplicatedStorage:WaitForChild("Events")

local DarkenLevel = EventsFolder:WaitForChild("DarkenLevel") :: RemoteEvent
local LightenLevel = EventsFolder:WaitForChild("LightenLevel") :: RemoteEvent

function Events.MakeLevelDarken()
    local Dark = Lighting:WaitForChild("Dark")
    TweenService:Create(Lighting, TweenInfo.new(1), Dark:GetAttributes()):Play()

    -- # Clear the Lighting
    for i, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Configuration") then continue end
        v:Destroy()
    end

    local Childs = Dark:GetChildren()
    for i,v in ipairs(Childs) do
        v:Clone().Parent = Lighting
    end
    print("Darken")
end
function Events.MakeLevelLighter()
    local Light = Lighting:WaitForChild("Light")
    TweenService:Create(Lighting, TweenInfo.new(1), Light:GetAttributes()):Play()

    -- # Clear the Lighting
    for i, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Configuration") then continue end
        v:Destroy()
    end

    local Childs = Light:GetChildren()
    for i,v in ipairs(Childs) do
        v:Clone().Parent = Lighting
    end
    print("Lighter")
end

DarkenLevel.OnClientEvent:Connect(function()
    Events.MakeLevelDarken()
end)

LightenLevel.OnClientEvent:Connect(function()
    Events.MakeLevelLighter()
end)

return Events