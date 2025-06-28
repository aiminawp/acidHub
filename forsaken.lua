local Fluent = loadstring(Game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local WatermarkEnabled = false
local WatermarkFrame = nil
local playerESP = loadstring(game:HttpGet("https://raiidev.xyz/lib/newesp.lua"))()
playerESP.Settings.MaxDistance = 1000
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
Lighting.Technology = Enum.Technology.Compatibility
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 4
FOVCircle.NumSides = 50
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local AimbotEnabled = false
local AimbotKey = Enum.KeyCode.E
local AimbotKeyPressed = false
local CurrentTarget = nil

local AntiAimSettings = {
    Enabled = false,
    Mode = "Random",
    Speed = 3
}

local AntiAimConnection = nil
local SpinBodyVelocity = nil
local ChanceSettings = {
    Enabled = false,
    FOVRadius = 100,
    MaxDistance = 500,
    FOVCircleEnabled = false,
    FOVCircleColor = Color3.fromRGB(255, 255, 255),
    AimbotKey = Enum.KeyCode.E
}
local function getRoot(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function StartSpinMode()
    if SpinBodyVelocity then
        SpinBodyVelocity:Destroy()
    end
    
    local root = getRoot(LocalPlayer.Character)
    if not root then return end

    for i, v in pairs(root:GetChildren()) do
        if v.Name == "Spinning" then
            v:Destroy()
        end
    end
    
    local Spin = Instance.new("BodyAngularVelocity")
    Spin.Name = "Spinning"
    Spin.Parent = root
    Spin.MaxTorque = Vector3.new(0, math.huge, 0)
    Spin.AngularVelocity = Vector3.new(0, AntiAimSettings.Speed, 0)
    
    SpinBodyVelocity = Spin
end

local function StartRandomMode()
    if AntiAimConnection then
        AntiAimConnection:Disconnect()
        AntiAimConnection = nil
    end

    local angles = {0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180}
    local currentAngle = 180
    local jitterTime = 0

    AntiAimConnection = RunService.RenderStepped:Connect(function()
        if not AntiAimSettings.Enabled then
            StopAntiAim()
            return
        end

        local root = getRoot(LocalPlayer.Character)
        if not root then return end

        jitterTime = jitterTime + 1
        if jitterTime >= math.max(1, 10 - AntiAimSettings.Speed) then
            currentAngle = angles[math.random(1, #angles)]
            jitterTime = 0
        end

        local radians = math.rad(currentAngle)
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, radians, 0)
    end)
end


local function StopAntiAim()
    if AntiAimConnection then
        AntiAimConnection:Disconnect()
        AntiAimConnection = nil
    end

    if SpinBodyVelocity then
        SpinBodyVelocity:Destroy()
        SpinBodyVelocity = nil
    end

    local root = getRoot(LocalPlayer.Character)
    if root then
        for _, v in pairs(root:GetChildren()) do
            if v.Name == "Spinning" then
                v:Destroy()
            end
        end
    end
end



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
    
    -- goofy a
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

local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    -- im sensing sum sus activity over here :fire:
    local killersFolder = workspace:FindFirstChild("Players")
    if killersFolder then
        local killers = killersFolder:FindFirstChild("Killers")
        if killers then
            for _, player in pairs(killers:GetChildren()) do
                if player:FindFirstChild("HumanoidRootPart") and player:FindFirstChild("Humanoid") then
                    if player.Humanoid.Health > 0 then
                        local worldDistance = (player.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if worldDistance <= ChanceSettings.MaxDistance then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(player.HumanoidRootPart.Position)
                            
                            if onScreen then
                                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                
                                if screenDistance <= ChanceSettings.FOVRadius and screenDistance < shortestDistance then
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


local function AimAtTarget(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.HumanoidRootPart.Position
        local cameraPosition = Camera.CFrame.Position
        local directionToTarget = (targetPosition - cameraPosition).Unit
        local cameraRight = Camera.CFrame.RightVector
        local cameraUp = Camera.CFrame.UpVector
        local rightOffset = 0.0155  -- positive = right, negative = left
        local upOffset = 0.0     -- positive = up, negative = down
        local offsetDirection = directionToTarget + (cameraRight * rightOffset) + (cameraUp * upOffset)
        offsetDirection = offsetDirection.Unit
        Camera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + offsetDirection)
    end
end

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
    Creds = Window:AddTab({ Title = "Credits", Icon = "" }),
    Aimbot = Window:AddTab({ Title = "Combat", Icon = ""}),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = ""}),
    Modulation = Window:AddTab({ Title = "Modulation", Icon = ""}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "" })
}

local ESPSettings = {
    Enabled = false,
    Types = {},
    Color = Color3.fromRGB(255, 255, 255)
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


local Options = Fluent.Options

    Tabs.Creds:AddParagraph({
        Title = "Klyte",
        Content = "_klyte_"
    })

    Tabs.Creds:AddParagraph({
        Title = "raii",
        Content = "https://raiidev.xyz awesome esp ;)"
    })

local ChanceSection = Tabs.Aimbot:AddSection("Chance")

ChanceSection:AddToggle("Chancebot", {
    Title = "Enable Chancebot",
    Description = "Aimbot for chance",
    Default = false,
    Callback = function(value)
        ChanceSettings.Enabled = value
        if not value then
            CurrentTarget = nil
        end
    end
})

ChanceSection:AddKeybind("AimbotKeybind", {
    Title = "Chancebot Key",
    Description = "Key to hold for chancebot",
    Default = "E",
    Callback = function(key)
        ChanceSettings.AimbotKey = key
    end
})

ChanceSection:AddSlider("FOVRadiusSlider", {
    Title = "FOV Radius",
    Description = "Adjust the FOV radius for chancebot targeting",
    Min = 20,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Callback = function(value)
        ChanceSettings.FOVRadius = value
        FOVCircle.Radius = value
    end
})

ChanceSection:AddSlider("MaxDistanceSlider", {
    Title = "Max Distance",
    Description = "Maximum distance for aimbot targeting (studs)",
    Min = 50,
    Max = 2000,
    Default = 500,
    Rounding = 0,
    Callback = function(value)
        ChanceSettings.MaxDistance = value
    end
})

ChanceSection:AddToggle("FOVCircleToggle", {
    Title = "FOV Circle",
    Description = "Show FOV circle",
    Default = false,
    Callback = function(value)
        ChanceSettings.FOVCircleEnabled = value
        FOVCircle.Visible = value
    end
})

ChanceSection:AddColorpicker("FOVColor", {
    Title = "FOV Circle Color",
    Description = "Choose the color for FOV circle",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        ChanceSettings.FOVCircleColor = value
        FOVCircle.Color = value
    end
})

local AntiAimSection = Tabs.Aimbot:AddSection("Anti-Aim")

AntiAimSection:AddToggle("AntiAimToggle", {
    Title = "Enable Anti-Aim",
    Description = "Toggle anti-aim functionality",
    Default = false,
    Callback = function(value)
        AntiAimSettings.Enabled = value
        
        if value then
            if AntiAimSettings.Mode == "Spin" then
                StartSpinMode()
            else
                StartRandomMode()
            end
        else
            StopAntiAim()
        end
    end
})

AntiAimSection:AddDropdown("AntiAimMode", {
    Title = "Anti-Aim Mode",
    Description = "Choose anti-aim mode",
    Values = {"Spin", "Random"},
    Multi = false,
    Default = "Random",
    Callback = function(value)
        AntiAimSettings.Mode = value

        if AntiAimSettings.Enabled then
            StopAntiAim()
            if value == "Spin" then
                StartSpinMode()
            else
                StartRandomMode()
            end
        end
    end
})

AntiAimSection:AddSlider("AntiAimSpeed", {
    Title = "Anti-Aim Speed",
    Description = "Adjust the speed of anti-aim",
    Min = 1,
    Max = 10,
    Default = 3,
    Rounding = 0,
    Callback = function(value)
        AntiAimSettings.Speed = value
        if AntiAimSettings.Enabled then
            if AntiAimSettings.Mode == "Spin" and SpinBodyVelocity then
                SpinBodyVelocity.AngularVelocity = Vector3.new(0, value, 0)
            end
        end
    end
})


local ESPSection = Tabs.Visuals:AddSection("ESP")

ESPSection:AddToggle("ESPToggle", {
    Title = "Enable ESP",
    Description = "Toggle ESP visibility",
    Default = false,
    Callback = function(value)
        playerESP.Settings.ShowExtra = value
        playerESP.Settings.Enabled = value
    end
})

ESPSection:AddToggle("NameESPToggle", {
    Title = "Name",
    Description = "Show name",
    Default = false,
    Callback = function(value)
        playerESP.Settings.ShowName = value
    end
})

ESPSection:AddToggle("HealthBarToggle", {
    Title = "Healthbar",
    Description = "Toggle healthbar visibility",
    Default = false,
    Callback = function(value)
        playerESP.Settings.ShowHealthBar = value
    end
})

ESPSection:AddToggle("BoxESPToggle", {
    Title = "Box",
    Description = "Showbox",
    Default = false,
    Callback = function(value)
        playerESP.Settings.ShowBox = value
    end
})

ESPSection:AddToggle("DistanceESPToggle", {
    Title = "Distance",
    Description = "Show distance",
    Default = false,
    Callback = function(value)
        playerESP.Settings.ShowDistance = value
    end
})

ESPSection:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Description = "Choose the color for ESP elements",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        playerESP.Settings.ExtraColor = value
        playerESP.Settings.DistanceColor = value
        playerESP.Settings.NameColor = value
        playerESP.Settings.TextColor = value
        playerESP.Settings.BoxColor = value
        playerESP:UpdateColors()
    end
})

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

        local textColor = Color3.fromRGB(230, 230, 230) -- default white text
        if themeName == "Light" or themeName == "SoftCream" or themeName == "Balloon" then
            textColor = Color3.fromRGB(0, 0, 0) -- black text for light themes
        end
        
        for _, child in ipairs(WatermarkFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = textColor
            end
        end
    end
end)

statusBarToggle:OnChanged(function(val)
    WatermarkEnabled = val
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


local BrightnessSection = Tabs.Modulation:AddSection("World")

BrightnessSection:AddToggle("BrightnessToggle", {
    Title = "Custom Modulation",
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


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AcidHub")
SaveManager:SetFolder("AcidHub/Forsaken")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Acid",
    Content = "Loaded Forsaken.lua",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()

RunService.RenderStepped:Connect(function()
    if WorldSettings.BrightEnabled then
        Lighting.Brightness = WorldSettings.Brightness
        Lighting.Ambient = WorldSettings.Ambient
        Lighting.OutdoorAmbient = WorldSettings.OutdoorAmbient
    end

    if WorldSettings.FogEnabled then
        Lighting.FogColor = WorldSettings.FogColor
        Lighting.FogStart = WorldSettings.FogStart
        Lighting.FogEnd = WorldSettings.FogEnd
    else
        Lighting.FogStart = 100000
        Lighting.FogEnd = 100001
    end

    if WorldSettings.CustomAtmosphere then
        if not Lighting:FindFirstChildOfClass("Atmosphere") then
            local atmosphere = Instance.new("Atmosphere")
            atmosphere.Density = 0.3
            atmosphere.Parent = Lighting
        end
    else
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            atm:Destroy()
        end
    end
end)

if not Lighting:FindFirstChild("AcidBrightnessCorrection") then
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "AcidBrightnessCorrection"
    cc.Brightness = 0
    cc.Parent = Lighting
end

local brightnessEffect = Lighting:FindFirstChild("AcidBrightnessCorrection")

RunService.RenderStepped:Connect(function()
    -- dis doesnt work but im too lazy to fix
    if WorldSettings.BrightEnabled then
        Lighting.Brightness = WorldSettings.Brightness
        Lighting.Ambient = WorldSettings.Ambient
        Lighting.OutdoorAmbient = WorldSettings.OutdoorAmbient
        if brightnessEffect then
            brightnessEffect.Brightness = (WorldSettings.Brightness - 1) * 0.5
        end
    else
        if brightnessEffect then
            brightnessEffect.Brightness = 0
        end
    end

    -- fock
    if WorldSettings.FogEnabled then
        Lighting.FogColor = WorldSettings.FogColor
        Lighting.FogStart = WorldSettings.FogStart
        Lighting.FogEnd = WorldSettings.FogEnd
    else
        Lighting.FogStart = 100000
        Lighting.FogEnd = 100001
    end

    -- atmosphere
    if WorldSettings.CustomAtmosphere then
        if not Lighting:FindFirstChildOfClass("Atmosphere") then
            local atmosphere = Instance.new("Atmosphere")
            atmosphere.Density = 0.3
            atmosphere.Parent = Lighting
        end
    else
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            atm:Destroy()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == ChanceSettings.AimbotKey and ChanceSettings.Enabled then
        AimbotKeyPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == ChanceSettings.AimbotKey then
        AimbotKeyPressed = false
        CurrentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if ChanceSettings.FOVCircleEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if ChanceSettings.Enabled and AimbotKeyPressed then
        local target = GetClosestPlayerInFOV()
        if target then
            CurrentTarget = target
            AimAtTarget(target)
        end
    else
        CurrentTarget = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if AntiAimSettings.Enabled then
        wait(4)
        if AntiAimSettings.Mode == "Spin" then
            StartSpinMode()
        else
            StartRandomMode()
        end
    end
end)
