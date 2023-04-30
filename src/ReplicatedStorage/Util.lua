local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bindables = {
    ["ProfileLoad"] = Instance.new("BindableEvent"),
    ["Client"] = Instance.new("BindableEvent")
}

local Util = {}
Util.Bindables = Bindables

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Sender = Shared:WaitForChild("Events")

Bindables.Client.Event:Connect(function(...)
    Sender:FireServer(...)
end)

return Util