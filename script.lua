-- MakerCS - Complete Edition with Owner Panel
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/ypw96hmxqy-cmd/MakerCS/main/script.lua"))()

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- ============ CONFIGURATION ============
local AUTHORIZED_USERS = {
    "ThatOneScripter1234",  -- Your username
}

local function isAuthorized()
    for _, name in pairs(AUTHORIZED_USERS) do
        if plr.Name == name then
            return true
        end
    end
    return false
end

-- ============ STATE TRACKING ============
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local invisibleEnabled = false
local discoEnabled = false
local speedEnabled = false
local jumpEnabled = false
local ragdollEnabled = false
local orbitEnabled = false

local flyBV = nil
local flyBG = nil
local flyConnection = nil
local espList = {}
local discoConnection = nil
local originalSpeed = 16
local originalJump = 50
local ragdollParts = {}

-- Orbit variables
local orbitConnection = nil
local orbitData = {}

-- Owner Panel Variables
local PremiumSettings = {
    Godmode = false,
    Noclip = false,
    InfiniteJump = false,
    WalkFling = false
}
local flingConnection = nil
local ownerPanelVisible = false

-- ============ CONFIG ============
local ORBIT_SPEED = 2
local ORBIT_RADIUS = 15
local ORBIT_HEIGHT = 0

local isMobile = UIS.TouchEnabled
local isMM2 = (game.PlaceId == 142823291) or (game.Name and string.find(game.Name, "Murder Mystery"))

-- ============ NOTIFICATION ============
local function notify(msg)
    pcall(function()
        SG:SetCore("SendNotification", {Title = "MakerCS", Text = msg, Duration = 2})
    end)
end

-- ============ FLY ============
local function toggleFly()
    if not root then notify("Wait for character!"); return end
    
    if flyEnabled then
        flyEnabled = false
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        flyBV = nil
        flyBG = nil
        flyConnection = nil
        notify("✈️ Fly OFF")
    else
        flyEnabled = true
        flyBV = Instance.new("BodyVelocity")
        flyBG = Instance.new("BodyGyro")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = root
        flyBG.Parent = root
        
        flyConnection = RS.RenderStepped:Connect(function()
            if not flyEnabled or not root then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            
            if isMobile then
                local moveVec = hum.MoveDirection
                if moveVec.Magnitude > 0.1 then
                    local forward = -moveVec.Z
                    local right = moveVec.X
                    dir = (cam.CFrame.RightVector * right) + (cam.CFrame.LookVector * forward)
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
        
        notify("✈️ Fly ON")
    end
end

-- ============ NOCLIP ============
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    notify(noclipEnabled and "🚪 Noclip ON" or "🚪 Noclip OFF")
end

local noclipLoop = RS.Stepped:Connect(function()
    if noclipEnabled and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)

-- ============ ESP ============
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
                bg.Name = "ESP_" .. p.Name
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(5, 0, 2.5, 0)
                bg.AlwaysOnTop = true
                bg.StudsOffset = Vector3.new(0, 2, 0)
                bg.Parent = gui
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = p.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = bg
                
                local infoLabel = Instance.new("TextLabel")
                infoLabel.Name = "InfoLabel"
                infoLabel.Size = UDim2.new(1, 0, 0.4, 0)
                infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
                infoLabel.BackgroundTransparency = 1
                infoLabel.TextScaled = true
                infoLabel.Font = Enum.Font.Gotham
                infoLabel.Parent = bg
                
                table.insert(espList, bg)
            end
        end
    end
    
    for i = #espList, 1, -1 do
        local esp = espList[i]
        if not esp or not esp.Adornee or not esp.Adornee.Parent then
            pcall(function() esp:Destroy() end)
            table.remove(espList, i)
        end
    end
end

local function updateESPLabels()
    if not espEnabled then return end
    
    for _, bg in pairs(espList) do
        if bg and bg.Adornee and bg.Adornee.Parent then
            local character = bg.Adornee.Parent
            local player = Players:GetPlayerFromCharacter(character)
            
            if player then
                local nameLabel = bg:FindFirstChild("NameLabel")
                if nameLabel then
                    nameLabel.Text = player.Name
                    if isMM2 then
                        if character:FindFirstChild("Knife") then
                            nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                        elseif character:FindFirstChild("Gun") then
                            nameLabel.TextColor3 = Color3.fromRGB(50, 150, 255)
                        else
                            nameLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        end
                    else
                        nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                end
                
                local infoLabel = bg:FindFirstChild("InfoLabel")
                if infoLabel then
                    if isMM2 then
                        if character:FindFirstChild("Knife") then
                            infoLabel.Text = "🔪 MURDERER"
                            infoLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                        elseif character:FindFirstChild("Gun") then
                            infoLabel.Text = "🔫 SHERIFF"
                            infoLabel.TextColor3 = Color3.fromRGB(50, 150, 255)
                        else
                            infoLabel.Text = "👤 INNOCENT"
                            infoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        end
                    else
                        local hum = character:FindFirstChild("Humanoid")
                        if hum then
                            infoLabel.Text = "❤️ " .. math.floor(hum.Health) .. " HP"
                            infoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                        end
                    end
                end
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
        updateESPLabels()
        
        Players.PlayerAdded:Connect(function() 
            task.wait(0.5) 
            if espEnabled then updateESP() end 
        end)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                p.CharacterAdded:Connect(function() 
                    task.wait(0.5) 
                    if espEnabled then updateESP() end 
                end)
            end
        end
        
        local labelUpdate = RS.Heartbeat:Connect(function()
            if espEnabled then updateESPLabels() end
        end)
        table.insert(espList, labelUpdate)
        
        notify(isMM2 and "👁️ MM2 ESP ON" or "👁️ ESP ON")
    end
end

-- ============ INVISIBLE ============
local function toggleInvisible()
    if not char then notify("Wait for character!"); return end
    
    invisibleEnabled = not invisibleEnabled
    
    if invisibleEnabled then
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

-- ============ SPEED ============
local function toggleSpeed()
    if not hum then notify("Wait for character!"); return end
    
    if speedEnabled then
        speedEnabled = false
        hum.WalkSpeed = 16
        notify("⚡ Speed OFF")
    else
        speedEnabled = true
        hum.WalkSpeed = 100
        notify("⚡ Speed 100 ON")
    end
end

-- ============ JUMP ============
local function toggleJump()
    if not hum then notify("Wait for character!"); return end
    
    if jumpEnabled then
        jumpEnabled = false
        hum.JumpPower = 50
        notify("🦘 Jump OFF")
    else
        jumpEnabled = true
        hum.JumpPower = 200
        notify("🦘 Jump 200 ON")
    end
end

-- ============ RAGDOLL ============
local function toggleRagdoll()
    if not char or not hum then notify("Wait for character!"); return end
    
    if ragdollEnabled then
        ragdollEnabled = false
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        
        for _, v in pairs(ragdollParts) do
            pcall(function() v:Destroy() end)
        end
        ragdollParts = {}
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Velocity = Vector3.new()
            end
        end
        notify("💀 Ragdoll OFF")
    else
        ragdollEnabled = true
        hum.AutoRotate = false
        hum.PlatformStand = true
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        
        local parts = {"Head", "Torso", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
        for _, partName in pairs(parts) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local weld = part:FindFirstChild("Weld")
                local motor = part:FindFirstChild("Motor6D")
                if weld then weld:Destroy() end
                if motor then motor:Destroy() end
                
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

-- ============ ORBIT ============
local function updateOrbit()
    if not orbitEnabled or not root or not root.Parent then return end
    
    local centerPos = root.Position
    
    for player, data in pairs(orbitData) do
        if not player or not player.Parent then
            orbitData[player] = nil
            goto continue
        end
        
        local char = player.Character
        if not char then
            player.CharacterAdded:Connect(function(newChar)
                task.wait(0.5)
                if orbitEnabled then
                    local newRoot = newChar:FindFirstChild("HumanoidRootPart")
                    if newRoot then
                        orbitData[player] = {
                            angle = math.random() * 2 * math.pi,
                            speed = ORBIT_SPEED + (math.random() * 0.5 - 0.25),
                            radius = ORBIT_RADIUS + (math.random() * 3 - 1.5),
                            height = ORBIT_HEIGHT + (math.random() * 2 - 1),
                            root = newRoot
                        }
                    end
                end
            end)
            goto continue
        end
        
        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        if not playerRoot then goto continue end
        
        data.angle = data.angle + (data.speed or ORBIT_SPEED) * 0.016
        
        local x = centerPos.X + math.cos(data.angle) * (data.radius or ORBIT_RADIUS)
        local z = centerPos.Z + math.sin(data.angle) * (data.radius or ORBIT_RADIUS)
        local y = centerPos.Y + (data.height or ORBIT_HEIGHT)
        
        playerRoot.CFrame = CFrame.new(x, y, z)
        
        local lookDir = (centerPos - playerRoot.Position).Unit
        if lookDir.Magnitude > 0.1 then
            playerRoot.CFrame = CFrame.lookAt(playerRoot.Position, playerRoot.Position + lookDir)
        end
        
        ::continue::
    end
end

local function toggleOrbit()
    if orbitEnabled then
        orbitEnabled = false
        if orbitConnection then
            orbitConnection:Disconnect()
            orbitConnection = nil
        end
        orbitData = {}
        notify("🌀 Orbit OFF")
    else
        if not root or not root.Parent then
            notify("❌ Wait for character to load!")
            return
        end
        
        orbitEnabled = true
        orbitData = {}
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= plr then
                local char = player.Character
                if char then
                    local playerRoot = char:FindFirstChild("HumanoidRootPart")
                    if playerRoot then
                        orbitData[player] = {
                            angle = math.random() * 2 * math.pi,
                            speed = ORBIT_SPEED + (math.random() * 0.5 - 0.25),
                            radius = ORBIT_RADIUS + (math.random() * 3 - 1.5),
                            height = ORBIT_HEIGHT + (math.random() * 2 - 1),
                            root = playerRoot
                        }
                    end
                end
            end
        end
        
        local function onPlayerAdded(player)
            if player ~= plr then
                player.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if orbitEnabled then
                        local newRoot = char:FindFirstChild("HumanoidRootPart")
                        if newRoot then
                            orbitData[player] = {
                                angle = math.random() * 2 * math.pi,
                                speed = ORBIT_SPEED + (math.random() * 0.5 - 0.25),
                                radius = ORBIT_RADIUS + (math.random() * 3 - 1.5),
                                height = ORBIT_HEIGHT + (math.random() * 2 - 1),
                                root = newRoot
                            }
                        end
                    end
                end)
            end
        end
        
        Players.PlayerAdded:Connect(onPlayerAdded)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= plr then
                player.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if orbitEnabled then
                        local newRoot = char:FindFirstChild("HumanoidRootPart")
                        if newRoot then
                            orbitData[player] = {
                                angle = math.random() * 2 * math.pi,
                                speed = ORBIT_SPEED + (math.random() * 0.5 - 0.25),
                                radius = ORBIT_RADIUS + (math.random() * 3 - 1.5),
                                height = ORBIT_HEIGHT + (math.random() * 2 - 1),
                                root = newRoot
                            }
                        end
                    end
                end)
            end
        end
        
        orbitConnection = RunService.RenderStepped:Connect(updateOrbit)
        notify("🌀 Orbit ON - Players orbit around you!")
    end
end

-- ============ OWNER PANEL FUNCTIONS ============
local function toggleOwnerPanel()
    if not isAuthorized() then
        notify("❌ You are not authorized to use the Owner Panel!")
        return
    end
    ownerPanelVisible = not ownerPanelVisible
    if ownerPanelVisible then
        ownerFrame.Visible = true
        updateStats()
        notify("👑 Owner Panel Opened")
    else
        ownerFrame.Visible = false
        notify("👑 Owner Panel Closed")
    end
end

local function updateStats()
    local statsText = "📊 STATS:\n"
    statsText = statsText .. "Players: " .. #Players:GetPlayers() .. "\n"
    statsText = statsText .. "Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms\n"
    statsText = statsText .. "FPS: " .. math.floor(1 / RS.RenderStepped:Wait()) .. "\n"
    statsText = statsText .. "Memory: " .. math.floor(game:GetService("Stats").Memory.Used:GetValue() / 1024 / 1024) .. "MB\n"
    statsText = statsText .. "Studs Moved: " .. math.floor((root and root.Position.Magnitude or 0))
    Stats.Text = statsText
end

-- ============ WALK FLING ============
local function toggleWalkFling()
    if PremiumSettings.WalkFling then
        if flingConnection then
            flingConnection:Disconnect()
            flingConnection = nil
        end
        flingConnection = RunService.Heartbeat:Connect(function()
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local root = char.HumanoidRootPart
                local hum = char.Humanoid
                
                if hum.MoveDirection.Magnitude > 0 then
                    root.Velocity = root.CFrame.LookVector * 150 + Vector3.new(0, 10, 0)
                end
            end
        end)
    else
        if flingConnection then
            flingConnection:Disconnect()
            flingConnection = nil
        end
    end
end

-- ============ LOAD TTK MODS ============
local function loadTTKMods()
    notify("📥 Loading TTK Mods...")
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ypw96hmxqy-cmd/MakerCS-TTK-script/main/script.lua"))()
    end)
    if success then
        notify("✅ TTK Mods Loaded Successfully!")
    else
        notify("❌ Failed to load TTK Mods: " .. tostring(err))
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
    
    if speedEnabled and hum then
        hum.WalkSpeed = 100
    end
    
    if jumpEnabled and hum then
        hum.JumpPower = 200
    end
    
    if espEnabled then
        task.wait(1)
        updateESP()
        updateESPLabels()
    end
end)

-- ============ CREATE GUI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 600)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "MakerCS [Complete]"
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

-- Owner Panel Button
local ownerBtn = Instance.new("TextButton")
ownerBtn.Size = UDim2.new(0,70,0,30)
ownerBtn.Position = UDim2.new(1,-110,0,5)
ownerBtn.BackgroundColor3 = Color3.fromRGB(0,100,0)
ownerBtn.Text = "👑 Owner"
ownerBtn.TextColor3 = Color3.new(1,1,1)
ownerBtn.TextScaled = true
ownerBtn.Font = Enum.Font.GothamBold
ownerBtn.Parent = title
Instance.new("UICorner", ownerBtn).CornerRadius = UDim.new(0, 8)

ownerBtn.MouseButton1Click:Connect(toggleOwnerPanel)

-- Device info
local deviceLabel = Instance.new("TextLabel")
deviceLabel.Size = UDim2.new(1,0,0,20)
deviceLabel.Position = UDim2.new(0,0,0,40)
deviceLabel.BackgroundColor3 = Color3.fromRGB(30,30,50)
deviceLabel.Text = isMobile and "📱 Mobile Mode" or "💻 PC Mode"
deviceLabel.TextColor3 = Color3.fromRGB(100,255,100)
deviceLabel.TextScaled = true
deviceLabel.Font = Enum.Font.Gotham
deviceLabel.Parent = mainFrame

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,60)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,45)
tabBar.Parent = mainFrame

local tabs = {"Main", "Orbit", "Loaders", "Executor", "Credits"}
local tabButtons = {}
local contentFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0,120,200) or Color3.fromRGB(45,45,65)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 0)
    tabButtons[tabName] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,-105)
    content.Position = UDim2.new(0,0,0,105)
    content.BackgroundTransparency = 1
    content.Visible = (i == 1)
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
    
    contentFrames[tabName] = content
end

local function createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.94, 0, 0, 45)
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============ MAIN TAB ============
local mainContent = contentFrames["Main"]
createButton(mainContent, "✈️ Toggle Fly", toggleFly, Color3.fromRGB(50,50,75))
createButton(mainContent, "🚪 Toggle Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
createButton(mainContent, "👁️ Toggle ESP", toggleESP, Color3.fromRGB(50,50,75))
createButton(mainContent, "👻 Toggle Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
createButton(mainContent, "🕺 Toggle Disco", toggleDisco, Color3.fromRGB(50,50,75))
createButton(mainContent, "⚡ Toggle Speed", toggleSpeed, Color3.fromRGB(60,60,85))
createButton(mainContent, "🦘 Toggle Jump", toggleJump, Color3.fromRGB(60,60,85))
createButton(mainContent, "💀 Toggle Ragdoll", toggleRagdoll, Color3.fromRGB(80,40,40))

-- ============ ORBIT TAB ============
local orbitContent = contentFrames["Orbit"]

-- Orbit Toggle
createButton(orbitContent, "🌀 Toggle Orbit", toggleOrbit, Color3.fromRGB(50,50,100))

-- Orbit Settings Display
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0.94, 0, 0, 100)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
settingsFrame.Parent = orbitContent
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 8)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1,0,0,25)
settingsTitle.BackgroundColor3 = Color3.fromRGB(50,50,80)
settingsTitle.Text = "⚙️ Orbit Settings"
settingsTitle.TextColor3 = Color3.new(1,1,1)
settingsTitle.TextScaled = true
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.Parent = settingsFrame
Instance.new("UICorner", settingsTitle).CornerRadius = UDim.new(0, 8)

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(0.5,0,0,25)
speedText.Position = UDim2.new(0.02,0,0.3,0)
speedText.BackgroundTransparency = 1
speedText.Text = "Speed: " .. ORBIT_SPEED
speedText.TextColor3 = Color3.fromRGB(200,200,200)
speedText.TextScaled = true
speedText.Font = Enum.Font.Gotham
speedText.Parent = settingsFrame

local radiusText = Instance.new("TextLabel")
radiusText.Size = UDim2.new(0.5,0,0,25)
radiusText.Position = UDim2.new(0.5,0,0.3,0)
radiusText.BackgroundTransparency = 1
radiusText.Text = "Radius: " .. ORBIT_RADIUS
radiusText.TextColor3 = Color3.fromRGB(200,200,200)
radiusText.TextScaled = true
radiusText.Font = Enum.Font.Gotham
radiusText.Parent = settingsFrame

local heightText = Instance.new("TextLabel")
heightText.Size = UDim2.new(0.5,0,0,25)
heightText.Position = UDim2.new(0.02,0,0.55,0)
heightText.BackgroundTransparency = 1
heightText.Text = "Height: " .. ORBIT_HEIGHT
heightText.TextColor3 = Color3.fromRGB(200,200,200)
heightText.TextScaled = true
heightText.Font = Enum.Font.Gotham
heightText.Parent = settingsFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0.5,0,0,25)
statusText.Position = UDim2.new(0.5,0,0.55,0)
statusText.BackgroundTransparency = 1
statusText.Text = "Status: Off"
statusText.TextColor3 = Color3.fromRGB(200,100,100)
statusText.TextScaled = true
statusText.Font = Enum.Font.GothamBold
statusText.Parent = settingsFrame

-- Update status when orbit toggles
local oldOrbitToggle = toggleOrbit
toggleOrbit = function()
    oldOrbitToggle()
    statusText.Text = orbitEnabled and "Status: 🟢 ON" or "Status: 🔴 Off"
    statusText.TextColor3 = orbitEnabled and Color3.fromRGB(100,255,100) or Color3.fromRGB(200,100,100)
end

-- TTK Mods Button
createButton(orbitContent, "🎯 Load TTK Mods", loadTTKMods, Color3.fromRGB(150,50,150))

-- ============ LOADERS TAB ============
local loadersContent = contentFrames["Loaders"]
createButton(loadersContent, "📦 Load Infinite Yield", loadIY, Color3.fromRGB(80,50,50))
createButton(loadersContent, "📋 Load Pastefy", loadPastefy, Color3.fromRGB(80,50,70))
createButton(loadersContent, "🎭 Load Emotes", loadEmotes, Color3.fromRGB(80,50,80))
createButton(loadersContent, "⚔️ Load Vertex MM2", loadVertex, Color3.fromRGB(80,50,60))
createButton(loadersContent, "🎯 Load TTK Mods", loadTTKMods, Color3.fromRGB(150,50,150))

-- ============ EXECUTOR TAB ============
local execContent = contentFrames["Executor"]

local execFrame = Instance.new("Frame")
execFrame.Size = UDim2.new(0.94, 0, 0, 120)
execFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
execFrame.Parent = execContent
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
scriptBox.Size = UDim2.new(0.96, 0, 0, 50)
scriptBox.Position = UDim2.new(0.02, 0, 0.25, 0)
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
        notify(success and "✅ Executed!" or "❌ Error")
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptBox.Text = ""
    notify("Cleared!")
end)

-- ============ CREDITS TAB ============
local creditsContent = contentFrames["Credits"]

local credFrame = Instance.new("Frame")
credFrame.Size = UDim2.new(0.94, 0, 0, 140)
credFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
credFrame.Parent = creditsContent
Instance.new("UICorner", credFrame).CornerRadius = UDim.new(0, 8)

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,0,1,0)
credText.BackgroundTransparency = 1
credText.Text = "👑 MAKERCS - COMPLETE EDITION\n\nCreated by: ThatOneScripter1234\n\nFeatures:\n• Fly, Noclip, ESP, Invisible\n• Disco, Speed, Jump, Ragdoll\n• 🌀 Orbit - Make players circle you\n• 🎯 TTK Mods Loader\n• 👑 Owner Panel (Premium Features)\n• Script Executor\n• Multiple Loaders\n\nGitHub: github.com/ypw96hmxqy-cmd/MakerCS"
credText.TextColor3 = Color3.fromRGB(200,200,200)
credText.TextScaled = true
credText.Font = Enum.Font.Gotham
credText.Parent = credFrame

-- ============ OWNER PANEL ============
local ownerFrame = Instance.new("Frame")
ownerFrame.Size = UDim2.new(0, 320, 0, 550)
ownerFrame.Position = UDim2.new(0.5, -160, 0.15, 0)
ownerFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
ownerFrame.Visible = false
ownerFrame.Active = true
ownerFrame.Draggable = true
ownerFrame.Parent = gui
Instance.new("UICorner", ownerFrame).CornerRadius = UDim.new(0, 10)

local ownerTitle = Instance.new("TextLabel")
ownerTitle.Size = UDim2.new(1,0,0,40)
ownerTitle.BackgroundColor3 = Color3.fromRGB(0,100,0)
ownerTitle.Text = "👑 OWNER PREMIUM PANEL"
ownerTitle.TextColor3 = Color3.fromRGB(0,255,100)
ownerTitle.TextScaled = true
ownerTitle.Font = Enum.Font.GothamBold
ownerTitle.Parent = ownerFrame
Instance.new("UICorner", ownerTitle).CornerRadius = UDim.new(0, 10)

local ownerClose = Instance.new("TextButton")
ownerClose.Size = UDim2.new(0,30,0,30)
ownerClose.Position = UDim2.new(1,-35,0,5)
ownerClose.BackgroundColor3 = Color3.fromRGB(200,50,50)
ownerClose.Text = "✕"
ownerClose.TextColor3 = Color3.new(1,1,1)
ownerClose.TextScaled = true
ownerClose.Font = Enum.Font.GothamBold
ownerClose.Parent = ownerTitle
Instance.new("UICorner", ownerClose).CornerRadius = UDim.new(0, 8)

ownerClose.MouseButton1Click:Connect(function()
    ownerFrame.Visible = false
    ownerPanelVisible = false
end)

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1,-20,0,100)
Stats.Position = UDim2.new(0,10,0,50)
Stats.BackgroundTransparency = 1
Stats.TextColor3 = Color3.fromRGB(255,255,255)
Stats.TextWrapped = true
Stats.Font = Enum.Font.Gotham
Stats.TextSize = 14
Stats.Parent = ownerFrame

local function updateStats()
    local statsText = "📊 STATS:\n"
    statsText = statsText .. "Players: " .. #Players:GetPlayers() .. "\n"
    statsText = statsText .. "Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms\n"
    statsText = statsText .. "Memory: " .. math.floor(game:GetService("Stats").Memory.Used:GetValue() / 1024 / 1024) .. "MB\n"
    statsText = statsText .. "Studs Moved: " .. math.floor((root and root.Position.Magnitude or 0))
    Stats.Text = statsText
end

-- Update stats every 2 seconds
game:GetService("RunService").Heartbeat:Connect(function()
    if ownerFrame.Visible then
        updateStats()
    end
end)

local y = 170

local function CreatePremiumToggle(name, default)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1,-20,0,40)
    Toggle.Position = UDim2.new(0,10,0,y)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    Toggle.Text = name .. ": " .. (default and "ON" or "OFF")
    Toggle.TextColor3 = Color3.fromRGB(255,255,255)
    Toggle.Font = Enum.Font.GothamSemibold
    Toggle.TextSize = 16
    Toggle.Parent = ownerFrame
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
    y += 48
    
    Toggle.MouseButton1Click:Connect(function()
        PremiumSettings[name] = not PremiumSettings[name]
        local on = PremiumSettings[name]
        Toggle.BackgroundColor3 = on and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        Toggle.Text = name .. ": " .. (on and "ON" or "OFF")
        
        if name == "Godmode" then
            if on and hum then
                hum.MaxHealth = 9999999
                hum.Health = 9999999
            elseif not on and hum then
                hum.MaxHealth = 100
                hum.Health = 100
            end
        elseif name == "Noclip" then
            toggleNoclip()
        elseif name == "InfiniteJump" then
            if on and hum then
                hum.JumpPower = 9999999
            elseif not on and hum then
                hum.JumpPower = 50
            end
        elseif name == "WalkFling" then
            toggleWalkFling()
        end
    end)
    return Toggle
end

-- Create premium toggles
CreatePremiumToggle("Godmode", false)
CreatePremiumToggle("Noclip", false)
CreatePremiumToggle("InfiniteJump", false)
CreatePremiumToggle("WalkFling", false)

-- Fly GUI Button
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(1,-20,0,45)
FlyBtn.Position = UDim2.new(0,10,0,y)
FlyBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
FlyBtn.Text = "🕊️ MakerCS Fly GUI"
FlyBtn.TextColor3 = Color3.fromRGB(255,255,255)
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 17
FlyBtn.Parent = ownerFrame
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 8)
y += 55

FlyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end)
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,100,0,35)
CloseBtn.Position = UDim2.new(0.5,-50,1,-50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
CloseBtn.Text = "Close"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Parent = ownerFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function()
    ownerFrame.Visible = false
    ownerPanelVisible = false
end)

-- ============ TAB SWITCHING ============
for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, content in pairs(contentFrames) do
            content.Visible = false
        end
        for _, tabBtn in pairs(tabButtons) do
            tabBtn.BackgroundColor3 = Color3.fromRGB(45,45,65)
        end
        contentFrames[name].Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0,120,200)
    end)
end

-- Minimize button
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

-- Final message
notify("✅ MakerCS Complete Loaded!")
if isAuthorized() then
    notify("👑 Owner Panel Available - Click 'Owner' button")
end
if isMobile then
    notify("📱 Mobile Mode Active")
end

print("========================================")
print("MakerCS - Complete Edition with Owner Panel")
print("Tabs: Main, Orbit, Loaders, Executor, Credits")
print("Owner Panel: Click '👑 Owner' button in title bar")
print("Features: Fly, Noclip, ESP, Invisible, Disco, Speed, Jump, Ragdoll, Orbit, TTK Mods")
print("Premium: Godmode, Noclip, InfiniteJump, WalkFling")
print("========================================")