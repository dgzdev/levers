local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Runner = {}

-- # Modules
local Util = require(ReplicatedStorage.Util)

local RoomPosition = CFrame.new(0,0,0)
local LastRoomName = "NULL"
local CurrentRoom = nil
local GeneratedRooms = {}

-- # Variables
local RoomFolder = ReplicatedStorage:WaitForChild("Rooms") :: Folder
local Rooms = ReplicatedStorage:WaitForChild("Rooms"):GetChildren() :: {Model}

-- # Auxiliar Functions
local GetAllOf = function(Instance: Instance, Name: string)
    local Children = Instance:GetDescendants()
    local Instances = {}

    for i,v in pairs(Children) do
        if v.Name == Name or v.Name:find(Name) then
            table.insert(Instances, v)
        end
    end

    return Instances
end

-- # Functional
function Runner:LoadCharacter(Player: Player)
    Player:LoadCharacter()

    local Character = Player.Character or Player.CharacterAdded:Wait()
    local InitialRoom = RoomFolder:WaitForChild("Initial")

    InitialRoom.Parent = Workspace.Rooms
    InitialRoom:PivotTo(RoomPosition)

    local Elevator = InitialRoom:WaitForChild("Elevator") :: Model
    local Pos = Elevator:GetPivot()
    Character:PivotTo(CFrame.new(Pos.Position))

    GeneratedRooms[#GeneratedRooms + 1] = InitialRoom
    CurrentRoom = InitialRoom

    Player:SetAttribute("Level", 1)
end

function Runner.Prepare()
    Players.PlayerAdded:Connect(function(Player: Player)
        Runner:LoadCharacter(Player)
    end)
end
function Runner.GetRoom(Player: Player)
    local Randomizer = Random.new()
    local ValidRoom = false
    local Room

    repeat
        local RoomNumber = Randomizer:NextInteger(1, #Rooms)
        Room = Rooms[RoomNumber]:Clone() :: Model

        if Room.Name == "Initial" then
            continue
        end
        if Room.Name == LastRoomName then
            continue
        end
        
        ValidRoom = true
        LastRoomName = Room.Name
    until ValidRoom == true

    local AmountOfLevers = 1
    local LeversOfRoom = Room:WaitForChild("Levers"):GetChildren()

    for i = 1, AmountOfLevers, 1 do
        local LeverNumber = Randomizer:NextInteger(1, #LeversOfRoom)
        local Lever = LeversOfRoom[LeverNumber] :: Model
        local LeverModel = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Lever"):Clone()
        LeverModel.Parent = Lever
        LeverModel:PivotTo(CFrame.new(Lever:GetPivot().Position))
    end 

    local AllLevelTextLabel = GetAllOf(Room, "LevelTextLabel") :: {TextLabel}
    for _, LevelTextLabel in ipairs(AllLevelTextLabel) do
        LevelTextLabel.Text = tostring(Player:GetAttribute("Level"))
    end

    local LastRoom = GeneratedRooms[#GeneratedRooms] :: Model
    LastRoom:Destroy()
    GeneratedRooms[#GeneratedRooms] = nil
    table.insert(GeneratedRooms, Room)
    CurrentRoom = Room

    Room.Parent = Workspace:WaitForChild("Rooms")
    Room:PivotTo( CFrame.new(RoomPosition.Position) )
    RoomPosition = Room:GetPivot()

    return Room
end

Runner.Prepare()

-- # Proximitys
ProximityPromptService.PromptTriggered:Connect(function(prompt, Player: Player)
    local Event = prompt.ObjectText
    -- # Variables
    local Character = Player.Character
    local Root = Character:WaitForChild("HumanoidRootPart")

    if Event == "NextLevel" then
        -- # Increment Level
        local Level = Player:GetAttribute("Level") :: number
        local NextLevel = Level + 1

        Player:SetAttribute("Level", NextLevel)

        -- # Generate new Room for the Level
        local Room = Runner.GetRoom(Player)

        -- # Teleport Player to the new Room
        local Elevator = Room:WaitForChild("Elevator") :: Model
        local Pos = Elevator:GetPivot()

        Character:PivotTo(CFrame.new(Pos.Position))
    end

    if Event == "LeverPrompt" then
        local State = prompt:GetAttribute("Enabled") or false
        local NewState = not State
        prompt:SetAttribute("Enabled", NewState)

        local NextLevelPrompt = CurrentRoom:FindFirstChild("NextLevelPrompt", true)
        NextLevelPrompt.Enabled = NewState
    end
end)

return Runner