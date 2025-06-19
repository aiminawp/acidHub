local Fluent = loadstring(Game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local coregui = cloneref(game:GetService("CoreGui"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")
local currentTarget = nil
local targetLockTime = 0
local lastAimUpdate = 0
local WatermarkEnabled = false
local WatermarkFrame = nil

local quotes = {
    " - BobDaHacker",
    " - Cultivating unemployment",
    " - builder.ai skid 2025 no way",
    " - Probably gonna get banned lol",
    " - Touching grass is overrated anyway",
    " - WARNING: May cause vitamin D deficiency",
    " - Now with 50% more spaghetti code",
    " - Breaking tos since 1900 BC",
    " - Trust me bro, it's legit",
    " - Speedrunning a ban any%",
    " - Warning: Side effects may include skill issues",
    " - Probably violating several laws of physics",
    " - Why wda_excludefromcapture not work???"
}

local function getRandomQuote()
    local randomIndex = math.random(1, #quotes)
    return quotes[randomIndex]
end

local randomQuote = getRandomQuote()

local Window = Fluent:CreateWindow({
    Title = "Acid " .. randomQuote,
    TabWidth = 160,
    Size = UDim2.fromOffset(720, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift,
})

local Tabs = {
    Credits = Window:AddTab({ Title = "Credits" }),
    Aim = Window:AddTab({ Title = "Aim" }),
    ESP = Window:AddTab({ Title = "Esp" }),
    Misc = Window:AddTab({ Title = "Misc" }),
    Modulation = Window:AddTab({ Title = "Modulation" })
}
Window:SelectTab(1)

Tabs.Credits:AddParagraph({
        Title = "Soma",
        Content = "Improved features"
})

Tabs.Credits:AddParagraph({
        Title = "Klyte",
        Content = "Base script"
})

local AimbotSettings = {
    Enabled = false,
    Mode = "Lock", 
    DistanceCap = 500,
    WallCheck = false,
    FOVEnabled = true,
    FOVSize = 100,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVFilled = false,
    FOVTransparency = 0.5,
    TargetPart = "Head",
    Key = Enum.KeyCode.E,
    Smoothness = 5,
    PredictionEnabled = false,
    PredictionStrength = 0.5
}

local ESPSettings = {
    Enabled = false,
    BoxEnabled = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameEnabled = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceEnabled = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    SkeletonEnabled = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    HealthBarEnabled = false,
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthBarBackgroundColor = Color3.fromRGB(0, 0, 0),
    HealthTextColor = Color3.fromRGB(255, 255, 255),
    HealthTextSize = 11,
    HealthBarThickness = 4,
    HealthBarOffsetX = 8,
    HealthBarOffsetY = 0,
    MaxDisplayDistance = 1000
}

local MiscSettings = {
    WalkSpeed = 16,
    NoSpread = false,
    NoSpreadPower = 80, -- lower is less spread higher is more spread
    Glide = false,
    GlideSpeed = 0.9
}

local WorldSettings = {
    CustomAtmosphere = false,
    BrightEnabled = false,
    Brightness = 1,
    Ambient = Color3.fromRGB(127, 127, 127),
    OutdoorAmbient = Color3.fromRGB(127, 127, 127),
    FogEnabled = false,
    FogColor = Color3.fromRGB(100, 100, 100),
    FogStart = 0,
    FogEnd = 300
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = AimbotSettings.FOVSize
FOVCircle.Color = AimbotSettings.FOVColor
FOVCircle.Transparency = AimbotSettings.FOVTransparency
FOVCircle.NumSides = 72
FOVCircle.Thickness = 4
FOVCircle.Filled = AimbotSettings.FOVFilled

local mousePosition = Vector2.new(0, 0)
local lastMouseUpdate = 0
local lastPlayerListUpdate = 0
local cachedPlayers = {}
local frameCounter = 0

local function UpdateMousePosition()
    local currentTime = tick()
    if currentTime - lastMouseUpdate > 0.005 then
        mousePosition = UserInputService:GetMouseLocation()
        lastMouseUpdate = currentTime
    end
end

local function UpdatePlayerCache()
    local currentTime = tick()
    if currentTime - lastPlayerListUpdate > 0.5 then
        cachedPlayers = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                cachedPlayers[#cachedPlayers + 1] = player
            end
        end
        lastPlayerListUpdate = currentTime
    end
end

local function UpdateFOVCircle()
    if FOVCircle and AimbotSettings.FOVEnabled and AimbotSettings.Enabled then
        FOVCircle.Position = mousePosition
        FOVCircle.Radius = AimbotSettings.FOVSize
        FOVCircle.Color = AimbotSettings.FOVColor
        FOVCircle.Transparency = AimbotSettings.FOVTransparency
        FOVCircle.Filled = AimbotSettings.FOVFilled
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

local function IsAlive(player)
    local character = player.Character
    return character and character:FindFirstChild("Humanoid") and 
           character.Humanoid.Health > 0 and 
           character:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(origin, destination, ignoreList)
    local ray = Ray.new(origin, destination - origin)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hit == nil
end

local function GetDistanceFromCharacter(position)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (LocalPlayer.Character.HumanoidRootPart.Position - position).Magnitude
end

local function GetClosestPlayerToMouse()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local targetPart = character:FindFirstChild(AimbotSettings.TargetPart)
            
            if humanoidRootPart and targetPart then
                local distance = GetDistanceFromCharacter(humanoidRootPart.Position)
                
                if distance <= AimbotSettings.DistanceCap then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local screenDistance = (mousePosition - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        
                        if screenDistance <= AimbotSettings.FOVSize then
                            if not AimbotSettings.Enabled or IsVisible(Camera.CFrame.Position, targetPart.Position, {LocalPlayer.Character, character}) then
                                if screenDistance < shortestDistance then
                                    closestPlayer = player
                                    shortestDistance = screenDistance
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local ESPObjects = {}
local espUpdateCounter = 0

local function CreateWatermark()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- screen gui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Watermark"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 40)
    frame.Position = UDim2.new(0.5, 0.5, 0, 5) -- top center
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    local accentColor = Color3.fromRGB(240, 240, 255)
    
    -- italic A logo
    local aLabel = Instance.new("TextLabel")
    aLabel.Size = UDim2.new(0, 32, 1, 0)
    aLabel.Position = UDim2.new(0, 12, 0, 0)
    aLabel.BackgroundTransparency = 1
    aLabel.TextColor3 = accentColor
    aLabel.Font = Enum.Font.SourceSansBold
    aLabel.TextSize = 26
    aLabel.Text = "A"
    aLabel.TextXAlignment = Enum.TextXAlignment.Center
    aLabel.TextYAlignment = Enum.TextYAlignment.Center
    aLabel.Rotation = -12
    aLabel.Parent = frame
    
    -- separator function
    local function createSeparator(xPos)
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(0, 2, 0, 24)
        sep.Position = UDim2.new(0, xPos, 0, 8)
        sep.BackgroundColor3 = accentColor
        sep.BackgroundTransparency = 0.6
        sep.BorderSizePixel = 0
        sep.Parent = frame
        return sep
    end
    
    createSeparator(62)
    createSeparator(174)
    
    -- fps label
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 100, 1, 0)
    fpsLabel.Position = UDim2.new(0, 70, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    fpsLabel.Font = Enum.Font.SourceSans
    fpsLabel.TextSize = 20
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
    fpsLabel.Text = "FPS: 0"
    fpsLabel.Parent = frame
    
    -- ping label
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0, 80, 1, 0)
    pingLabel.Position = UDim2.new(0, 200, 0, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    pingLabel.Font = Enum.Font.SourceSans
    pingLabel.TextSize = 20
    pingLabel.TextXAlignment = Enum.TextXAlignment.Center
    pingLabel.TextYAlignment = Enum.TextYAlignment.Center
    pingLabel.Text = "Ping: 0 ms"
    pingLabel.Parent = frame
    
    -- fps counter
    local fps = 0
    local frameCount = 0
    local lastTime = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            fps = frameCount / (now - lastTime)
            frameCount = 0
            lastTime = now
            fpsLabel.Text = string.format("FPS: %d", math.floor(fps))
        end
    end)
    
    -- ping updater
    coroutine.wrap(function()
        while true do
            local ping = player:GetNetworkPing() * 1000
            pingLabel.Text = string.format("Ping: %d ms", math.floor(ping))
            wait(1)
        end
    end)()
    
    return frame
end

local function CreateESPObject(player)
    local espObject = {
        Player = player,
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBarBackground = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        SkeletonLines = {},
        LastUpdate = 0
    }
    
    espObject.BoxOutline.Color = Color3.new(0, 0, 0)
    espObject.BoxOutline.Thickness = 3
    espObject.BoxOutline.Visible = false
    
    espObject.Box.Thickness = 1
    espObject.Box.Visible = false
    
    espObject.Name.Size = 13
    espObject.Name.Center = true
    espObject.Name.Outline = true
    espObject.Name.Visible = false
    
    espObject.Distance.Size = 13
    espObject.Distance.Center = true
    espObject.Distance.Outline = true
    espObject.Distance.Visible = false
    
    -- Health bar setup
    espObject.HealthBarBackground.Color = ESPSettings.HealthBarBackgroundColor
    espObject.HealthBarBackground.Filled = true
    espObject.HealthBarBackground.Visible = false
    
    espObject.HealthBar.Color = ESPSettings.HealthBarColor
    espObject.HealthBar.Filled = true
    espObject.HealthBar.Visible = false
    
    espObject.HealthText.Size = ESPSettings.HealthTextSize
    espObject.HealthText.Center = true
    espObject.HealthText.Outline = true
    espObject.HealthText.Color = ESPSettings.HealthTextColor
    espObject.HealthText.Visible = false
    
    local skeletonConnections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"}
    }
    
    for _, connection in pairs(skeletonConnections) do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        
        espObject.SkeletonLines[#espObject.SkeletonLines + 1] = {
            Line = line,
            From = connection[1],
            To = connection[2]
        }
    end
    
    return espObject
end

local function UpdateESPObject(espObject, currentTime, forceUpdate)
    local player = espObject.Player
    
    -- player do not exist sadge
    if not player or not player.Parent then
        return
    end
    
    -- esp updates every 0.02 secs or every 50 frames i think idfk i forgor
    if not forceUpdate and currentTime - espObject.LastUpdate < 0.02 then
        return
    end
    
    espObject.LastUpdate = currentTime
    
    if not IsAlive(player) or not ESPSettings.Enabled then
        espObject.BoxOutline.Visible = false
        espObject.Box.Visible = false
        espObject.Name.Visible = false
        espObject.Distance.Visible = false
        espObject.HealthBarBackground.Visible = false
        espObject.HealthBar.Visible = false
        espObject.HealthText.Visible = false
        
        for _, skeleton in pairs(espObject.SkeletonLines) do
            skeleton.Line.Visible = false
        end
        return
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local distance = GetDistanceFromCharacter(humanoidRootPart.Position)
    
    if distance > ESPSettings.MaxDisplayDistance then
        espObject.BoxOutline.Visible = false
        espObject.Box.Visible = false
        espObject.Name.Visible = false
        espObject.Distance.Visible = false
        espObject.HealthBarBackground.Visible = false
        espObject.HealthBar.Visible = false
        espObject.HealthText.Visible = false
        
        for _, skeleton in pairs(espObject.SkeletonLines) do
            skeleton.Line.Visible = false
        end
        return
    end
    
    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not (head and rootPart and humanoid) then
        return
    end
    
    local rootPosition = rootPart.Position
    local headPosition = head.Position + Vector3.new(0, head.Size.Y/2, 0)
    local footPosition = rootPosition - Vector3.new(0, humanoid.HipHeight + 2, 0)
    
    local headPos, headOnScreen = Camera:WorldToViewportPoint(headPosition)
    local footPos, footOnScreen = Camera:WorldToViewportPoint(footPosition)
    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPosition)
    
    if not (headOnScreen or footOnScreen or rootOnScreen) then
        espObject.BoxOutline.Visible = false
        espObject.Box.Visible = false
        espObject.Name.Visible = false
        espObject.Distance.Visible = false
        espObject.HealthBarBackground.Visible = false
        espObject.HealthBar.Visible = false
        espObject.HealthText.Visible = false
        
        for _, skeleton in pairs(espObject.SkeletonLines) do
            skeleton.Line.Visible = false
        end
        return
    end
    
    local boxHeight = math.abs(headPos.Y - footPos.Y) * 1.1
    local boxWidth = boxHeight * 0.6
    local boxCenter = Vector2.new(headPos.X, headPos.Y + (footPos.Y - headPos.Y)/2)
    
    -- esp
    if ESPSettings.BoxEnabled then
        espObject.BoxOutline.Position = Vector2.new(boxCenter.X - boxWidth/2, boxCenter.Y - boxHeight/2)
        espObject.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
        espObject.BoxOutline.Visible = true
        
        espObject.Box.Position = Vector2.new(boxCenter.X - boxWidth/2, boxCenter.Y - boxHeight/2)
        espObject.Box.Size = Vector2.new(boxWidth, boxHeight)
        espObject.Box.Color = ESPSettings.BoxColor
        espObject.Box.Visible = true
    else
        espObject.BoxOutline.Visible = false
        espObject.Box.Visible = false
    end
    
    if ESPSettings.NameEnabled then
        espObject.Name.Position = Vector2.new(boxCenter.X, boxCenter.Y - boxHeight/2 - 15)
        espObject.Name.Text = player.Name
        espObject.Name.Color = ESPSettings.NameColor
        espObject.Name.Visible = true
    else
        espObject.Name.Visible = false
    end
    
    if ESPSettings.DistanceEnabled then
        espObject.Distance.Position = Vector2.new(boxCenter.X, boxCenter.Y + boxHeight/2 + 5)
        espObject.Distance.Text = math.floor(distance) .. " studs"
        espObject.Distance.Color = ESPSettings.DistanceColor
        espObject.Distance.Visible = true
    else
        espObject.Distance.Visible = false
    end
    
    if ESPSettings.HealthBarEnabled then
        local maxHealth = humanoid.MaxHealth
        local currentHealth = humanoid.Health
        local healthPercentage = currentHealth / maxHealth
        
        local healthBarWidth = ESPSettings.HealthBarThickness
        local healthBarHeight = boxHeight
        local healthBarX = boxCenter.X - boxWidth/2 - ESPSettings.HealthBarOffsetX
        local healthBarY = boxCenter.Y - boxHeight/2 + ESPSettings.HealthBarOffsetY -- CHANGED now its actually aligned lmfao
        
        -- Health bar background
        espObject.HealthBarBackground.Position = Vector2.new(healthBarX, healthBarY)
        espObject.HealthBarBackground.Size = Vector2.new(healthBarWidth, healthBarHeight)
        espObject.HealthBarBackground.Color = ESPSettings.HealthBarBackgroundColor
        espObject.HealthBarBackground.Visible = true
        
        -- Health bar fill
        local healthFillHeight = healthBarHeight * healthPercentage
        espObject.HealthBar.Position = Vector2.new(healthBarX, healthBarY + (healthBarHeight - healthFillHeight))
        espObject.HealthBar.Size = Vector2.new(healthBarWidth, healthFillHeight)
        espObject.HealthBar.Color = Color3.fromRGB(0, 255, 0) -- Green
        
        espObject.HealthBar.Visible = true
        
        -- helth text
        espObject.HealthText.Position = Vector2.new(healthBarX - 15, healthBarY - 15)
        espObject.HealthText.Text = math.floor(currentHealth) .. "/" .. math.floor(maxHealth)
        espObject.HealthText.Visible = true
    else
        espObject.HealthBarBackground.Visible = false
        espObject.HealthBar.Visible = false
        espObject.HealthText.Visible = false
    end
    
    -- esp
    if ESPSettings.SkeletonEnabled then
        for _, skeleton in pairs(espObject.SkeletonLines) do
            local fromPart = character:FindFirstChild(skeleton.From)
            local toPart = character:FindFirstChild(skeleton.To)
            
            if fromPart and toPart then
                local fromPoint, visibleFrom = Camera:WorldToViewportPoint(fromPart.Position)
                local toPoint, visibleTo = Camera:WorldToViewportPoint(toPart.Position)
                
                if visibleFrom and visibleTo then
                    skeleton.Line.From = Vector2.new(fromPoint.X, fromPoint.Y)
                    skeleton.Line.To = Vector2.new(toPoint.X, toPoint.Y)
                    skeleton.Line.Color = ESPSettings.SkeletonColor
                    skeleton.Line.Visible = true
                else
                    skeleton.Line.Visible = false
                end
            else
                skeleton.Line.Visible = false
            end
        end
    else
        for _, skeleton in pairs(espObject.SkeletonLines) do
            skeleton.Line.Visible = false
        end
    end
end

local function CreatePlayerESP(player)
    if player ~= LocalPlayer then
        ESPObjects[player] = CreateESPObject(player)
    end
end

local function RemovePlayerESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs({"BoxOutline", "Box", "Name", "Distance", "HealthBarBackground", "HealthBar", "HealthText"}) do
            if ESPObjects[player][drawing] then 
                ESPObjects[player][drawing]:Remove()
            end
        end
        
        for _, skeleton in pairs(ESPObjects[player].SkeletonLines) do
            if skeleton.Line then
                skeleton.Line:Remove()
            end
        end
        
        ESPObjects[player] = nil
    end
end

-- init esp
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreatePlayerESP(player)
    end
end

Players.PlayerAdded:Connect(CreatePlayerESP)
Players.PlayerRemoving:Connect(RemovePlayerESP)

local function PredictTargetPosition(targetPart)
    if not AimbotSettings.PredictionEnabled then
        return targetPart.Position
    end
    
    local velocity = targetPart.Velocity
    local predictionTime = AimbotSettings.PredictionStrength * 0.1
    return targetPart.Position + (velocity * predictionTime)
end

-- legit aimbot
local function LegitAimAtTarget(target)
    local targetPart = target.Character:FindFirstChild(AimbotSettings.TargetPart)
    if not targetPart then return end
    
    local currentTime = tick()
    local deltaTime = currentTime - lastAimUpdate
    lastAimUpdate = currentTime
    
    -- predict target position
    local targetPosition = PredictTargetPosition(targetPart)
    
    -- direction
    local camera = workspace.CurrentCamera
    local cameraPosition = camera.CFrame.Position
    local targetDirection = (targetPosition - cameraPosition).Unit
    
    -- current direction (kanye west)
    local currentDirection = camera.CFrame.LookVector
    
    -- smoothingfactor
    local smoothingFactor = math.min(deltaTime * AimbotSettings.Smoothness, 1)
    
    -- interpolation
    local newDirection = currentDirection:Lerp(targetDirection, smoothingFactor)
    
    -- rotation appliance
    local newCFrame = CFrame.lookAt(cameraPosition, cameraPosition + newDirection)
    camera.CFrame = newCFrame
end

-- speedo rocket dont forget to tik tok it
local function LockAimAtTarget(target)
    local targetPart = target.Character:FindFirstChild(AimbotSettings.TargetPart)
    if not targetPart then return end
    
    -- lock
    local camPos = Camera.CFrame.Position
    local targetPosition = PredictTargetPosition(targetPart)
    local newCFrame = CFrame.lookAt(camPos, targetPosition)
    Camera.CFrame = newCFrame
end

-- aimbot func
local function AimAtTarget()
    if not AimbotSettings.Enabled then 
        return 
    end
    
    if not UserInputService:IsKeyDown(AimbotSettings.Key) then 
        currentTarget = nil
        targetLockTime = 0
        return 
    end
    
    local target = GetClosestPlayerToMouse()
    if not target or not target.Character then 
        if frameCounter % 120 == 0 then
            --print("shit")
        end
        currentTarget = nil
        targetLockTime = 0
        return 
    end

    -- target
    if currentTarget ~= target then
        --new target
    end

    -- target consist
    if currentTarget ~= target then
        currentTarget = target
        targetLockTime = tick()
    end
    
    -- aimbot set
    if AimbotSettings.Mode == "Legit" then
        LegitAimAtTarget(target)
    elseif AimbotSettings.Mode == "Lock" then
        LockAimAtTarget(target)
    end
end

-- optimization trickery
local lastWorldUpdate = 0
RunService.RenderStepped:Connect(function(deltaTime)
    frameCounter = frameCounter + 1
    local currentTime = tick()
    
    -- functions
    UpdateMousePosition()
    UpdatePlayerCache()
    UpdateFOVCircle()

    -- esp
    if ESPSettings.Enabled then
        for player, espObject in pairs(ESPObjects) do
            if player and player.Parent then
                UpdateESPObject(espObject, currentTime, false)
            end
        end
    end

    local function UpdateAimbot()
        if AimbotSettings.Enabled then
            AimAtTarget()
        end
    end
    -- aimbot
    UpdateAimbot()
    
    -- movement
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        -- walkspeed
        humanoid.WalkSpeed = MiscSettings.WalkSpeed
    end

    -- world settings
    if WorldSettings.CustomAtmosphere and currentTime - lastWorldUpdate > 0.1 then
        local lighting = game:GetService("Lighting")
        
        if WorldSettings.BrightEnabled then
            lighting.Brightness = WorldSettings.Brightness
            lighting.Ambient = WorldSettings.Ambient
            lighting.OutdoorAmbient = WorldSettings.OutdoorAmbient
        end
        
        if WorldSettings.FogEnabled then
            lighting.FogStart = WorldSettings.FogStart
            lighting.FogEnd = WorldSettings.FogEnd
            lighting.FogColor = WorldSettings.FogColor
        end
        
        lastWorldUpdate = currentTime
    end
end)

-- ui
local AimSection = Tabs.Aim:AddSection("Aimbot")

AimSection:AddToggle("AimbotToggle", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(value)
        AimbotSettings.Enabled = value
    end
})

AimSection:AddDropdown("AimbotModeDropdown", {
    Title = "Aimbot Mode",
    Values = {"Lock", "Legit"},
    Default = "Lock",
    Callback = function(value)
        AimbotSettings.Mode = value
    end
})

AimSection:AddKeybind("AimbotKey", {
    Title = "Aimbot Key",
    Default = "E",
    Callback = function(value)
        -- keycode or string
        if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
            AimbotSettings.Key = value
        elseif typeof(value) == "string" then
            -- string to keycode
            local success, keyCode = pcall(function()
                return Enum.KeyCode[value]
            end)
            if success and keyCode then
                AimbotSettings.Key = keyCode
            else
                warn("Invalid key: " .. tostring(value))
                AimbotSettings.Key = Enum.KeyCode.E -- Default fallback
            end
        else
            warn("Unexpected keybind value type: " .. typeof(value))
            AimbotSettings.Key = Enum.KeyCode.E -- Default fallback
        end
        
        print("Aimbot key set to:", AimbotSettings.Key.Name)
    end
})


-- Legit Mode Settings Section
local LegitSection = Tabs.Aim:AddSection("Legit Mode Settings")

LegitSection:AddSlider("SmoothnessSlider", {
    Title = "Smoothness",
    Description = "Lower = Smoother, Higher = Snappier",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(value)
        AimbotSettings.Smoothness = value
    end
})

LegitSection:AddToggle("PredictionToggle", {
    Title = "Target Prediction",
    Default = false,
    Callback = function(value)
        AimbotSettings.PredictionEnabled = value
    end
})

LegitSection:AddSlider("PredictionStrengthSlider", {
    Title = "Prediction Strength",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Callback = function(value)
        AimbotSettings.PredictionStrength = value
    end
})

-- General Aimbot Settings Section
local GeneralAimSection = Tabs.Aim:AddSection("General Settings")

GeneralAimSection:AddToggle("WallCheckToggle", {
    Title = "Wall Check",
    Default = false,
    Callback = function(value)
        AimbotSettings.WallCheck = value
    end
})

GeneralAimSection:AddSlider("DistanceCapSlider", {
    Title = "Distance Cap",
    Default = 500,
    Min = 10,
    Max = 2000,
    Rounding = 0,
    Callback = function(value)
        AimbotSettings.DistanceCap = value
    end
})

GeneralAimSection:AddDropdown("TargetPartDropdown", {
    Title = "Target Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Callback = function(value)
        AimbotSettings.TargetPart = value
    end
})

-- FOV Settings Section
local FOVSection = Tabs.Aim:AddSection("FOV Circle")

FOVSection:AddToggle("FOVToggle", {
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(value)
        AimbotSettings.FOVEnabled = value
    end
})

FOVSection:AddSlider("FOVSlider", {
    Title = "FOV Size",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        AimbotSettings.FOVSize = value
    end
})

FOVSection:AddColorpicker("FOVColor", {
    Title = "FOV Circle Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        AimbotSettings.FOVColor = value
    end
})

FOVSection:AddToggle("FOVFilledToggle", {
    Title = "Fill FOV Circle",
    Default = false,
    Callback = function(value)
        AimbotSettings.FOVFilled = value
    end
})

FOVSection:AddSlider("FOVTransparency", {
    Title = "FOV Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        AimbotSettings.FOVTransparency = value
    end
})

-- esp
local ESPMainSection = Tabs.ESP:AddSection("ESP")

ESPMainSection:AddToggle("ESPToggle", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.Enabled = value
    end
})

ESPMainSection:AddSlider("ESPDistanceSlider", {
    Title = "Max Display Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Callback = function(value)
        ESPSettings.MaxDisplayDistance = value
    end
})

local BoxESPSection = Tabs.ESP:AddSection("Box ESP")

BoxESPSection:AddToggle("BoxESPToggle", {
    Title = "Box ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.BoxEnabled = value
    end
})

BoxESPSection:AddColorpicker("BoxESPColor", {
    Title = "Box Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        ESPSettings.BoxColor = value
    end
})

local NameESPSection = Tabs.ESP:AddSection("Name ESP")

NameESPSection:AddToggle("NameESPToggle", {
    Title = "Name ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.NameEnabled = value
    end
})

NameESPSection:AddColorpicker("NameESPColor", {
    Title = "Name Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        ESPSettings.NameColor = value
    end
})

local DistanceESPSection = Tabs.ESP:AddSection("Distance ESP")

DistanceESPSection:AddToggle("DistanceESPToggle", {
    Title = "Distance ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.DistanceEnabled = value
    end
})

DistanceESPSection:AddColorpicker("DistanceESPColor", {
    Title = "Distance Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(value)
        ESPSettings.DistanceColor = value
    end
})

local HealthBarESPSection = Tabs.ESP:AddSection("Health Bar ESP")

HealthBarESPSection:AddToggle("HealthBarESPToggle", {
    Title = "Health Bar ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.HealthBarEnabled = value
    end
})

HealthBarESPSection:AddColorpicker("HealthBarESPColor", {
    Title = "Health Bar Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(value)
        ESPSettings.HealthBarColor = value
        ESPSettings.HealthTextColor = value
    end
})

HealthBarESPSection:AddColorpicker("HealthTextColor", {
    Title = "Health Text Color", 
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        ESPSettings.HealthTextColor = value
    end
})

HealthBarESPSection:AddColorpicker("HealthBarBackgroundColor", {
    Title = "Health Bar Background",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        ESPSettings.HealthBarBackgroundColor = value
    end
})

local SkeletonESPSection = Tabs.ESP:AddSection("Skeleton ESP")

SkeletonESPSection:AddToggle("SkeletonESPToggle", {
    Title = "Skeleton ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.SkeletonEnabled = value
    end
})

SkeletonESPSection:AddColorpicker("SkeletonESPColor", {
    Title = "Skeleton Color",
    Default = Color3.fromRGB(0, 0, 255),
    Callback = function(value)
        ESPSettings.SkeletonColor = value
    end
})

-- misc
local NoSpreadSection = Tabs.Misc:AddSection("NoSpread")

NoSpreadSection:AddToggle("NoSpreadToggle", {
    Title = "NoSpread Toggle",
    Default = false,
    Callback = function(value)
        MiscSettings.NoSpread = value
    end
})

NoSpreadSection:AddSlider("NoSpreadPower", {
    Title = "NoSpread Power (DOESNT WORK YET)",
    Default = 80,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        MiscSettings.NoSpreadPower = value
    end
})

local MovementSection = Tabs.Misc:AddSection("Movement")

MovementSection:AddSlider("WalkSpeedSlider", {
    Title = "Walk Speed",
    Default = 16,
    Min = 8,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        MiscSettings.WalkSpeed = value
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

MovementSection:AddToggle("GlideToggle", {
    Title = "Glide",
    Default = false,
    Callback = function(value)
        MiscSettings.Glide = value
    end
})

-- world
-- Status Bar Section
local StatusBarSection = Tabs.Modulation:AddSection("Status Bar")

local themeColors = {
    Dark = Color3.fromRGB(40, 40, 40),
    Darker = Color3.fromRGB(20, 20, 20),
    Amoled = Color3.fromRGB(0, 0, 0),
    Light = Color3.fromRGB(240, 240, 240),
    Balloon = Color3.fromRGB(218, 239, 255),
    SoftCream = Color3.fromRGB(248, 238, 214),
    Aqua = Color3.fromRGB(25, 90, 103),
    Amethyst = Color3.fromRGB(40, 21, 62),
    Rose = Color3.fromRGB(56, 28, 42),
    Midnight = Color3.fromRGB(11, 11, 36),
    Forest = Color3.fromRGB(22, 38, 27),
    Sunset = Color3.fromRGB(54, 30, 23),
    Ocean = Color3.fromRGB(19, 27, 44),
    Emerald = Color3.fromRGB(22, 47, 40),
    Sapphire = Color3.fromRGB(13, 24, 61),
    Cloud = Color3.fromRGB(23, 61, 75),
    Grape = Color3.fromRGB(12, 6, 24),
}

local statusBarToggle = StatusBarSection:AddToggle("StatusBarToggle", {
    Title = "Show Status Bar",
    Description = "Display FPS and ping information at the top of screen",
    Default = false,
})

StatusBarSection:AddDropdown("ThemeSelector", {
    Title = "Status Bar Theme",
    Description = "Choose the background color theme for the status bar",
    Values = {"Dark", "Darker", "Amoled", "Light", "Balloon", "SoftCream", "Aqua", "Amethyst", "Rose", "Midnight", "Forest", "Sunset", "Ocean", "Emerald", "Sapphire", "Cloud", "Grape"},
    Multi = false,
    Default = "Dark",
}):OnChanged(function(themeName)
    if WatermarkFrame and themeColors[themeName] then
        local color = themeColors[themeName]
        WatermarkFrame.BackgroundColor3 = color
        
        -- Set text color based on theme
        local textColor = Color3.fromRGB(230, 230, 230) -- Default white text
        if themeName == "Light" or themeName == "SoftCream" or themeName == "Balloon" then
            textColor = Color3.fromRGB(0, 0, 0) -- Black text for light themes
        end
        
        for _, child in ipairs(WatermarkFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = textColor
            end
        end
    end
end)

statusBarToggle:OnChanged(function(val)
    statusBarEnabled = val
    if val then
        if not WatermarkFrame then
            WatermarkFrame = CreateWatermark()
        end
        WatermarkFrame.Visible = true
    else
        if WatermarkFrame then
            WatermarkFrame.Visible = false
        end
    end
end)

StatusBarSection:AddSlider("StatusBarTransparency", {
    Title = "Status Bar Transparency",
    Description = "Adjust the background transparency of the status bar",
    Min = 0,
    Max = 1,
    Default = 0.3,
    Rounding = 2,
    Callback = function(val)
        if WatermarkFrame then
            WatermarkFrame.BackgroundTransparency = val
        end
    end,
})

StatusBarSection:AddSlider("StatusBarPosX", {
    Title = "Status Bar X Position",
    Description = "Adjust the horizontal (X) position of the status bar",
    Min = -800,
    Max = 800,
    Default = 0,
    Rounding = 0,
    Callback = function(xOffset)
        if WatermarkFrame then
            WatermarkFrame.Position = UDim2.new(0.5, xOffset, WatermarkFrame.Position.Y.Scale, WatermarkFrame.Position.Y.Offset)
        end
    end,
})

StatusBarSection:AddSlider("StatusBarPosY", {
    Title = "Status Bar Y Position",
    Description = "Adjust the vertical (Y) position of the status bar",
    Min = -61,
    Max = 921,
    Default = 5,
    Rounding = 0,
    Callback = function(yOffset)
        if WatermarkFrame then
            WatermarkFrame.Position = UDim2.new(WatermarkFrame.Position.X.Scale, WatermarkFrame.Position.X.Offset, 0, yOffset)
        end
    end,
})
local WorldSection = Tabs.Modulation:AddSection("Atmosphere")

WorldSection:AddToggle("CustomAtmosphereToggle", {
    Title = "Custom Atmosphere",
    Default = false,
    Callback = function(value)
        WorldSettings.CustomAtmosphere = value
    end
})

local BrightnessSection = Tabs.Modulation:AddSection("Brightness")

BrightnessSection:AddToggle("BrightnessToggle", {
    Title = "Custom Brightness",
    Default = false,
    Callback = function(value)
        WorldSettings.BrightEnabled = value
    end
})

BrightnessSection:AddSlider("BrightnessSlider", {
    Title = "Brightness",
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(value)
        WorldSettings.Brightness = value
    end
})

BrightnessSection:AddColorpicker("AmbientColor", {
    Title = "Ambient Color",
    Default = Color3.fromRGB(127, 127, 127),
    Callback = function(value)
        WorldSettings.Ambient = value
    end
})

BrightnessSection:AddColorpicker("OutdoorAmbientColor", {
    Title = "Outdoor Ambient",
    Default = Color3.fromRGB(127, 127, 127),
    Callback = function(value)
        WorldSettings.OutdoorAmbient = value
    end
})

local FogSection = Tabs.Modulation:AddSection("Fog")

FogSection:AddToggle("FogToggle", {
    Title = "Custom Fog",
    Default = false,
    Callback = function(value)
        WorldSettings.FogEnabled = value
    end
})

FogSection:AddColorpicker("FogColor", {
    Title = "Fog Color",
    Default = Color3.fromRGB(100, 100, 100),
    Callback = function(value)
        WorldSettings.FogColor = value
    end
})

FogSection:AddSlider("FogStartSlider", {
    Title = "Fog Start",
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        WorldSettings.FogStart = value
    end
})

FogSection:AddSlider("FogEndSlider", {
    Title = "Fog End",
    Default = 300,
    Min = 10,
    Max = 2000,
    Rounding = 0,
    Callback = function(value)
        WorldSettings.FogEnd = value
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    --if input.KeyCode == Enum.KeyCode.T then -- T test
    --    print("=== AIMBOT DEBUG TEST ===")
    --    print("Aimbot Enabled:", AimbotSettings.Enabled)
    --    print("Aimbot Mode:", AimbotSettings.Mode)
    --    print("FOV Size:", AimbotSettings.FOVSize)
    --    print("Distance Cap:", AimbotSettings.DistanceCap)
    --    print("Target Part:", AimbotSettings.TargetPart)
    --    print("Key:", AimbotSettings.Key)
        
        local playersFound = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                playersFound = playersFound + 1
                --print("Player found:", player.Name, "Alive:", IsAlive(player))
            end
        end
        --print("Total other players:", playersFound)
        
        -- test
        --local target = GetClosestPlayerToMouse()
        --if target then
        --    print("Closest target:", target.Name)
        --else
        --    print("No target found in FOV/range")
        --end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)


SaveManager:SetFolder("AcidHub")
SaveManager:BuildConfigSection(Tabs.Misc)


InterfaceManager:SetFolder("AcidHub/Dahood")
InterfaceManager:BuildInterfaceSection(Tabs.Misc)


SaveManager:LoadAutoloadConfig()


local function cleanupScriptBeforeClosing()
    
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    
    for player, espObject in pairs(ESPObjects) do
        RemovePlayerESP(player)
    end
    
    
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.Ambient = Color3.fromRGB(0, 0, 0)
    lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    lighting.FogStart = 0
    lighting.FogEnd = 100000
    lighting.FogColor = Color3.fromRGB(192, 192, 192)
end

game:GetService(coregui).ChildRemoved:Connect(function(child)
    if child.Name == "ScreenGui" and child:FindFirstChild("Acid") then
        cleanupScriptBeforeClosing()
    end
end)

Fluent:Notify({
    Title = "Acid",
    Content = "Loaded DaHood script",
    Duration = 5
})

return Window
