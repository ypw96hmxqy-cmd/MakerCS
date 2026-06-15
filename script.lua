-- MakerCS - Working Toggle Edition for Delta
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

-- Toggle states (using simple boolean variables)
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local invisibleEnabled = false
local discoEnabled = false
local speedEnabled = false
local jumpEnabled = false
local ragdollEnabled = false

local flyBV = nil
local flyBG = nil
local espList = {}
local discoConnection = nil
local originalSpeed = 16
local originalJump = 50
local ragdollParts = {}

-- Mobile detection
local isMobile = UIS.TouchEnabled

-- MM2 detection
local isMM2 = (game.PlaceId == 142823291) or (game.Name and string.find(game.Name, "Murder Mystery"))

-- Notification
local function notify(msg)
    pcall(function()
        SG:SetCore("SendNotification", {Title = "MakerCS", Text = msg, Duration = 2})
    end)
end

-- ============ FLY TOGGLE ============
local function toggleFly()
    if not root then notify("Wait for character!"); return end
    
    if flyEnabled then
        -- Turn OFF
        flyEnabled = false
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        flyBV = nil
        flyBG = nil
        notify("✈️ Fly OFF")
    else
        -- Turn ON
        flyEnabled = true
        flyBV = Instance.new("BodyVelocity")
        flyBG = Instance.new("BodyGyro")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = root
        flyBG.Parent = root
        
        -- Create movement connection
        local con
        con = RS.RenderStepped:Connect(function()
            if not flyEnabled or not root then 
                if con then con:Disconnect() end
                return 
            end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            
            if isMobile then
                local moveVec = hum.MoveDirection
                if moveVec.Magnitude > 0.1 then
                    dir = (cam.CFrame.RightVector * moveVec.X) + (cam.CFrame.LookVector * -moveVec.Z)
                    dir = dir.Unit
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.ButtonA) then
                    dir = dir + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.ButtonR2) then
                    dir = dir + Vector3.new(0, -1, 0)
                end
            else
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0, -1, 0) end
            end
            
            if dir.Magnitude > 0 then
                flyBV.Velocity = dir.Unit * 50
            else
                flyBV.Velocity = Vector3.new()
            end
            flyBG.CFrame = cam.CFrame
        end)
        
        notify("✈️ Fly ON - " .. (isMobile and "Use joystick! Jump/Crouch = Up/Down" or "WASD + Space/Ctrl"))
    end
end

-- ============ NOCLIP TOGGLE ============
local function toggleNoclip()
    if noclipEnabled then
        noclipEnabled = false
        notify("🚪 Noclip OFF")
    else
        noclipEnabled = true
        notify("🚪 Noclip ON")
    end
end

-- Noclip loop
local noclipLoop = RS.Stepped:Connect(function()
    if noclipEnabled and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)

-- ============ ESP TOGGLE ============
local function updateESP()
    if not espEnabled then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local exists = false
            for _, esp in pairs(espList) do
                if esp.Adornee == p.Character.Head then
                    exists = true
                    break
                end
            end
            if not exists then
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(5, 0, 2, 0)
                bg.AlwaysOnTop = true
                bg.Parent = gui
                
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name
                tl.TextColor3 = Color3.fromRGB(255, 0, 0)
                tl.TextScaled = true
                tl.Font = Enum.Font.GothamBold
                tl.Parent = bg
                
                table.insert(espList, bg)
            end
        end
    end
end

local function toggleESP()
    if espEnabled then
        espEnabled = false
        for _, v in pairs(espList) do
            pcall(function() v:Destroy() end)
        end
        espList = {}
        notify("👁️ ESP OFF")
    else
        espEnabled = true
        updateESP()
        
        -- Watch for new players
        Players.PlayerAdded:Connect(function()
            task.wait(0.5)
            if espEnabled then updateESP() end
        end)
        
        -- Watch for character spawns
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if espEnabled then updateESP() end
                end)
            end
        end
        
        notify("👁️ ESP ON")
    end
end

-- ============ INVISIBLE TOGGLE ============
local function toggleInvisible()
    if not char then notify("Wait for character!"); return end
    
    if invisibleEnabled then
        invisibleEnabled = false
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 0 end)
            end
        end
        notify("👻 Invisible OFF")
    else
        invisibleEnabled = true
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
        notify("👻 Invisible ON")
    end
end

-- ============ DISCO TOGGLE ============
local function toggleDisco()
    if discoEnabled then
        discoEnabled = false
        if discoConnection then discoConnection:Disconnect() end
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        notify("🕺 Disco OFF")
    else
        discoEnabled = true
        discoConnection = RS.Heartbeat:Connect(function()
            if discoEnabled then
                Lighting.Ambient = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            end
        end)
        notify("🕺 Disco ON")
    end
end

-- ============ SPEED TOGGLE ============
local function toggleSpeed()
    if not hum then notify("Wait for character!"); return end
    
    if speedEnabled then
        speedEnabled = false
        hum.WalkSpeed = originalSpeed
        notify("⚡ Speed OFF")
    else
        speedEnabled = true
        originalSpeed = hum.WalkSpeed
        hum.WalkSpeed = 100
        notify("⚡ Speed 100 ON")
    end
end

-- ============ JUMP TOGGLE ============
local function toggleJump()
    if not hum then notify("Wait for character!"); return end
    
    if jumpEnabled then
        jumpEnabled = false
        hum.JumpPower = originalJump
        notify("🦘 Jump OFF")
    else
        jumpEnabled = true
        originalJump = hum.JumpPower
        hum.JumpPower = 200
        notify("🦘 Jump 200 ON")
    end
end

-- ============ RAGDOLL TOGGLE ============
local function toggleRagdoll()
    if not char or not hum then notify("Wait for character!"); return end
    
    if ragdollEnabled then
        ragdollEnabled = false
        
        -- Restore humanoid
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        
        -- Clean up
        for _, v in pairs(ragdollParts) do
            pcall(function() v:Destroy() end)
        end
        ragdollParts = {}
        
        -- Reset parts
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Velocity = Vector3.new()
            end
        end
        
        notify("💀 Ragdoll OFF")
    else
        ragdollEnabled = true
        
        -- Disable humanoid
        hum.AutoRotate = false
        hum.PlatformStand = true
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        
        -- Ragdoll parts
        local parts = {"Head", "Torso", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
        
        for _, partName in pairs(parts) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                -- Break joints
                local weld = part:FindFirstChild("Weld")
                local motor = part:FindFirstChild("Motor6D")
                if weld then weld:Destroy() end
                if motor then motor:Destroy() end
                
                -- Add physics
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(math.random(-15,15), math.random(-25,-10), math.random(-15,15))
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Parent = part
                table.insert(ragdollParts, bv)
                
                local av = Instance.new("AngularVelocity")
                av.AngularVelocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
                av.MaxTorque = Vector3.new(4000, 4000, 4000)
                av.Parent = part
                table.insert(ragdollParts, av)
                
                part.CanCollide = true
            end
        end
        
        notify("💀 Ragdoll ON")
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
    notify("Loading Vertex MM2...")
    pcall(function() loadstring(game:HttpGet("https://raw.smokingscripts.org/vertex.lua"))() end)
end

-- ============ CHARACTER RESPAWN ============
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    -- Reapply toggles that should persist
    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    
    if invisibleEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
    end
    
    if flyEnabled then
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        flyBV = Instance.new("BodyVelocity")
        flyBG = Instance.new("BodyGyro")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = root
        flyBG.Parent = root
    end
    
    if speedEnabled then
        hum.WalkSpeed = 100
    end
    
    if jumpEnabled then
        hum.JumpPower = 200
    end
end)

-- ============ CREATE GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 520)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "MakerCS"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,35,0,35)
minBtn.Position = UDim2.new(1,-40,0,3)
minBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
minBtn.Text = "✕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextScaled = true
minBtn.Parent = title
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,0,1,-45)
content.Position = UDim2.new(0,0,0,45)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0,0,0,0)
content.ScrollBarThickness = 6
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = content
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
end)

local function createButton(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.94, 0, 0, 45)
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Create all buttons
createButton("✈️ Toggle Fly", toggleFly, Color3.fromRGB(50,50,75))
createButton("🚪 Toggle Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
createButton("👁️ Toggle ESP", toggleESP, Color3.fromRGB(50,50,75))
createButton("👻 Toggle Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
createButton("🕺 Toggle Disco", toggleDisco, Color3.fromRGB(50,50,75))
createButton("⚡ Toggle Speed", toggleSpeed, Color3.fromRGB(60,60,85))
createButton("🦘 Toggle Jump", toggleJump, Color3.fromRGB(60,60,85))
createButton("💀 Toggle Ragdoll", toggleRagdoll, Color3.fromRGB(80,40,40))
createButton("📦 Load Infinite Yield", loadIY, Color3.fromRGB(80,50,50))
createButton("📋 Load Pastefy", loadPastefy, Color3.fromRGB(80,50,70))
createButton("🎭 Load Emotes", loadEmotes, Color3.fromRGB(80,50,80))
createButton("⚔️ Load Vertex MM2", loadVertex, Color3.fromRGB(80,50,60))

-- Script Executor
local execFrame = Instance.new("Frame")
execFrame.Size = UDim2.new(0.94, 0, 0, 110)
execFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
execFrame.Parent = content
Instance.new("UICorner", execFrame).CornerRadius = UDim.new(0, 8)

local execTitle = Instance.new("TextLabel")
execTitle.Size = UDim2.new(1,0,0,25)
execTitle.BackgroundColor3 = Color3.fromRGB(100,50,50)
execTitle.Text = "📝 SCRIPT EXECUTOR"
execTitle.TextColor3 = Color3.new(1,1,1)
execTitle.TextScaled = true
execTitle.Font = Enum.Font.GothamBold
execTitle.Parent = execFrame

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(0.96, 0, 0, 45)
scriptBox.Position = UDim2.new(0.02, 0, 0.3, 0)
scriptBox.BackgroundColor3 = Color3.fromRGB(20,20,35)
scriptBox.PlaceholderText = "Paste Lua script here..."
scriptBox.Text = ""
scriptBox.TextColor3 = Color3.new(100,255,100)
scriptBox.TextScaled = true
scriptBox.Font = Enum.Font.Code
scriptBox.Parent = execFrame
Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 5)

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0.48, 0, 0, 30)
execBtn.Position = UDim2.new(0.02, 0, 0.7, 0)
execBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
execBtn.Text = "EXECUTE"
execBtn.TextColor3 = Color3.new(1,1,1)
execBtn.TextScaled = true
execBtn.Font = Enum.Font.GothamBold
execBtn.Parent = execFrame
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 5)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, 0, 0, 30)
clearBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(150,50,0)
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.TextScaled = true
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = execFrame
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)

execBtn.MouseButton1Click:Connect(function()
    local code = scriptBox.Text
    if code and code ~= "" then
        local success, err = pcall(function() loadstring(code)() end)
        notify(success and "✅ Executed!" or "❌ Error: " .. tostring(err))
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptBox.Text = ""
    notify("Cleared!")
end)

-- Credits
local credFrame = Instance.new("Frame")
credFrame.Size = UDim2.new(0.94, 0, 0, 80)
credFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
credFrame.Parent = content
Instance.new("UICorner", credFrame).CornerRadius = UDim.new(0, 8)

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,0,1,0)
credText.BackgroundTransparency = 1
credText.Text = "👑 MAKERCS\nCreated by: ThatOneScripter1234\nGitHub: ypw96hmxqy-cmd/MakerCS"
credText.TextColor3 = Color3.fromRGB(200,200,200)
credText.TextScaled = true
credText.Font = Enum.Font.Gotham
credText.Parent = credFrame

-- Floating minimize icon
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
    mainFrame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    icon.Visible = false
end)

notify("✅ MakerCS Loaded!")

print("========================================")
print("MakerCS - Working Toggle Edition")
print("All toggles should work properly now")
print("========================================")