-- MakerCS - Working Edition
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/ypw96hmxqy-cmd/MakerCS/main/script.lua"))()

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Simple state tracking
local flyActive = false
local noclipActive = false
local espActive = false
local invisibleActive = false
local discoActive = false
local speedActive = false
local jumpActive = false
local ragdollActive = false

local flyBV = nil
local flyBG = nil
local espList = {}
local discoConn = nil
local normalSpeed = 16
local normalJump = 50
local ragdollParts = {}

local isMobile = UIS.TouchEnabled
local isMM2 = (game.PlaceId == 142823291)

local function notify(msg)
    pcall(function()
        SG:SetCore("SendNotification", {Title = "MakerCS", Text = msg, Duration = 2})
    end)
end

-- ============ FLY ============
local function toggleFly()
    if not root then notify("No character"); return end
    
    if flyActive then
        flyActive = false
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        flyBV = nil
        flyBG = nil
        notify("Fly OFF")
    else
        flyActive = true
        flyBV = Instance.new("BodyVelocity")
        flyBG = Instance.new("BodyGyro")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = root
        flyBG.Parent = root
        
        RS.RenderStepped:Connect(function()
            if not flyActive or not root then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            
            if isMobile then
                local mv = hum.MoveDirection
                if mv.Magnitude > 0.1 then
                    dir = (cam.CFrame.RightVector * mv.X) + (cam.CFrame.LookVector * -mv.Z)
                    dir = dir.Unit
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0,-1,0) end
            else
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0,-1,0) end
            end
            
            if dir.Magnitude > 0 then
                flyBV.Velocity = dir.Unit * 50
            else
                flyBV.Velocity = Vector3.new()
            end
            flyBG.CFrame = cam.CFrame
        end)
        
        notify("Fly ON")
    end
end

-- ============ NOCLIP ============
local function toggleNoclip()
    noclipActive = not noclipActive
    notify(noclipActive and "Noclip ON" or "Noclip OFF")
end

RS.Stepped:Connect(function()
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)

-- ============ ESP ============
local function updateESP()
    if not espActive then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local exists = false
            for _, e in pairs(espList) do
                if e.Adornee == p.Character.Head then exists = true; break end
            end
            if not exists then
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(4,0,2,0)
                bg.AlwaysOnTop = true
                bg.Parent = gui
                
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Text = p.Name
                txt.TextColor3 = Color3.new(1,0,0)
                txt.TextScaled = true
                txt.Parent = bg
                
                table.insert(espList, bg)
            end
        end
    end
end

local function toggleESP()
    espActive = not espActive
    if espActive then
        updateESP()
        Players.PlayerAdded:Connect(function() task.wait(0.5) updateESP() end)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                p.CharacterAdded:Connect(function() task.wait(0.5) updateESP() end)
            end
        end
        notify("ESP ON")
    else
        for _, e in pairs(espList) do pcall(function() e:Destroy() end) end
        espList = {}
        notify("ESP OFF")
    end
end

-- ============ INVISIBLE ============
local function toggleInvisible()
    if not char then notify("No character"); return end
    invisibleActive = not invisibleActive
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            pcall(function() part.Transparency = invisibleActive and 1 or 0 end)
        end
    end
    notify(invisibleActive and "Invisible ON" or "Invisible OFF")
end

-- ============ DISCO ============
local function toggleDisco()
    discoActive = not discoActive
    if discoActive then
        discoConn = RS.Heartbeat:Connect(function()
            if discoActive then
                Lighting.Ambient = Color3.fromHSV(tick()%5/5, 1, 1)
            end
        end)
        notify("Disco ON")
    else
        if discoConn then discoConn:Disconnect() end
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        notify("Disco OFF")
    end
end

-- ============ SPEED ============
local function toggleSpeed()
    if not hum then notify("No character"); return end
    speedActive = not speedActive
    if speedActive then
        normalSpeed = hum.WalkSpeed
        hum.WalkSpeed = 100
        notify("Speed 100 ON")
    else
        hum.WalkSpeed = normalSpeed
        notify("Speed OFF")
    end
end

-- ============ JUMP ============
local function toggleJump()
    if not hum then notify("No character"); return end
    jumpActive = not jumpActive
    if jumpActive then
        normalJump = hum.JumpPower
        hum.JumpPower = 200
        notify("Jump 200 ON")
    else
        hum.JumpPower = normalJump
        notify("Jump OFF")
    end
end

-- ============ RAGDOLL ============
local function toggleRagdoll()
    if not char or not hum then notify("No character"); return end
    ragdollActive = not ragdollActive
    
    if ragdollActive then
        hum.AutoRotate = false
        hum.PlatformStand = true
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        
        local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
        for _, name in pairs(parts) do
            local part = char:FindFirstChild(name)
            if part then
                local w = part:FindFirstChild("Weld")
                local m = part:FindFirstChild("Motor6D")
                if w then w:Destroy() end
                if m then m:Destroy() end
                
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(math.random(-10,10), math.random(-20,-5), math.random(-10,10))
                bv.MaxForce = Vector3.new(1000,1000,1000)
                bv.Parent = part
                table.insert(ragdollParts, bv)
                part.CanCollide = true
            end
        end
        notify("Ragdoll ON")
    else
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        
        for _, v in pairs(ragdollParts) do
            pcall(function() v:Destroy() end)
        end
        ragdollParts = {}
        notify("Ragdoll OFF")
    end
end

-- ============ LOADERS ============
local function loadIY()
    notify("Loading Infinite Yield...")
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
end

local function loadPastefy()
    notify("Loading Pastefy...")
    pcall(function() loadstring(game:HttpGet("https://pastefy.app/iPp0a0Nx/raw"))() end)
end

local function loadEmotes()
    notify("Loading Emotes...")
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))() end)
end

local function loadVertex()
    notify("Loading Vertex...")
    pcall(function() loadstring(game:HttpGet("https://raw.smokingscripts.org/vertex.lua"))() end)
end

-- ============ CREATE GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 500)
frame.Position = UDim2.new(0.5, -150, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "MakerCS"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-35,0,5)
minBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
minBtn.Text = "✕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextScaled = true
minBtn.Parent = title
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,-45)
scroll.Position = UDim2.new(0,0,0,45)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
end)

local function addBtn(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.94, 0, 0, 45)
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Create buttons
addBtn("✈️ Fly", toggleFly, Color3.fromRGB(50,50,75))
addBtn("🚪 Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
addBtn("👁️ ESP", toggleESP, Color3.fromRGB(50,50,75))
addBtn("👻 Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
addBtn("🕺 Disco", toggleDisco, Color3.fromRGB(50,50,75))
addBtn("⚡ Speed", toggleSpeed, Color3.fromRGB(60,60,85))
addBtn("🦘 Jump", toggleJump, Color3.fromRGB(60,60,85))
addBtn("💀 Ragdoll", toggleRagdoll, Color3.fromRGB(80,40,40))
addBtn("📦 Infinite Yield", loadIY, Color3.fromRGB(80,50,50))
addBtn("📋 Pastefy", loadPastefy, Color3.fromRGB(80,50,70))
addBtn("🎭 Emotes", loadEmotes, Color3.fromRGB(80,50,80))
addBtn("⚔️ Vertex", loadVertex, Color3.fromRGB(80,50,60))

-- Executor
local execFrame = Instance.new("Frame")
execFrame.Size = UDim2.new(0.94, 0, 0, 100)
execFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
execFrame.Parent = scroll
Instance.new("UICorner", execFrame).CornerRadius = UDim.new(0, 8)

local execTitle = Instance.new("TextLabel")
execTitle.Size = UDim2.new(1,0,0,25)
execTitle.BackgroundColor3 = Color3.fromRGB(100,50,50)
execTitle.Text = "Script Executor"
execTitle.TextColor3 = Color3.new(1,1,1)
execTitle.TextScaled = true
execTitle.Font = Enum.Font.GothamBold
execTitle.Parent = execFrame

local box = Instance.new("TextBox")
box.Size = UDim2.new(0.96, 0, 0, 40)
box.Position = UDim2.new(0.02, 0, 0.3, 0)
box.BackgroundColor3 = Color3.fromRGB(20,20,35)
box.PlaceholderText = "Paste script here..."
box.Text = ""
box.TextColor3 = Color3.new(100,255,100)
box.TextScaled = true
box.Font = Enum.Font.Code
box.Parent = execFrame
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0.48, 0, 0, 28)
execBtn.Position = UDim2.new(0.02, 0, 0.7, 0)
execBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
execBtn.Text = "RUN"
execBtn.TextColor3 = Color3.new(1,1,1)
execBtn.TextScaled = true
execBtn.Font = Enum.Font.GothamBold
execBtn.Parent = execFrame
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 5)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, 0, 0, 28)
clearBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(150,50,0)
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.TextScaled = true
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = execFrame
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)

execBtn.MouseButton1Click:Connect(function()
    local code = box.Text
    if code ~= "" then
        pcall(function() loadstring(code)() end)
        notify("Script executed")
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    box.Text = ""
    notify("Cleared")
end)

-- Credits
local credFrame = Instance.new("Frame")
credFrame.Size = UDim2.new(0.94, 0, 0, 80)
credFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
credFrame.Parent = scroll
Instance.new("UICorner", credFrame).CornerRadius = UDim.new(0, 8)

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,0,1,0)
credText.BackgroundTransparency = 1
credText.Text = "MakerCS\nCreated by: ThatOneScripter1234\nGitHub: ypw96hmxqy-cmd/MakerCS"
credText.TextColor3 = Color3.fromRGB(200,200,200)
credText.TextScaled = true
credText.Font = Enum.Font.Gotham
credText.Parent = credFrame

-- Minimize icon
local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0.02, 0, 0.85, 0)
icon.BackgroundColor3 = Color3.fromRGB(0,150,255)
icon.Text = "⚙️"
icon.TextColor3 = Color3.new(1,1,1)
icon.TextScaled = true
icon.Visible = false
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 25)

minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    frame.Visible = true
    icon.Visible = false
end)

-- Character respawn handler
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    if noclipActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    
    if invisibleActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
    end
    
    if speedActive and hum then
        hum.WalkSpeed = 100
    end
    
    if jumpActive and hum then
        hum.JumpPower = 200
    end
end)

notify("MakerCS Loaded!")

print("========================================")
print("MakerCS - Working Edition")
print("All features should work properly")
print("========================================")