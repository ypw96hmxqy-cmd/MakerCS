-- MakerCS - Delta iOS with All Scripts (IY + Tiger X + Vertex MM2 + Pastefy + Emotes)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local flying, noclipping, espOn, discoOn, invisible = false, false, false, false, false
local flySpeed = 50
local cons = {}
local esps = {}
local originalTransparency = {}

-- Store camera for reference
local camera = workspace.CurrentCamera

-- Function to detect executor
local function detectExecutor()
    -- Check for Roblox Studio
    if game:GetService("RunService"):IsStudio() then
        return "Roblox Studio"
    end
    
    -- Common executor identifiers
    local executorNames = {
        ["Synapse X"] = syn and true or false,
        ["Krnl"] = krnl and true or false,
        ["ScriptWare"] = scriptware and true or false,
        ["Hydrogen"] = hydrogen and true or false,
        ["Fluxus"] = fluxus and true or false,
        ["Electron"] = electron and true or false,
        ["Delta"] = delta and true or false,
        ["Arceus X"] = arceus and true or false,
        ["CodeX"] = codex and true or false,
        ["Evon"] = evon and true or false,
        ["Vega X"] = vega and true or false,
        ["Valyse"] = valyse and true or false,
        ["Oxygen U"] = oxygen and true or false,
        ["Kiwi X"] = kiwi and true or false,
        ["Calamity"] = calamity and true or false,
        ["Comet"] = comet and true or false,
        ["Swift"] = swift and true or false,
        ["Nihon"] = nihon and true or false,
        ["Athena"] = athena and true or false,
        ["Solara"] = solara and true or false,
        ["Celestial"] = celestial and true or false,
        ["Ronix"] = ronix and true or false,
        ["Wave"] = wave and true or false,
        ["Aether"] = aether and true or false,
        ["Elysian"] = elysian and true or false,
        ["Novaline"] = novaline and true or false,
        ["Titan"] = titan and true or false,
    }
    
    -- Check for common global executor variables
    for name, exists in pairs(executorNames) do
        if exists then
            return name
        end
    end
    
    -- Check for identifyexecutor function
    local success, result = pcall(function()
        if identifyexecutor then
            return identifyexecutor()
        end
    end)
    if success and result and result ~= "" then
        return result
    end
    
    -- Check game environment for executor indicators
    local env = getfenv and getfenv() or getrenv and getrenv() or _G
    local executorIndicators = {
        "Synapse", "Krnl", "ScriptWare", "Hydrogen", "Fluxus", 
        "Electron", "Delta", "Arceus", "CodeX", "Evon", "Vega"
    }
    
    for _, indicator in pairs(executorIndicators) do
        if env[indicator] or rawget(env, indicator) then
            return indicator
        end
    end
    
    -- Check for Delta iOS specific
    if game:GetService("UserInputService").TouchEnabled and not game:GetService("RunService"):IsStudio() then
        local success, deltaCheck = pcall(function()
            return getexecutorname and getexecutorname()
        end)
        if success and deltaCheck then
            return deltaCheck
        end
    end
    
    -- Try getexecutorname if available
    local success, execName = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
    end)
    if success and execName and execName ~= "" then
        return execName
    end
    
    -- Check if on mobile
    if UserInputService.TouchEnabled then
        return "Delta iOS / Mobile Executor"
    end
    
    return "Unknown Executor"
end

local executor = detectExecutor()

local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 600)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundColor3 = Color3.fromRGB(0,100,200)
title.Text = "MakerCS [Delta iOS]"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Executor display label
local execLabel = Instance.new("TextLabel")
execLabel.Size = UDim2.new(1,0,0,25)
execLabel.Position = UDim2.new(0,0,0,50)
execLabel.BackgroundColor3 = Color3.fromRGB(0,70,140)
execLabel.Text = "Executor: " .. executor
execLabel.TextColor3 = Color3.new(1,1,0.5)
execLabel.TextScaled = true
execLabel.Font = Enum.Font.GothamBold
execLabel.Parent = mainFrame

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1,0,0,40)
tabFrame.Position = UDim2.new(0,0,0,75)
tabFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
tabFrame.Parent = mainFrame
Instance.new("UICorner", tabFrame)

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.5,0,1,0)
mainTabBtn.Position = UDim2.new(0,0,0,0)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
mainTabBtn.Text = "Main"
mainTabBtn.TextColor3 = Color3.new(1,1,1)
mainTabBtn.TextScaled = true
mainTabBtn.Font = Enum.Font.GothamBold
mainTabBtn.Parent = tabFrame
Instance.new("UICorner", mainTabBtn)

local scriptsTabBtn = Instance.new("TextButton")
scriptsTabBtn.Size = UDim2.new(0.5,0,1,0)
scriptsTabBtn.Position = UDim2.new(0.5,0,0,0)
scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
scriptsTabBtn.Text = "Scripts"
scriptsTabBtn.TextColor3 = Color3.new(1,1,1)
scriptsTabBtn.TextScaled = true
scriptsTabBtn.Font = Enum.Font.GothamBold
scriptsTabBtn.Parent = tabFrame
Instance.new("UICorner", scriptsTabBtn)

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,35,0,35)
minBtn.Position = UDim2.new(1,-40,0,8)
minBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
minBtn.Text = "✕"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextScaled = true
minBtn.Parent = mainFrame
Instance.new("UICorner", minBtn)

-- Floating Icon
local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0,70,0,70)
icon.Position = UDim2.new(0.5,-35,0.2,0)
icon.BackgroundColor3 = Color3.fromRGB(0,100,200)
icon.Text = "⚙️\nMakerCS"
icon.TextColor3 = Color3.new(1,1,1)
icon.TextScaled = true
icon.Visible = false
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 20)

-- Content Frames
local mainContent = Instance.new("ScrollingFrame")
mainContent.Size = UDim2.new(1,0,1,-130)
mainContent.Position = UDim2.new(0,0,0,125)
mainContent.BackgroundTransparency = 1
mainContent.CanvasSize = UDim2.new(0,0,0,350)
mainContent.ScrollBarThickness = 8
mainContent.Parent = mainFrame

local mainList = Instance.new("UIListLayout")
mainList.Parent = mainContent
mainList.Padding = UDim.new(0, 10)
mainList.SortOrder = Enum.SortOrder.LayoutOrder

local scriptsContent = Instance.new("ScrollingFrame")
scriptsContent.Size = UDim2.new(1,0,1,-130)
scriptsContent.Position = UDim2.new(0,0,0,125)
scriptsContent.BackgroundTransparency = 1
scriptsContent.Visible = false
scriptsContent.CanvasSize = UDim2.new(0,0,0,350)
scriptsContent.ScrollBarThickness = 8
scriptsContent.Parent = mainFrame

local scriptsList = Instance.new("UIListLayout")
scriptsList.Parent = scriptsContent
scriptsList.Padding = UDim.new(0, 10)
scriptsList.SortOrder = Enum.SortOrder.LayoutOrder

local function notify(txt)
    SG:SetCore("SendNotification", {Title="MakerCS", Text=txt, Duration=3})
end

local function makeButton(parent, text, toggleFunc, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        if toggleFunc then
            toggleFunc()
            if state then
                btn.BackgroundColor3 = state[1] and Color3.fromRGB(0,170,0) or Color3.fromRGB(40,40,40)
            end
        end
    end)
    return btn
end

local function makeScriptButton(parent, text, url, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.LayoutOrder = order
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        notify("Loading " .. text .. "...")
        pcall(function()
            loadstring(game:HttpGet(url))()
            notify(text .. " Loaded!")
        end)
    end)
    return btn
end

-- === FE FEATURES (All client-side but works with FE) ===
local function toggleFly()
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity")
        local bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bv.Parent = root
        bg.Parent = root
        
        table.insert(cons, RS.RenderStepped:Connect(function()
            if not flying or not root.Parent then return end
            
            -- Get current camera
            local cam = workspace.CurrentCamera
            local moveVector = hum.MoveDirection
            local dir = Vector3.new()
            
            if moveVector.Magnitude > 0.1 then
                -- Get the camera's right and look vectors
                local camRight = cam.CFrame.RightVector
                local camLook = cam.CFrame.LookVector
                
                -- MoveDirection gives us: X = strafe (right/left), Z = forward/back
                local forwardMovement = -moveVector.Z
                local rightMovement = moveVector.X
                
                -- Combine for camera-relative movement
                dir = (camRight * rightMovement) + (camLook * forwardMovement)
                
                -- Normalize if we have movement
                if dir.Magnitude > 0 then
                    dir = dir.Unit
                end
            else
                -- PC keyboard controls fallback
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if dir.Magnitude > 0 then dir = dir.Unit end
            end
            
            -- Vertical movement
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, 1, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                dir = dir + Vector3.new(0, -1, 0)
            end
            
            -- Apply velocity
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
            
            -- Face the camera direction
            bg.CFrame = cam.CFrame
        end))
        
        if UserInputService.TouchEnabled then
            notify("Fly Enabled - Move joystick to fly! (Camera-relative)")
        else
            notify("Fly Enabled - Use WASD + Space/Ctrl")
        end
    else
        for _,v in root:GetChildren() do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
        notify("Fly Disabled")
    end
end

-- Noclip - FE compatible (client-side collision disable)
local function toggleNoclip()
    noclipping = not noclipping
    notify(noclipping and "Noclip Enabled" or "Noclip Disabled")
end

-- Character added connection for noclip
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    
    -- Reapply noclip if enabled
    if noclipping then
        task.wait(0.5)
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Reapply invisibility if enabled
    if invisible then
        task.wait(0.5)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 1
            end
        end
    end
end)

table.insert(cons, RS.Stepped:Connect(function()
    if noclipping and char and root then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        if root then
            root.CanCollide = false
        end
    end
end))

-- ESP - FE compatible (client-side only, other players won't see it)
local function toggleESP()
    espOn = not espOn
    if espOn then
        -- Function to update ESP for all players
        local function updateESP()
            for _,p in Players:GetPlayers() do
                if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
                    -- Check if ESP already exists for this player
                    local existing = nil
                    for _,v in pairs(esps) do
                        if v:FindFirstChild("PlayerName") and v:FindFirstChild("PlayerName").Text == p.Name then
                            existing = v
                            break
                        end
                    end
                    if not existing then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "ESP_" .. p.Name
                        bg.Adornee = p.Character.Head
                        bg.Size = UDim2.new(4,0,2,0)
                        bg.AlwaysOnTop = true
                        bg.Parent = gui
                        
                        local tl = Instance.new("TextLabel")
                        tl.Name = "PlayerName"
                        tl.Size = UDim2.new(1,0,1,0)
                        tl.BackgroundTransparency = 1
                        tl.Text = p.Name .. "\n❤️ " .. math.floor(p.Character.Humanoid.Health)
                        tl.TextColor3 = Color3.new(1,0,0)
                        tl.TextScaled = true
                        tl.Parent = bg
                        
                        table.insert(esps, bg)
                    else
                        -- Update health
                        local tl = existing:FindFirstChild("PlayerName")
                        if tl and p.Character and p.Character:FindFirstChild("Humanoid") then
                            tl.Text = p.Name .. "\n❤️ " .. math.floor(p.Character.Humanoid.Health)
                        end
                    end
                end
            end
        end
        
        updateESP()
        
        -- Update ESP when players join or health changes
        local function onPlayerAdded(p)
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                updateESP()
            end)
        end
        
        for _,p in Players:GetPlayers() do
            if p ~= plr then
                p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    updateESP()
                end)
            end
        end
        
        Players.PlayerAdded:Connect(onPlayerAdded)
        
        -- Health update loop
        table.insert(cons, RS.Heartbeat:Connect(function()
            if espOn then
                for _,bg in pairs(esps) do
                    if bg and bg.Adornee and bg.Adornee.Parent then
                        local character = bg.Adornee.Parent
                        if character and character:FindFirstChild("Humanoid") then
                            local tl = bg:FindFirstChild("PlayerName")
                            if tl then
                                local name = bg.Adornee.Parent.Name
                                tl.Text = name .. "\n❤️ " .. math.floor(character.Humanoid.Health)
                            end
                        end
                    end
                end
            end
        end))
        
        notify("ESP Enabled")
    else
        for _,v in esps do v:Destroy() end
        esps = {}
        notify("ESP Disabled")
    end
end)

-- Disco - FE compatible (client-side lighting)
local function toggleDisco()
    discoOn = not discoOn
    if discoOn then
        local discoConnection
        discoConnection = RS.Heartbeat:Connect(function()
            if discoOn then
                Lighting.Ambient = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                Lighting.ClockTime = (tick() % 24)
                Lighting.ColorShift_Top = Color3.fromHSV(tick() % 5 / 5, 1, 0.5)
                Lighting.ColorShift_Bottom = Color3.fromHSV((tick() + 1) % 5 / 5, 1, 0.5)
            else
                discoConnection:Disconnect()
            end
        end)
        table.insert(cons, discoConnection)
        notify("Disco Enabled")
    else
        -- Reset lighting
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.ClockTime = 14
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        notify("Disco Disabled")
    end
end

-- Invisibility - FE compatible (client-side transparency)
local function toggleInvisible()
    invisible = not invisible
    
    if invisible then
        -- Make character invisible
        local function setInvisible(character)
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    if not originalTransparency[part] then
                        originalTransparency[part] = part.Transparency
                    end
                    part.Transparency = 1
                end
            end
        end
        
        setInvisible(char)
        
        -- Also handle future character respawns
        local charAddedConnection
        charAddedConnection = plr.CharacterAdded:Connect(function(newChar)
            char = newChar
            hum = char:WaitForChild("Humanoid")
            root = char:WaitForChild("HumanoidRootPart")
            task.wait(0.1)
            if invisible then
                setInvisible(char)
            end
        end)
        table.insert(cons, charAddedConnection)
        
        notify("Invisibility Enabled - You are invisible on your screen!")
    else
        -- Restore original transparency
        for part, originalValue in pairs(originalTransparency) do
            if part and part.Parent then
                part.Transparency = originalValue
            end
        end
        originalTransparency = {}
        notify("Invisibility Disabled")
    end
end

-- Make buttons
local flyBtn = makeButton(mainContent, "Toggle Fly", toggleFly, {flying})
local noclipBtn = makeButton(mainContent, "Toggle Noclip", toggleNoclip, {noclipping})
local espBtn = makeButton(mainContent, "Toggle ESP", toggleESP, {espOn})
local discoBtn = makeButton(mainContent, "Toggle Disco", toggleDisco, {discoOn})
local invisBtn = makeButton(mainContent, "Toggle Invisibility", toggleInvisible, {invisible})

-- Set layout order
flyBtn.LayoutOrder = 1
noclipBtn.LayoutOrder = 2
espBtn.LayoutOrder = 3
discoBtn.LayoutOrder = 4
invisBtn.LayoutOrder = 5

-- === SCRIPTS TAB - All Scripts ===
makeScriptButton(scriptsContent, "Load Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", 1)
makeScriptButton(scriptsContent, "Load Tiger X (Brookhaven)", "https://raw.githubusercontent.com/BalintTheDevXBack/Games/refs/heads/main/TIGER_X_Brookhaven", 2)
makeScriptButton(scriptsContent, "Load Vertex MM2", "https://raw.smokingscripts.org/vertex.lua", 3)
makeScriptButton(scriptsContent, "Load Pastefy Script", "https://pastefy.app/iPp0a0Nx/raw", 4)
makeScriptButton(scriptsContent, "Load Emotes Script", "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua", 5)

-- Tab Switching
mainTabBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = true
    scriptsContent.Visible = false
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
end)

scriptsTabBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = false
    scriptsContent.Visible = true
    scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
end)

-- Minimize / Icon
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    icon.Visible = false
end)

-- Get game info and show welcome notification
local gameName = game.Name or "Unknown Game"
local deviceType = UserInputService.TouchEnabled and "Mobile (iOS/Android)" or "PC"
notify("MakerCS Loaded (FE Compatible)!\nExecutor: " .. executor .. "\nGame: " .. gameName .. "\nDevice: " .. deviceType .. "\nAll scripts are in the Scripts tab!")