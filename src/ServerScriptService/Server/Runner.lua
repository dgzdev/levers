local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
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

    local Options = {true, false}
    local Option = Options[Randomizer:NextInteger(1, #Options)]
    local IsTheLevelDarker = Option == true

    if IsTheLevelDarker then
        -- # Fires all Clients
        local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DarkenLevel") :: RemoteEvent
        Event:FireAllClients()

        local Childs = Room:GetDescendants()
        for _, Child in ipairs(Childs) do
            if not Child:IsDescendantOf(Room:WaitForChild("Lights")) then continue end

            if Child:IsA("BasePart") and Child.Name:find("Light") then
                Child = Child :: BasePart
                Child.Color = Color3.new(.3,.3,.3)
            end

            if Child:IsA("PointLight") then
                Child = Child :: PointLight
                Child.Enabled = false
            end
        end

        -- # Play the music for the level
        local Music = SoundService:WaitForChild("Musics"):WaitForChild("DarkLevel")
        if Music.IsPlaying == false then
            Music.Volume = 0
            TweenService:Create(Music, TweenInfo.new(1), {Volume = 0.5}):Play()
            Music:Play()
        end

        -- # Stop the music for the light level
        local LightMusic = SoundService:WaitForChild("Musics"):WaitForChild("LightLevel")
        if LightMusic.IsPlaying == true then
            local T = TweenService:Create(LightMusic, TweenInfo.new(1), {Volume = 0})
            T:Play()
            T.Completed:Once(function(playbackState)
                LightMusic:Stop()
            end)
        end
    else
        -- # Fires all Clients
        local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LightenLevel") :: RemoteEvent
        Event:FireAllClients()

        local Childs = Room:GetDescendants()
        for _, Child in ipairs(Childs) do
            if not Child:IsDescendantOf(Room:WaitForChild("Lights")) then continue end

            if Child:IsA("BasePart") and Child.Name:find("Light") then
                Child = Child :: BasePart
                Child.Color = Color3.new(1, 0.949019, 0.843137)
            end

            if Child:IsA("PointLight") then
                Child = Child :: PointLight
                Child.Enabled = true
                Child.Color = Color3.new(1, 0.949019, 0.843137)
                Child.Brightness = .35
                Child.Range = 26
                Child.Shadows = true
            end
        end

        -- # Play the music for the level
        local Music = SoundService:WaitForChild("Musics"):WaitForChild("LightLevel")
        if Music.IsPlaying == false then
            Music.Volume = 0
            TweenService:Create(Music, TweenInfo.new(1), {Volume = 0.5}):Play()
            Music:Play()
        end

        -- # Stop the music for the dark level
        local DarkMusic = SoundService:WaitForChild("Musics"):WaitForChild("DarkLevel")
        if DarkMusic.IsPlaying == true then
            local T = TweenService:Create(DarkMusic, TweenInfo.new(1), {Volume = 0})
            T:Play()
            T.Completed:Once(function(playbackState)
                DarkMusic:Stop()
            end)
        end
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

        local Sound = SoundService:WaitForChild("SFX"):WaitForChild("Elevator"):Clone()
        Sound.Parent = Elevator
        Sound:Play()
        Debris:AddItem(Sound, 1)


        Character:PivotTo(CFrame.new(Pos.Position))
    end

    if Event == "LeverPrompt" then
        local State = prompt:GetAttribute("Enabled") or false
        local NewState = not State
        prompt:SetAttribute("Enabled", NewState)

        local SoundFolder = SoundService:WaitForChild("SFX")
        if NewState == true then
            local Sound = SoundFolder:WaitForChild("SwitchON"):Clone()
            Sound.Parent = prompt.Parent
            Sound:Play()
            Debris:AddItem(Sound, 1)
        elseif NewState == false then
            local Sound = SoundFolder:WaitForChild("SwitchOFF"):Clone()
            Sound.Parent = prompt.Parent
            Sound:Play()
            Debris:AddItem(Sound, 1)
        end

        local NextLevelPrompt = CurrentRoom:FindFirstChild("NextLevelPrompt", true)
        NextLevelPrompt.Enabled = NewState
    end
end)

return Runner