-- MakerCS - ScriptBlox Edition
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/ypw96hmxqy-cmd/MakerCS/main/script.lua"))()

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Toggle states
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
local flyConnection = nil
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

-- ============ SCRIPLBLOX ============
local scriptbloxCache = {}
local currentFilter = "recent"
local isLoading = false
local scriptbloxContent = nil

local function fetchScripts(filter)
    if isLoading then return end
    isLoading = true
    
    local url = "https://scriptblox.com/api/script/fetch?page=1&max=30"
    
    if filter == "verified" then
        url = url .. "&verified=1"
    elseif filter == "free" then
        url = url .. "&mode=free"
    elseif filter == "universal" then
        url = url .. "&universal=1"
    elseif filter == "trending" then
        url = url .. "&sortBy=views&order=desc"
    elseif filter == "popular" then
        url = url .. "&sortBy=likeCount&order=desc"
    else
        url = url .. "&sortBy=createdAt&order=desc"
    end
    
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result then
        local data = HttpService:JSONDecode(result)
        if data and data.result then
            scriptbloxCache = data.result.scripts or {}
            currentFilter = filter
            notify("✅ Loaded " .. #scriptbloxCache .. " scripts from ScriptBlox")
        end
    else
        notify("❌ Failed to fetch scripts")
    end
    
    isLoading = false
    return scriptbloxCache
end

local function executeScript(scriptUrl, scriptTitle)
    if not scriptUrl or scriptUrl == "" then
        notify("❌ No script URL")
        return
    end
    
    notify("📥 Loading: " .. scriptTitle)
    
    local success, result = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success and result then
        local execSuccess = pcall(function()
            loadstring(result)()
        end)
        if execSuccess then
            notify("✅ Loaded: " .. scriptTitle)
        else
            notify("❌ Execution failed")
        end
    else
        notify("❌ Failed to download")
    end
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
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(0,120,200)
title.Text = "MakerCS [ScriptBlox]"
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

local tabs = {"Main", "ScriptBlox", "Loaders", "Executor", "Credits"}
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

-- ============ SCRIPLBLOX TAB ============
scriptbloxContent = contentFrames["ScriptBlox"]

-- Filter buttons
local filterBar = Instance.new("Frame")
filterBar.Size = UDim2.new(0.94, 0, 0, 45)
filterBar.BackgroundColor3 = Color3.fromRGB(35,35,55)
filterBar.Parent = scriptbloxContent
Instance.new("UICorner", filterBar).CornerRadius = UDim.new(0, 8)

local filters = {"recent", "trending", "popular", "verified", "free", "universal"}
local filterNames = {"🕐 Recent", "🔥 Trending", "⭐ Popular", "✅ Verified", "💸 Free", "🌍 Universal"}

for i, filter in pairs(filters) do
    local filterBtn = Instance.new("TextButton")
    filterBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
    filterBtn.Position = UDim2.new(0.02 + ((i-1)*0.16), 0, 0.1, 0)
    filterBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0,120,200) or Color3.fromRGB(45,65,85)
    filterBtn.Text = filterNames[i]
    filterBtn.TextColor3 = Color3.new(1,1,1)
    filterBtn.TextScaled = true
    filterBtn.Font = Enum.Font.GothamSemibold
    filterBtn.Parent = filterBar
    Instance.new("UICorner", filterBtn).CornerRadius = UDim.new(0, 5)
    
    filterBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(filterBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(45,65,85)
            end
        end
        filterBtn.BackgroundColor3 = Color3.fromRGB(0,120,200)
        
        -- Clear old scripts
        for _, child in pairs(scriptbloxContent:GetChildren()) do
            if child:IsA("TextButton") and child ~= filterBar then
                child:Destroy()
            end
        end
        
        -- Fetch and display new scripts
        fetchScripts(filter)
        task.wait(0.5)
        
        for _, script in pairs(scriptbloxCache) do
            local scriptBtn = Instance.new("TextButton")
            scriptBtn.Size = UDim2.new(0.94, 0, 0, 55)
            scriptBtn.BackgroundColor3 = Color3.fromRGB(55,55,75)
            scriptBtn.Text = "📜 " .. (script.title or "Unknown") .. "\n👁️ " .. (script.views or 0) .. " views | 💬 " .. (script.likes or 0)
            scriptBtn.TextColor3 = Color3.new(1,1,1)
            scriptBtn.TextScaled = true
            scriptBtn.TextWrapped = true
            scriptBtn.Font = Enum.Font.GothamSemibold
            scriptBtn.Parent = scriptbloxContent
            Instance.new("UICorner", scriptBtn).CornerRadius = UDim.new(0, 8)
            
            local scriptUrl = script.script or (script.slug and "https://scriptblox.com/script/" .. script.slug) or nil
            
            scriptBtn.MouseButton1Click:Connect(function()
                if scriptUrl then
                    executeScript(scriptUrl, script.title or "Script")
                else
                    notify("❌ No download URL available")
                end
            end)
        end
    end)
end

-- Load initial scripts
fetchScripts("recent")
task.wait(0.5)

for _, script in pairs(scriptbloxCache) do
    local scriptBtn = Instance.new("TextButton")
    scriptBtn.Size = UDim2.new(0.94, 0, 0, 55)
    scriptBtn.BackgroundColor3 = Color3.fromRGB(55,55,75)
    scriptBtn.Text = "📜 " .. (script.title or "Unknown") .. "\n👁️ " .. (script.views or 0) .. " views | 💬 " .. (script.likes or 0)
    scriptBtn.TextColor3 = Color3.new(1,1,1)
    scriptBtn.TextScaled = true
    scriptBtn.TextWrapped = true
    scriptBtn.Font = Enum.Font.GothamSemibold
    scriptBtn.Parent = scriptbloxContent
    Instance.new("UICorner", scriptBtn).CornerRadius = UDim.new(0, 8)
    
    local scriptUrl = script.script or (script.slug and "https://scriptblox.com/script/" .. script.slug) or nil
    
    scriptBtn.MouseButton1Click:Connect(function()
        if scriptUrl then
            executeScript(scriptUrl, script.title or "Script")
        else
            notify("❌ No download URL available")
        end
    end)
end

-- ============ LOADERS TAB ============
local loadersContent = contentFrames["Loaders"]
createButton(loadersContent, "📦 Load Infinite Yield", loadIY, Color3.fromRGB(80,50,50))
createButton(loadersContent, "📋 Load Pastefy", loadPastefy, Color3.fromRGB(80,50,70))
createButton(loadersContent, "🎭 Load Emotes", loadEmotes, Color3.fromRGB(80,50,80))
createButton(loadersContent, "⚔️ Load Vertex MM2", loadVertex, Color3.fromRGB(80,50,60))

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
credFrame.Size = UDim2.new(0.94, 0, 0, 110)
credFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
credFrame.Parent = creditsContent
Instance.new("UICorner", credFrame).CornerRadius = UDim.new(0, 8)

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,0,1,0)
credText.BackgroundTransparency = 1
credText.Text = "👑 MAKERCS\n\nCreated by: ThatOneScripter1234\n\nFeatures:\n• ScriptBlox Integration - Browse & load scripts\n• Mobile-friendly Fly\n• MM2 Role Detection\n• Fly, Noclip, ESP, Disco\n• Speed, Jump, Ragdoll\n\nGitHub: github.com/ypw96hmxqy-cmd/MakerCS"
credText.TextColor3 = Color3.fromRGB(200,200,200)
credText.TextScaled = true
credText.Font = Enum.Font.Gotham
credText.Parent = credFrame

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

notify("✅ MakerCS Loaded with ScriptBlox!")
notify("📚 Browse scripts in the ScriptBlox tab")

print("========================================")
print("MakerCS - ScriptBlox Edition")
print("ScriptBlox: Browse and load scripts directly")
print("Features: Fly, Noclip, ESP, Invisible, Disco, Speed, Jump, Ragdoll")
print("========================================")