-- =============================================
-- MakerAdminCS - Mobile Friendly Roblox Admin Script
-- GitHub: https://github.com/ypw96hmxqy-cmd/MakerCS
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local noclipping = false
local espEnabled = false
local discoEnabled = false
local walkflingEnabled = false

local flySpeed = 60
local originalWalkSpeed = humanoid.WalkSpeed
local originalJump = humanoid.JumpPower
local connections = {}
local espBillboards = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MakerAdminCS"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
title.Text = "MakerAdminCS"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- X Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -45, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minimizeBtn.Text = "X"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = mainFrame
Instance.new("UICorner", minimizeBtn)

-- Icon Button
local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 80, 0, 80)
iconBtn.Position = UDim2.new(0.5, -40, 0.1, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
iconBtn.Text = "⚙️\nCS"
iconBtn.TextColor3 = Color3.new(1,1,1)
iconBtn.TextScaled = true
iconBtn.Font = Enum.Font.GothamBold
iconBtn.Visible = false
iconBtn.Draggable = true
iconBtn.Parent = screenGui
Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0, 16)

local function updateButton(btn, enabled)
    btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
end

local function createBtn(name, y, varRef, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 55)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        func()
        updateButton(btn, varRef[1])
    end)
    return btn
end

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
end

-- Toggle ESP
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = plr.Character.Head
                bb.Size = UDim2.new(5, 0, 2, 0)
                bb.StudsOffset = Vector3.new(0, 4, 0)
                bb.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", bb)
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Text = plr.Name
                txt.TextColor3 = Color3.fromRGB(255, 85, 85)
                txt.TextStrokeTransparency = 0
                txt.Font = Enum.Font.GothamBold
                txt.TextScaled = true
                bb.Parent = player.PlayerGui
                table.insert(espBillboards, bb)
            end
        end
        notify("ESP", "Enabled")
    else
        for _, bb in ipairs(espBillboards) do bb:Destroy() end
        espBillboards = {}
        notify("ESP", "Disabled")
    end
end

-- Toggle Fly
local function toggleFly()
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bv.Parent = root
        bg.Parent = root
        table.insert(connections, RunService.Heartbeat:Connect(function()
            if not flying then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            local finalDir = dir.Magnitude > 0 and dir.Unit or Vector3.new()
            bv.Velocity = finalDir * flySpeed
            bg.CFrame = cam.CFrame
        end))
        notify("Fly", "Enabled")
    else
        for _, c in ipairs(connections) do if c then c:Disconnect() end end
        connections = {}
        if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
        if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
        notify("Fly", "Disabled")
    end
end

-- Toggle Noclip
local function toggleNoclip()
    noclipping = not noclipping
    notify("Noclip", noclipping and "Enabled" or "Disabled")
end

table.insert(connections, RunService.Stepped:Connect(function()
    if noclipping and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

-- Toggle WalkFling
local function toggleWalkFling()
    walkflingEnabled = not walkflingEnabled
    if walkflingEnabled then
        humanoid.WalkSpeed = 100
        humanoid.JumpPower =