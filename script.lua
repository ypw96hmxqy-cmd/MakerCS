-- MakerAdminCS - Delta iOS with All Scripts (IY + Tiger X + Vertex MM2)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local flying, noclipping, espOn, discoOn = false, false, false, false
local flySpeed = 50
local cons = {}
local esps = {}

local gui = Instance.new("ScreenGui")
gui.Name = "MakerCS"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 520)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundColor3 = Color3.fromRGB(0,100,200)
title.Text = "MakerAdminCS [Delta iOS]"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Tabs
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1,0,0,40)
tabFrame.Position = UDim2.new(0,0,0,50)
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
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1,0,1,-130)
mainContent.Position = UDim2.new(0,0,0,100)
mainContent.BackgroundTransparency = 1
mainContent.Parent = mainFrame

local scriptsContent = Instance.new("Frame")
scriptsContent.Size = UDim2.new(1,0,1,-130)
scriptsContent.Position = UDim2.new(0,0,0,100)
scriptsContent.BackgroundTransparency = 1
scriptsContent.Visible = false
scriptsContent.Parent = mainFrame

local function notify(txt)
    SG:SetCore("SendNotification", {Title="MakerCS", Text=txt, Duration=3})
end

local function makeButton(parent, text, posY, toggleFunc, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.Position = UDim2.new(0.05,0,0,posY)
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

-- === MAIN TAB FEATURES ===
local function toggleFly()
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        local bg = Instance.new("BodyGyro", root)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        table.insert(cons, RS.RenderStepped:Connect(function()
            if not flying then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            bv.Velocity = dir.Unit * flySpeed
            bg.CFrame = cam.CFrame
        end))
        notify("Fly Enabled")
    else
        for _,v in root:GetChildren() do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
        notify("Fly Disabled")
    end
end

local function toggleNoclip()
    noclipping = not noclipping
    notify(noclipping and "Noclip Enabled" or "Noclip Disabled")
end
table.insert(cons, RS.Stepped:Connect(function()
    if noclipping and char then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

local function toggleESP()
    espOn = not espOn
    if espOn then
        for _,p in Players:GetPlayers() do
            if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
                local bg = Instance.new("BillboardGui", gui)
                bg.Adornee = p.Character.Head
                bg.Size = UDim2.new(4,0,2,0)
                bg.AlwaysOnTop = true
                local tl = Instance.new("TextLabel", bg)
                tl.Size = UDim2.new(1,0,1,0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name
                tl.TextColor3 = Color3.new(1,0,0)
                tl.TextScaled = true
                table.insert(esps, bg)
            end
        end
        notify("ESP Enabled")
    else
        for _,v in esps do v:Destroy() end
        esps = {}
        notify("ESP Disabled")
    end
end

local function toggleDisco()
    discoOn = not discoOn
    if discoOn then
        table.insert(cons, RS.Heartbeat:Connect(function()
            if discoOn then Lighting.Ambient = Color3.fromHSV(tick()%5/5,1,1) end
        end))
        notify("Disco Enabled")
    else
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        notify("Disco Disabled")
    end
end

makeButton(mainContent, "Toggle Fly", 10, toggleFly, {flying})
makeButton(mainContent, "Toggle Noclip", 70, toggleNoclip, {noclipping})
makeButton(mainContent, "Toggle ESP", 130, toggleESP, {espOn})
makeButton(mainContent, "Toggle Disco", 190, toggleDisco, {discoOn})

-- === SCRIPTS TAB - All Scripts ===
makeButton(scriptsContent, "Load Infinite Yield", 10, function()
    notify("Loading Infinite Yield...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        notify("Infinite Yield Loaded!")
    end)
end, nil)

makeButton(scriptsContent, "Load Tiger X (Brookhaven)", 70, function()
    notify("Loading Tiger X...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BalintTheDevXBack/Games/refs/heads/main/TIGER_X_Brookhaven"))()
        notify("Tiger X Loaded!")
    end)
end, nil)

makeButton(scriptsContent, "Load Vertex MM2", 130, function()
    notify("Loading Vertex MM2...")
    pcall(function()
        loadstring(game:HttpGet('https://raw.smokingscripts.org/vertex.lua'))()
        notify("Vertex MM2 Loaded! (Best in MM2)")
    end)
end, nil)

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

notify("MakerAdminCS Loaded! All scripts are in the Scripts tab.")