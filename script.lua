-- MakerCS - GitHub Loadstring Version (Mobile Friendly)
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

-- Variables
local flying = false
local noclipping = false
local espOn = false
local invisible = false
local discoOn = false
local flySpeed = 50
local cons = {}
local esps = {}

-- Mobile detection
local isMobile = UIS.TouchEnabled

-- Check for Murder Mystery 2
local isMM2 = (game.PlaceId == 142823291) or (game.Name and string.find(game.Name, "Murder Mystery"))

-- Notification
local function notify(msg)
    pcall(function()
        SG:SetCore("SendNotification", {Title = "MakerCS", Text = msg, Duration = 2})
    end)
    print("[MakerCS] " .. msg)
end

-- Character respawn handler
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    if noclipping then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    
    if invisible then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
    end
end)

-- ============ MOBILE-FRIENDLY FLY ============
local function toggleFly()
    if not root then notify("Wait for character!"); return end
    flying = not flying
    
    if flying then
        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root
        bg.Parent = root
        
        local con = RS.RenderStepped:Connect(function()
            if not flying or not root then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            
            if isMobile then
                -- Mobile: Use MoveDirection from joystick
                local moveVec = hum.MoveDirection
                if moveVec.Magnitude > 0.1 then
                    -- Convert joystick to camera-relative movement
                    dir = (cam.CFrame.RightVector * moveVec.X) + (cam.CFrame.LookVector * -moveVec.Z)
                    dir = dir.Unit
                end
                -- Vertical movement on mobile (jump/crouch buttons)
                if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.ButtonA) then
                    dir = dir + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.ButtonR2) then
                    dir = dir + Vector3.new(0, -1, 0)
                end
            else
                -- PC: Use WASD
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0, -1, 0) end
            end
            
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
            bg.CFrame = cam.CFrame
        end)
        table.insert(cons, con)
        
        if isMobile then
            notify("✈️ Fly ON - Use joystick to move! Jump = Up, Crouch = Down")
        else
            notify("✈️ Fly ON - WASD + Space/Ctrl")
        end
    else
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
        notify("✈️ Fly OFF")
    end
end

-- ============ NOCLIP ============
local function toggleNoclip()
    noclipping = not noclipping
    notify(noclipping and "🚪 Noclip ON" or "🚪 Noclip OFF")
end

local noclipCon = RS.Stepped:Connect(function()
    if noclipping and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)
table.insert(cons, noclipCon)

-- ============ ESP ============
local function updateESP()
    if not espOn then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local exists = false
            for _, bg in pairs(esps) do
                if bg.Adornee == p.Character.Head then exists = true; break end
            end
            if not exists then
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(5, 0, 2, 0)
                bg.AlwaysOnTop = true
                bg.Parent = gui
                
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 0.5, 0)
                tl.BackgroundTransparency = 1
                
                -- MM2 Role Detection
                if isMM2 and p.Character then
                    if p.Character:FindFirstChild("Knife") then
                        tl.Text = "🔪 " .. p.Name .. " - MURDERER"
                        tl.TextColor3 = Color3.fromRGB(255, 50, 50)
                    elseif p.Character:FindFirstChild("Gun") then
                        tl.Text = "🔫 " .. p.Name .. " - SHERIFF"
                        tl.TextColor3 = Color3.fromRGB(50, 150, 255)
                    else
                        tl.Text = "👤 " .. p.Name
                        tl.TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                else
                    tl.Text = p.Name
                    tl.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
                
                tl.TextScaled = true
                tl.Font = Enum.Font.GothamBold
                tl.Parent = bg
                table.insert(esps, bg)
            end
        end
    end
end

local function toggleESP()
    espOn = not espOn
    if espOn then
        updateESP()
        Players.PlayerAdded:Connect(function() task.wait(0.5) updateESP() end)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                p.CharacterAdded:Connect(function() task.wait(0.5) updateESP() end)
            end
        end
        notify(isMM2 and "👁️ MM2 ESP ON - Shows roles!" or "👁️ ESP ON")
    else
        for _, v in pairs(esps) do pcall(function() v:Destroy() end) end
        esps = {}
        notify("👁️ ESP OFF")
    end
end

-- ============ INVISIBLE ============
local function toggleInvisible()
    if not char then notify("Wait for character!"); return end
    invisible = not invisible
    if invisible then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
        notify("👻 Invisible ON")
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 0 end)
            end
        end
        notify("👻 Invisible OFF")
    end
end

-- ============ DISCO ============
local discoCon = nil
local function toggleDisco()
    discoOn = not discoOn
    if discoOn then
        discoCon = RS.Heartbeat:Connect(function()
            if discoOn then Lighting.Ambient = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
        end)
        notify("🕺 Disco ON")
    else
        if discoCon then discoCon:Disconnect() end
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        notify("🕺 Disco OFF")
    end
end

-- ============ SPEED ============
local speedActive = false
local originalSpeed = 16
local function toggleSpeed()
    if not hum then notify("Wait for character!"); return end
    speedActive = not speedActive
    if speedActive then
        originalSpeed = hum.WalkSpeed
        hum.WalkSpeed = 100
        notify("⚡ Speed 100 ON")
    else
        hum.WalkSpeed = originalSpeed
        notify("⚡ Speed OFF")
    end
end

-- ============ JUMP ============
local jumpActive = false
local originalJump = 50
local function toggleJump()
    if not hum then notify("Wait for character!"); return end
    jumpActive = not jumpActive
    if jumpActive then
        originalJump = hum.JumpPower
        hum.JumpPower = 200
        notify("🦘 Jump 200 ON")
    else
        hum.JumpPower = originalJump
        notify("🦘 Jump OFF")
    end
end

-- ============ RAGDOLL ============
local ragdollActive = false
local function toggleRagdoll()
    if not char then notify("Wait for character!"); return end
    ragdollActive = not ragdollActive
    
    if ragdollActive then
        hum.AutoRotate = false
        hum.PlatformStand = true
        
        local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
        for _, partName in pairs(parts) do
            local part = char:FindFirstChild(partName)
            if part then
                local weld = part:FindFirstChild("Weld")
                local motor = part:FindFirstChild("Motor6D")
                if weld then weld:Destroy() end
                if motor then motor:Destroy() end
                
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(math.random(-10,10), math.random(-15,-5), math.random(-10,10))
                bv.MaxForce = Vector3.new(1000,1000,1000)
                bv.Parent = part
                
                task.wait(0.05)
            end
        end
        notify("💀 Ragdoll ON")
    else
        hum.AutoRotate = true
        hum.PlatformStand = false
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BodyVelocity") then part:Destroy() end
        end
        notify("💀 Ragdoll OFF")
    end
end

-- ============ LOADERS ============
local function loadIY()
    notify("📦 Loading Infinite Yield...")
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
end

local function loadPastefy()
    notify("📋 Loading Pastefy...")
    pcall(function() loadstring(game:HttpGet("https://pastefy.app/iPp0a0Nx/raw"))() end)
end

local function loadEmotes()
    notify("🎭 Loading Emotes...")
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))() end)
end

local function loadVertex()
    notify("⚔️ Loading Vertex MM2...")
    pcall(function() loadstring(game:HttpGet("https://raw.smokingscripts.org/vertex.lua"))() end)
end

-- ============ CREATE GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Mobile-optimized frame size
local frameSize = isMobile and 320 or 280
local frameHeight = isMobile and 550 or 520

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, frameSize, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameSize/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "MakerCS" .. (isMM2 and " [MM2]" or "")
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

-- Device info label
local deviceLabel = Instance.new("TextLabel")
deviceLabel.Size = UDim2.new(1,0,0,18)
deviceLabel.Position = UDim2.new(0,0,0,40)
deviceLabel.BackgroundColor3 = Color3.fromRGB(30,30,50)
deviceLabel.Text = isMobile and "📱 Mobile Mode - Joystick Fly" or "💻 PC Mode - WASD Fly"
deviceLabel.TextColor3 = Color3.fromRGB(100,255,100)
deviceLabel.TextScaled = true
deviceLabel.Font = Enum.Font.Gotham
deviceLabel.Parent = mainFrame

local gameLabel = Instance.new("TextLabel")
gameLabel.Size = UDim2.new(1,0,0,18)
gameLabel.Position = UDim2.new(0,0,0,58)
gameLabel.BackgroundColor3 = Color3.fromRGB(30,30,50)
gameLabel.Text = isMM2 and "🎮 MM2 Mode Active" or "🎮 " .. game.Name
gameLabel.TextColor3 = Color3.fromRGB(200,200,200)
gameLabel.TextScaled = true
gameLabel.Font = Enum.Font.Gotham
gameLabel.Parent = mainFrame

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,0,1,-80)
content.Position = UDim2.new(0,0,0,80)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0,0,0,0)
content.ScrollBarThickness = isMobile and 8 or 6
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
    btn.Size = UDim2.new(0.94, 0, 0, isMobile and 55 or 45)
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    
    -- Mobile touch support
    if isMobile then
        btn.TouchTap:Connect(callback)
    end
    return btn
end

-- Main Feature Buttons
createButton("✈️ Toggle Fly", toggleFly, Color3.fromRGB(50,50,75))
createButton("🚪 Toggle Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
createButton("👁️ Toggle ESP", toggleESP, Color3.fromRGB(50,50,75))
createButton("👻 Toggle Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
createButton("🕺 Toggle Disco", toggleDisco, Color3.fromRGB(50,50,75))
createButton("⚡ Toggle Speed 100", toggleSpeed, Color3.fromRGB(60,60,85))
createButton("🦘 Toggle Jump 200", toggleJump, Color3.fromRGB(60,60,85))
createButton("💀 Toggle Ragdoll", toggleRagdoll, Color3.fromRGB(80,40,40))

-- Loader Buttons
createButton("📦 Load Infinite Yield", loadIY, Color3.fromRGB(80,50,50))
createButton("📋 Load Pastefy", loadPastefy, Color3.fromRGB(80,50,70))
createButton("🎭 Load Emotes", loadEmotes, Color3.fromRGB(80,50,80))
createButton("⚔️ Load Vertex MM2", loadVertex, Color3.fromRGB(80,50,60))

-- Script Executor
local execFrame = Instance.new("Frame")
execFrame.Size = UDim2.new(0.94, 0, 0, isMobile and 130 or 110)
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
scriptBox.Size = UDim2.new(0.96, 0, 0, isMobile and 55 or 45)
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
        notify(success and "✅ Script executed!" or "❌ Error")
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptBox.Text = ""
    notify("Cleared!")
end)

-- Credits
local credFrame = Instance.new("Frame")
credFrame.Size = UDim2.new(0.94, 0, 0, isMobile and 100 or 90)
credFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
credFrame.Parent = content
Instance.new("UICorner", credFrame).CornerRadius = UDim.new(0, 8)

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,0,1,0)
credText.BackgroundTransparency = 1
credText.Text = "👑 MAKERCS\nCreated by: ThatOneScripter1234\nVersion 3.0 | Mobile Friendly\nGitHub: ypw96hmxqy-cmd/MakerCS"
credText.TextColor3 = Color3.fromRGB(200,200,200)
credText.TextScaled = true
credText.Font = Enum.Font.Gotham
credText.Parent = credFrame

-- Floating minimize icon (mobile-friendly size)
local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
icon.Position = UDim2.new(0.02, 0, 0.85, 0)
icon.BackgroundColor3 = Color3.fromRGB(0,150,255)
icon.Text = "⚙️"
icon.TextColor3 = Color3.new(1,1,1)
icon.TextScaled = true
icon.Visible = false
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 30)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    icon.Visible = false
end)

if isMobile then
    icon.TouchTap:Connect(function()
        mainFrame.Visible = true
        icon.Visible = false
    end)
end

-- Final message
notify("✅ MakerCS Loaded Successfully!")
if isMobile then
    notify("📱 Mobile Mode - Use joystick to fly! Jump = Up, Crouch = Down")
end
print("========================================")
print("MakerCS - Mobile Friendly GitHub Version")
print("Game: " .. game.Name)
print("MM2 Mode: " .. tostring(isMM2))
print("Device: " .. (isMobile and "Mobile (Joystick Fly)" or "PC (WASD Fly)"))
print("Features: Fly, Noclip, ESP, Invisible, Disco, Speed, Jump, Ragdoll")
print("Loaders: IY, Pastefy, Emotes, Vertex")
print("========================================")