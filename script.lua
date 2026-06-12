-- MakerCS - Universal Executor Script
-- Auto-detects executor, mobile-friendly, works on any executor

-- Detect executor
local executor = "Unknown"
local isMobile = false
local currentGame = game.Name or "Unknown"
local placeId = game.PlaceId or 0

-- Executor detection
local function detectExecutor()
    if syn then executor = "Synapse X" 
    elseif krnl then executor = "Krnl" 
    elseif scriptware then executor = "ScriptWare" 
    elseif fluxus then executor = "Fluxus" 
    elseif electron then executor = "Electron" 
    elseif delta then executor = "Delta" 
    elseif arceus then executor = "Arceus X" 
    elseif hydrogen then executor = "Hydrogen" 
    elseif vega then executor = "Vega X" 
    elseif valyse then executor = "Valyse" 
    elseif oxygen then executor = "Oxygen U" 
    elseif kiwi then executor = "Kiwi X" 
    elseif comet then executor = "Comet" 
    elseif swift then executor = "Swift" 
    elseif nihon then executor = "Nihon" 
    elseif athena then executor = "Athena" 
    elseif solara then executor = "Solara" 
    end
    
    if game:GetService("UserInputService").TouchEnabled then
        isMobile = true
    end
    
    local success, name = pcall(function()
        return getexecutorname()
    end)
    if success and name and name ~= "" then
        executor = name
    end
end

detectExecutor()

-- Safe notification function
local function notify(msg, duration)
    duration = duration or 3
    pcall(function()
        if syn and syn.notify then
            syn.notify(msg, duration)
        elseif notify then
            notify(msg, duration)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "MakerCS [" .. executor .. "]",
                Text = msg,
                Duration = duration
            })
        end
    end)
    print("[MakerCS] " .. msg)
end

-- Wait for game load
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local flying = false
local noclipping = false
local espOn = false
local invisible = false
local discoOn = false
local flySpeed = 50
local cons = {}
local esps = {}

-- Character respawn handler
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    
    if noclipping then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
    end
end)

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
if isMobile then
    mainFrame.Size = UDim2.new(0, 350, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -260)
else
    mainFrame.Size = UDim2.new(0, 320, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
end
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,50)
titleBar.BackgroundColor3 = Color3.fromRGB(0,120,200)
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "MakerCS"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local execLabel = Instance.new("TextLabel")
execLabel.Size = UDim2.new(0,100,0,18)
execLabel.Position = UDim2.new(1,-110,0,5)
execLabel.BackgroundTransparency = 1
execLabel.Text = executor
execLabel.TextColor3 = Color3.fromRGB(100,255,100)
execLabel.TextScaled = true
execLabel.Font = Enum.Font.Gotham
execLabel.Parent = titleBar

local gameLabel = Instance.new("TextLabel")
gameLabel.Size = UDim2.new(1,0,0,18)
gameLabel.Position = UDim2.new(0,10,0,30)
gameLabel.BackgroundTransparency = 1
gameLabel.Text = game.Name .. " (ID: " .. placeId .. ")"
gameLabel.TextColor3 = Color3.fromRGB(200,200,200)
gameLabel.TextScaled = true
gameLabel.TextXAlignment = Enum.TextXAlignment.Left
gameLabel.Font = Enum.Font.Gotham
gameLabel.Parent = titleBar

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,35,0,35)
minBtn.Position = UDim2.new(1,-40,0,8)
minBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
minBtn.Text = "✕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,50)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,45)
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 0)

-- Tabs
local tabs = {
    {name = "Main", color = Color3.fromRGB(0,120,200)},
    {name = "Client Scripts", color = Color3.fromRGB(45,45,65)},
    {name = "SS Scripts", color = Color3.fromRGB(65,45,45)},
    {name = "Executor", color = Color3.fromRGB(45,55,65)}
}

local tabButtons = {}
local contentFrames = {}

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = tab.color
    btn.Text = tab.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 0)
    tabButtons[tab.name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,-95)
    content.Position = UDim2.new(0,0,0,95)
    content.BackgroundTransparency = 1
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = isMobile and 8 or 6
    content.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    contentFrames[tab.name] = content
end

-- Create button function
local function createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    if isMobile then
        btn.Size = UDim2.new(0.94, 0, 0, 55)
        btn.Position = UDim2.new(0.03, 0, 0, 0)
    else
        btn.Size = UDim2.new(0.94, 0, 0, 45)
        btn.Position = UDim2.new(0.03, 0, 0, 0)
    end
    btn.BackgroundColor3 = color or Color3.fromRGB(45,45,65)
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    if isMobile then
        btn.TouchTap:Connect(function()
            pcall(callback)
        end)
    end
    return btn
end

-- ============ SCAN GAME FUNCTION ============
local scanResults = {}
local scanFrame = nil
local scanText = nil

local function scanGame()
    notify("🔍 Scanning game... This may take a moment")
    scanResults = {}
    
    -- Create scan results window
    local scanGui = Instance.new("ScreenGui")
    scanGui.Name = "ScanResults"
    scanGui.Parent = plr.PlayerGui
    
    local scanMainFrame = Instance.new("Frame")
    scanMainFrame.Size = UDim2.new(0, 400, 0, 500)
    scanMainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    scanMainFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
    scanMainFrame.Parent = scanGui
    Instance.new("UICorner", scanMainFrame).CornerRadius = UDim.new(0, 12)
    
    local scanTitle = Instance.new("TextLabel")
    scanTitle.Size = UDim2.new(1,0,0,40)
    scanTitle.BackgroundColor3 = Color3.fromRGB(0,100,200)
    scanTitle.Text = "🔍 Game Scanner Results"
    scanTitle.TextColor3 = Color3.new(1,1,1)
    scanTitle.TextScaled = true
    scanTitle.Font = Enum.Font.GothamBold
    scanTitle.Parent = scanMainFrame
    Instance.new("UICorner", scanTitle).CornerRadius = UDim.new(0, 12)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-35,0,5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = scanTitle
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    local scanContent = Instance.new("ScrollingFrame")
    scanContent.Size = UDim2.new(1,0,1,-45)
    scanContent.Position = UDim2.new(0,0,0,45)
    scanContent.BackgroundTransparency = 1
    scanContent.CanvasSize = UDim2.new(0,0,0,0)
    scanContent.ScrollBarThickness = 6
    scanContent.Parent = scanMainFrame
    
    local scanLayout = Instance.new("UIListLayout")
    scanLayout.Parent = scanContent
    scanLayout.Padding = UDim.new(0, 5)
    scanLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function addScanResult(category, name, value)
        local resultFrame = Instance.new("Frame")
        resultFrame.Size = UDim2.new(0.96, 0, 0, 40)
        resultFrame.BackgroundColor3 = Color3.fromRGB(30,30,45)
        resultFrame.Parent = scanContent
        Instance.new("UICorner", resultFrame).CornerRadius = UDim.new(0, 8)
        
        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(0.3, 0, 1, 0)
        catLabel.Position = UDim2.new(0.02, 0, 0, 0)
        catLabel.BackgroundTransparency = 1
        catLabel.Text = category
        catLabel.TextColor3 = Color3.fromRGB(100,200,255)
        catLabel.TextScaled = true
        catLabel.Font = Enum.Font.GothamBold
        catLabel.Parent = resultFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.35, 0, 1, 0)
        nameLabel.Position = UDim2.new(0.33, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255,255,100)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = resultFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.28, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.69, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(value)
        valueLabel.TextColor3 = Color3.fromRGB(100,255,100)
        valueLabel.TextScaled = true
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Parent = resultFrame
    end
    
    -- Scan Workspace
    local workspaceCount = 0
    for _, child in pairs(Workspace:GetChildren()) do
        workspaceCount = workspaceCount + 1
    end
    addScanResult("📦 Workspace", "Total Objects", workspaceCount)
    
    -- Scan Players
    addScanResult("👥 Players", "Total Players", #Players:GetPlayers())
    local playerNames = ""
    for i, p in pairs(Players:GetPlayers()) do
        if i <= 5 then
            playerNames = playerNames .. p.Name .. (i < #Players:GetPlayers() and i < 5 and ", " or "")
        end
    end
    if #Players:GetPlayers() > 5 then
        playerNames = playerNames .. " +" .. (#Players:GetPlayers() - 5) .. " more"
    end
    addScanResult("👥 Players", "Names", playerNames)
    
    -- Scan ReplicatedStorage
    local remoteEvents = 0
    local remoteFunctions = 0
    local scripts = 0
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") then remoteEvents = remoteEvents + 1
        elseif child:IsA("RemoteFunction") then remoteFunctions = remoteFunctions + 1
        elseif child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then scripts = scripts + 1
        end
    end
    addScanResult("📡 ReplicatedStorage", "RemoteEvents", remoteEvents)
    addScanResult("📡 ReplicatedStorage", "RemoteFunctions", remoteFunctions)
    addScanResult("📡 ReplicatedStorage", "Scripts/Modules", scripts)
    
    -- Scan Lighting
    addScanResult("💡 Lighting", "ClockTime", math.floor(Lighting.ClockTime))
    addScanResult("💡 Lighting", "Brightness", math.floor(Lighting.Brightness))
    addScanResult("💡 Lighting", "FogEnd", math.floor(Lighting.FogEnd))
    
    -- Detect backdoor indicators
    local backdoorIndicators = {}
    local backdoorIDs = {7192763922, 7116428237, 5813836873, 5282751219, 4867426485, 7001260635, 15581949972, 9230060018, 7411835387, 8222129769, 11505758587, 16857604287, 114451231828363}
    for _, id in pairs(backdoorIDs) do
        local success = pcall(function() return require(id) end)
        if success then
            table.insert(backdoorIndicators, tostring(id))
        end
    end
    addScanResult("🔓 Backdoor Check", "Require IDs Found", #backdoorIndicators)
    if #backdoorIndicators > 0 then
        addScanResult("🔓 Backdoor IDs", "IDs", table.concat(backdoorIndicators, ", "))
    end
    
    -- Scan for admin scripts
    local adminIndicators = {"Admin", "ESP", "Fly", "Noclip", "Infinite", "Yield", "CMD", "Command"}
    local foundAdmin = {}
    local services = {Workspace, ReplicatedStorage, Lighting}
    for _, service in pairs(services) do
        for _, child in pairs(service:GetChildren()) do
            for _, indicator in pairs(adminIndicators) do
                if child.Name:find(indicator) then
                    table.insert(foundAdmin, child.Name)
                    break
                end
            end
        end
    end
    addScanResult("🛡️ Admin Scripts", "Found", #foundAdmin)
    if #foundAdmin > 0 then
        addScanResult("🛡️ Admin Scripts", "Names", table.concat(foundAdmin, ", "))
    end
    
    -- Update canvas size
    task.wait(0.1)
    local totalHeight = 0
    for _, child in pairs(scanContent:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + 45
        end
    end
    scanContent.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
    
    closeBtn.MouseButton1Click:Connect(function()
        scanGui:Destroy()
    end)
    
    notify("✅ Scan complete! Found " .. (#Players:GetPlayers()) .. " players, " .. remoteEvents .. " RemoteEvents, " .. #backdoorIndicators .. " backdoor IDs")
end

-- ============ FLY ============
local function toggleFly()
    if not root then
        notify("Wait for character to load!")
        return
    end
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bv.Parent = root
        bg.Parent = root
        
        local con = RS.RenderStepped:Connect(function()
            if not flying or not root then return end
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
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
            bg.CFrame = cam.CFrame
        end)
        table.insert(cons, con)
        notify("✈️ Fly ON")
    else
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
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
        for _, part in ipairs(char:GetDescendants()) do
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
                if bg.Adornee == p.Character.Head then
                    exists = true
                    break
                end
            end
            if not exists then
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(4, 0, 2, 0)
                bg.AlwaysOnTop = true
                bg.Parent = gui
                
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name .. "\n❤️ " .. math.floor(p.Character.Humanoid.Health)
                tl.TextColor3 = Color3.new(1, 0.2, 0.2)
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
        
        Players.PlayerAdded:Connect(function() task.wait(1) updateESP() end)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr then
                p.CharacterAdded:Connect(function() task.wait(1) updateESP() end)
            end
        end
        
        local healthLoop = RS.Heartbeat:Connect(function()
            if espOn then
                for _, bg in pairs(esps) do
                    if bg and bg.Adornee and bg.Adornee.Parent then
                        local char = bg.Adornee.Parent
                        if char and char:FindFirstChild("Humanoid") then
                            local tl = bg:FindFirstChild("TextLabel")
                            if tl then
                                tl.Text = char.Name .. "\n❤️ " .. math.floor(char.Humanoid.Health)
                            end
                        end
                    end
                end
            end
        end)
        table.insert(cons, healthLoop)
        
        notify("👁️ ESP ON")
    else
        for _, v in pairs(esps) do
            pcall(function() v:Destroy() end)
        end
        esps = {}
        notify("👁️ ESP OFF")
    end
end

-- ============ INVISIBLE ============
local function toggleInvisible()
    if not char then
        notify("Wait for character!")
        return
    end
    invisible = not invisible
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
        end
        notify("👻 Invisible ON")
    else
        for _, part in ipairs(char:GetDescendants()) do
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
            if discoOn then
                Lighting.Ambient = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                Lighting.ColorShift_Top = Color3.fromHSV((tick() + 1) % 5 / 5, 1, 0.5)
                Lighting.ColorShift_Bottom = Color3.fromHSV((tick() + 2) % 5 / 5, 1, 0.5)
            end
        end)
        notify("🕺 Disco ON")
    else
        if discoCon then discoCon:Disconnect() end
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        notify("🕺 Disco OFF")
    end
end

-- ============ SPEED ============
local speedActive = false
local originalSpeed = 16

local function toggleSpeed()
    if not hum then
        notify("Wait for character!")
        return
    end
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
    if not hum then
        notify("Wait for character!")
        return
    end
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

-- ============ CLIENT SCRIPTS ============
local clientScripts = {
    {"🏃 Speed 100", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100"},
    {"🐢 Speed 16", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16"},
    {"🦘 Jump 200", "game.Players.LocalPlayer.Character.Humanoid.JumpPower = 200"},
    {"📏 Normal Jump", "game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50"},
    {"💥 Explode Self", "local p = game.Players.LocalPlayer.Character.HumanoidRootPart; local e = Instance.new('Explosion'); e.Position = p.Position; e.Parent = workspace"},
    {"🔫 Kill Others", "for _, v in pairs(game.Players:GetPlayers()) do if v ~= game.Players.LocalPlayer and v.Character then v.Character.Humanoid.Health = 0 end end"},
    {"🌞 Day Time", "game.Lighting.ClockTime = 14"},
    {"🌙 Night Time", "game.Lighting.ClockTime = 0"},
    {"🎨 Rainbow Character", "local c = game.Players.LocalPlayer.Character; for _, part in pairs(c:GetDescendants()) do if part:IsA('BasePart') then game:GetService('RunService').RenderStepped:Connect(function() part.Color = Color3.fromHSV(tick()%5/5,1,1) end) end end"},
    {"💪 Super Strength", "game.Players.LocalPlayer.Character.Humanoid.MaxHealth = 1000; game.Players.LocalPlayer.Character.Humanoid.Health = 1000"},
    {"📦 Infinite Yield", "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"},
    {"🌌 Custom Skybox", "local s = Instance.new('Sky'); s.Parent = game.Lighting; s.SkyboxBk = 'rbxassetid://133260261393194'; s.SkyboxDn = 'rbxassetid://133260261393194'; s.SkyboxFt = 'rbxassetid://133260261393194'; s.SkyboxLf = 'rbxassetid://133260261393194'; s.SkyboxRt = 'rbxassetid://133260261393194'; s.SkyboxUp = 'rbxassetid://133260261393194'"}
}

-- ============ SS SCRIPTS (ServerSide - Attempts) ============
local ssScripts = {
    {"🌊 Attempt Flood", [[
        for x = -200, 200, 50 do
            for z = -200, 200, 50 do
                local water = Instance.new("Part")
                water.Size = Vector3.new(50, 1, 50)
                water.Position = Vector3.new(x, -10, z)
                water.Material = Enum.Material.Water
                water.Color = Color3.fromRGB(0,100,255)
                water.Transparency = 0.5
                water.Anchored = true
                water.CanCollide = false
                water.Parent = workspace
            end
        end
    ]]},
    {"🔥 Attempt Lava Map", [[
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(255,50,0)
            end
        end
    ]]},
    {"❄️ Attempt Freeze Map", [[
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Ice
                part.Color = Color3.fromRGB(100,200,255)
            end
        end
    ]]},
    {"💀 Attempt Kill All", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                v.Character.Humanoid.Health = 0
            end
        end
    ]]},
    {"🚀 Attempt Launch All", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                v.Character.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0)
            end
        end
    ]]},
    {"🛑 Attempt Freeze Players", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                v.Character.Humanoid.WalkSpeed = 0
                v.Character.Humanoid.JumpPower = 0
            end
        end
    ]]},
    {"💨 Attempt Unfreeze", [[
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character then
                v.Character.Humanoid.WalkSpeed = 16
                v.Character.Humanoid.JumpPower = 50
            end
        end
    ]]},
    {"🌑 Attempt Blackout", [[
        game.Lighting.Brightness = 0
        game.Lighting.ClockTime = 0
    ]]},
    {"☀️ Attempt Restore Lighting", [[
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
    ]]},
}

-- ============ SCRIPT EXECUTOR ============
local function createExecutor(parent)
    local execFrame = Instance.new("Frame")
    if isMobile then
        execFrame.Size = UDim2.new(0.94, 0, 0, 140)
    else
        execFrame.Size = UDim2.new(0.94, 0, 0, 130)
    end
    execFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
    execFrame.BackgroundTransparency = 0.1
    execFrame.Parent = parent
    Instance.new("UICorner", execFrame).CornerRadius = UDim.new(0, 10)
    
    local execTitle = Instance.new("TextLabel")
    execTitle.Size = UDim2.new(1,0,0,25)
    execTitle.BackgroundColor3 = Color3.fromRGB(100,50,50)
    execTitle.BackgroundTransparency = 0.2
    execTitle.Text = "📝 SCRIPT EXECUTOR"
    execTitle.TextColor3 = Color3.new(1,1,1)
    execTitle.TextScaled = true
    execTitle.Font = Enum.Font.GothamBold
    execTitle.Parent = execFrame
    Instance.new("UICorner", execTitle).CornerRadius = UDim.new(0, 10)
    
    local scriptBox = Instance.new("TextBox")
    if isMobile then
        scriptBox.Size = UDim2.new(0.96, 0, 0, 60)
        scriptBox.Position = UDim2.new(0.02, 0, 0.25, 0)
    else
        scriptBox.Size = UDim2.new(0.96, 0, 0, 55)
        scriptBox.Position = UDim2.new(0.02, 0, 0.25, 0)
    end
    scriptBox.BackgroundColor3 = Color3.fromRGB(20,20,35)
    scriptBox.PlaceholderText = "Paste script here..."
    scriptBox.Text = ""
    scriptBox.TextColor3 = Color3.new(100,255,100)
    scriptBox.TextScaled = true
    scriptBox.Font = Enum.Font.Code
    scriptBox.Parent = execFrame
    Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 8)
    
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.48, 0, 0, 35)
    execBtn.Position = UDim2.new(0.02, 0, 0.72, 0)
    execBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    execBtn.Text = "▶ EXECUTE"
    execBtn.TextColor3 = Color3.new(1,1,1)
    execBtn.TextScaled = true
    execBtn.Font = Enum.Font.GothamBold
    execBtn.Parent = execFrame
    Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 8)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, 0, 0, 35)
    clearBtn.Position = UDim2.new(0.5, 0, 0.72, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150,50,0)
    clearBtn.Text = "🗑 CLEAR"
    clearBtn.TextColor3 = Color3.new(1,1,1)
    clearBtn.TextScaled = true
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = execFrame
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)
    
    execBtn.MouseButton1Click:Connect(function()
        local code = scriptBox.Text
        if code and code ~= "" then
            local success, err = pcall(function()
                loadstring(code)()
            end)
            if success then
                notify("✅ Script executed!")
            else
                notify("❌ Error: " .. tostring(err))
            end
        end
    end)
    
    if isMobile then
        execBtn.TouchTap:Connect(function()
            local code = scriptBox.Text
            if code and code ~= "" then
                local success, err = pcall(function()
                    loadstring(code)()
                end)
                if success then
                    notify("✅ Script executed!")
                else
                    notify("❌ Error: " .. tostring(err))
                end
            end
        end)
    end
    
    clearBtn.MouseButton1Click:Connect(function()
        scriptBox.Text = ""
        notify("Cleared!")
    end)
end

-- ============ POPULATE TABS ============

-- MAIN TAB
local mainContent = contentFrames["Main"]
createButton(mainContent, "✈️ Toggle Fly", toggleFly, Color3.fromRGB(50,50,75))
createButton(mainContent, "🚪 Toggle Noclip", toggleNoclip, Color3.fromRGB(50,50,75))
createButton(mainContent, "👁️ Toggle ESP", toggleESP, Color3.fromRGB(50,50,75))
createButton(mainContent, "👻 Toggle Invisible", toggleInvisible, Color3.fromRGB(50,50,75))
createButton(mainContent, "🕺 Toggle Disco", toggleDisco, Color3.fromRGB(50,50,75))
createButton(mainContent, "⚡ Toggle Speed (100)", toggleSpeed, Color3.fromRGB(60,60,85))
createButton(mainContent, "🦘 Toggle Jump (200)", toggleJump, Color3.fromRGB(60,60,85))

-- CLIENT SCRIPTS TAB
local clientContent = contentFrames["Client Scripts"]

-- Add Scan Game button
createButton(clientContent, "🔍 SCAN GAME (Full Scan)", scanGame, Color3.fromRGB(0,100,150))

for _, script in pairs(clientScripts) do
    createButton(clientContent, script[1], function()
        local success, err = pcall(function()
            loadstring(script[2])()
        end)
        if success then
            notify("✅ Executed: " .. script[1])
        else
            notify("❌ Error: " .. tostring(err))
        end
    end, Color3.fromRGB(55,55,80))
end

-- SS SCRIPTS TAB
local ssContent = contentFrames["SS Scripts"]

local ssWarning = Instance.new("TextLabel")
ssWarning.Size = UDim2.new(0.94, 0, 0, 40)
ssWarning.BackgroundColor3 = Color3.fromRGB(100,50,50)
ssWarning.BackgroundTransparency = 0.3
ssWarning.Text = "⚠️ SS Scripts may only work in backdoored games ⚠️"
ssWarning.TextColor3 = Color3.fromRGB(255,200,100)
ssWarning.TextScaled = true
ssWarning.Font = Enum.Font.GothamBold
ssWarning.Parent = ssContent
Instance.new("UICorner", ssWarning).CornerRadius = UDim.new(0, 10)

for _, script in pairs(ssScripts) do
    createButton(ssContent, script[1], function()
        local success, err = pcall(function()
            loadstring(script[2])()
        end)
        if success then
            notify("✅ Attempted: " .. script[1])
        else
            notify("❌ Failed: " .. tostring(err))
        end
    end, Color3.fromRGB(75,45,45))
end

-- EXECUTOR TAB
local execContent = contentFrames["Executor"]
createExecutor(execContent)

-- Update canvas sizes
local function updateAllCanvas()
    task.wait(0.1)
    for name, content in pairs(contentFrames) do
        local count = 0
        for _, child in pairs(content:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                count = count + 1
            end
        end
        content.CanvasSize = UDim2.new(0, 0, 0, (count * 55) + 30)
    end
end
updateAllCanvas()

for _, content in pairs(contentFrames) do
    local layout = content:FindFirstChildWhichIsA("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
    end
end

-- Tab switching
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

-- Minimize / Restore
local icon = Instance.new("TextButton")
if isMobile then
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0.02, 0, 0.85, 0)
else
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0.02, 0, 0.87, 0)
end
icon.BackgroundColor3 = Color3.fromRGB(0,150,255)
icon.Text = "⚙️\nCS"
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

-- Final welcome
notify("✅ MakerCS Loaded!")
notify("Executor: " .. executor)
notify("Game: " .. game.Name)
notify(isMobile and "📱 Mobile Mode Active" or "💻 PC Mode Active")

print("========================================")
print("MakerCS - Complete Script")
print("Executor: " .. executor)
print("Game: " .. game.Name .. " (ID: " .. placeId .. ")")
print("Mobile: " .. tostring(isMobile))
print("Tabs: Main, Client Scripts, SS Scripts, Executor")
print("========================================")