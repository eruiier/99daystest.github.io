local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Window = WindUI:CreateWindow({
    Folder = "Ringta Scripts",
    Title = "RINGTA SCRIPTS",
    Icon = "star",
    Author = "RINGTA and BUBLIK6241",
    Theme = "Dark",
    Size = UDim2.fromOffset(500, 350),
    HasOutline = true,
})

Window:EditOpenButton({
    Title = "Open RINGTA SCRIPTS",
    Icon = "pointer",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(200, 0, 255), Color3.fromRGB(0, 200, 255)),
    Draggable = true,
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "star" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "rocket" }),
    Bring = Window:Tab({ Title = "Bring Items", Icon = "package" }),
    Hitbox = Window:Tab({ Title = "Hitbox", Icon = "target" }),
    AutoDays = Window:Tab({ Title = "Auto days", Icon = "sun" }),
    KillAll = Window:Tab({ Title = "Kill All Mobs", Icon = "skull" }),
    Misc = Window:Tab({ Title = "Misc", Icon = "tool" }),
    Esp = Window:Tab({ Title = "Esp", Icon = "eye" }),
    Credits = Window:Tab({ Title = "Credits", Icon = "award" })
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().KillAuraActive = false
getgenv().KillAuraRadius = 100

local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982",
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ToolDamageObject = RemoteEvents:WaitForChild("ToolDamageObject")
local EquipItemHandle = RemoteEvents:WaitForChild("EquipItemHandle")
local UnequipItemHandle = RemoteEvents:WaitForChild("UnequipItemHandle")

local function getAnyToolWithDamageID()
    local inventory = LocalPlayer:FindFirstChild("Inventory")
    if not inventory then return nil, nil end
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then
        EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

Tabs.KillAll:Toggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(state)
        getgenv().KillAuraActive = state
    end
})

Tabs.KillAll:Slider({
    Title = "Kill Aura Radius",
    Step = 1,
    Value = {Min = 10, Max = 150, Default = 100},
    Callback = function(val)
        getgenv().KillAuraRadius = val
    end
})

task.spawn(function()
    while true do
        if getgenv().KillAuraActive then
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tool, damageID = getAnyToolWithDamageID()
                if tool and damageID then
                    equipTool(tool)
                    for _, mob in ipairs(Workspace:WaitForChild("Characters"):GetChildren()) do
                        if mob:IsA("Model") then
                            local part = mob:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - hrp.Position).Magnitude <= getgenv().KillAuraRadius then
                                pcall(function()
                                    ToolDamageObject:InvokeServer(
                                        mob,
                                        tool,
                                        damageID,
                                        CFrame.new(part.Position)
                                    )
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
