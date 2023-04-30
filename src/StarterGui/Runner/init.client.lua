local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
-- # Local
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- # Auxilary
local GetDescendantsOf = function(Instance: Instance, ClassName: string)
    local Descendants = Instance:GetDescendants()
    local Filtered = {}
    for i,v in pairs(Descendants) do
        if v:IsA(ClassName) == true then
            table.insert(Filtered, v)
        end
    end
    return Filtered
end

-- # Variables
local Guis = GetDescendantsOf(PlayerGui, "ScreenGui") :: {[number]: ScreenGui}

-- # Functions
local function GetGui(Name: string)
    for i,v in pairs(Guis) do
        if v.Name == Name then
            return v
        end
    end
end

local function SetAttributes(Gui: ScreenGui)
    local Attributes = Gui:GetAttributes()
    for i,v in pairs(Attributes) do
        Gui[i] = v
    end
end

for _, ScreenGui in ipairs(Guis) do
    UserInputService.MouseIconEnabled = false
    SetAttributes(ScreenGui)
end