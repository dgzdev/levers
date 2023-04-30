local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Bindables = Util.Bindables

local function GetPrompts(): {[number]: ProximityPrompt}
    local Childrens = Workspace:GetDescendants()
    local Prompts = {}
    for i,v in pairs(Childrens) do
        if v:IsA("ProximityPrompt") == true then
            table.insert(Prompts, v)
        end
    end
    return Prompts
end

local function PrepareProximity(Prompt)
    local Hightlight = Instance.new("Highlight", Prompt)
    if Prompt:FindFirstChild("Prompt_Outline") then return end
    Hightlight.Name = "Prompt_Outline"

    local Settings = {
        FillTransparency = 1,
        OutlineTransparency = 1,
        OutlineColor = Color3.fromRGB(255, 222, 189),
        Adornee = Prompt:FindFirstAncestorWhichIsA("Model"),
    }

    for Name, Value in pairs(Settings) do
        Hightlight[Name] = Value
    end
end

for _, Prompt in ipairs(GetPrompts()) do
    PrepareProximity(Prompt)
end
Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        PrepareProximity(descendant)
    end
end)

local function ProximityPromptAppeared(
    ProximityPrompt: ProximityPrompt,
    Player: Player
)

    local Prompt_Outline = ProximityPrompt:FindFirstChild("Prompt_Outline")
    if Prompt_Outline then
        task.spawn(function()
            TweenService:Create(Prompt_Outline, TweenInfo.new(0.5), {
                OutlineTransparency = 0,
            }):Play()
        end)
    end
end

local function ProximityPromptDisappeared(
    ProximityPrompt: ProximityPrompt,
    Player: Player
)
    local Prompt_Outline = ProximityPrompt:FindFirstChild("Prompt_Outline")
    if Prompt_Outline then
        task.spawn(function()
            TweenService:Create(Prompt_Outline, TweenInfo.new(0.5), {
                OutlineTransparency = 1,
            }):Play()
        end)
    end
end

ProximityPromptService.PromptShown:Connect(ProximityPromptAppeared)
ProximityPromptService.PromptHidden:Connect(ProximityPromptDisappeared)
ProximityPromptService.MaxPromptsVisible = 1

local Prompts = {}

return Prompts