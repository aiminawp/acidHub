local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local walkingRageAutoPlant = false
local autoBuy = false
local antiAfk = false
local autoFarm = false
local autoFarmMode = "Rage"
local autoFarmInterval = 0.03
local selectedBuyFruits = {}
local selectedHoneyItems = {}
local selectedGearItems = {}
local selectedFarmFruits = {}
local autoSlotSpam = false
local slotMin = 1
local slotMax = 5
local slotDelay = 2
local autoSell = false
local sellInterval = 20
local autoCollect = false
local autoCollectMode = ""
local autoCollectInterval = 0.1
local autoCollectRange = 13
local selectedCollectFruits = {}
local selectedCollectMiscFruits = {}
local positionDelay = 0.05
local walkingRageMode = false
local walkingRageSpeed = 16
local walkingRagePlotIndex = 1
local currentWalkingTarget = nil
local isWalkingToTarget = false
local noclipConnection = nil
local noclipEnabled = false
local originalBrightness = game.Lighting.Brightness
local originalAmbient = game.Lighting.Ambient
local originalFloorColor = nil
local statusBarEnabled = false
local statusBarFrame = nil
local topBaseplate = workspace:FindFirstChild("TopBaseplate")
if topBaseplate then
    originalFloorColor = topBaseplate.Color
end
local customPromptPaths2 = {
    Foxglove = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Foxglove")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,
    
    Rose = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Rose")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Lavender = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Lavender")
        local child = named and named:FindFirstChild("Base")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Lilac = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Lilac")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Succulent = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Succulent")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Pink Lily"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Pink Lily")
        local child = named and named:FindFirstChild("Base")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Purple Dahlia"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Purple Dahlia")
        local child = named and named:FindFirstChild("Base")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Moon Melon"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Purple Dahlia")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Moon Mango"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Moon Mango")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Cocovine = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Cocovine")
        local child = named and named:FindFirstChild("3")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Starfruit = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Starfruit")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Honeysuckle = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Honeysuckle")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Durian = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Durian")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Cranberry = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Cranberry")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Nectarine = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Nectarine")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Peach = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Peach")
        local child = named and named:FindFirstChild("Primary")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Easter Egg"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Easter Egg")
        local child = named and named:FindFirstChild("Base")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Violet Corn"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Violet Corn")
        local child = named and named:FindFirstChild("3")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Hive Fruit"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Hive Fruit")
        local child = named and named:FindFirstChild("Base")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,
}
local customPromptPaths = {
    Bamboo = function(plant)
        local base = plant:FindFirstChild("Base")
        return base and base:FindFirstChildOfClass("ProximityPrompt")
    end,

    Apple = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Apple")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Carrot = function(plant)
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Mushroom = function(plant)
        local child = plant:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    
    Watermelon = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Watermelon")
        local child = named and named:FindFirstChild("5")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    ["Ember Lily"] = function(plant)
        local fruits = plant:FindFirstChild("Fruits")
        local named = fruits and fruits:FindFirstChild("Ember Lily")
        local base = named and named:FindFirstChild("Base")
        return base and base:FindFirstChildOfClass("ProximityPrompt")
    end,

    Mango = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Mango")
        local child = named and named:FindFirstChild("1")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Beanstalk = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Beanstalk")
        local child = named and named:FindFirstChild("5")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Cacao = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Cacao")
        local child = named and named:FindFirstChild("3")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Tomato = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Tomato")
        local child = named and named:FindFirstChild("3")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Corn = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Corn")
        local child = named and named:FindFirstChild("3")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Strawberry = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Strawberry")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,

    Blueberry = function(plant)
        local named = plant:FindFirstChild("Fruits"):FindFirstChild("Blueberry")
        local child = named and named:FindFirstChild("2")
        return child and child:FindFirstChildOfClass("ProximityPrompt")
    end,
}
local honeyItems = {
    "Flower Seed Pack", "Lavender", "Nectarshade", "Nectarine", "Hive Fruit", "Pollen Radar", "Nectar Staff", "Honey Sprinkler", "Bee Egg", "Bee Crate", "Honey Comb", "Bee Chair", "Honey Torch", "Honey Walkway"
}

local gearItems = {
    "Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler", "Godly Sprinkler", "Lighting Rod", "Master Sprinkler", "Cleaning Spray", "Favorite Tool", "Harvest Tool", "Friendship Pot"
}

local allFruits = {
    "Sugar Apple", "Ember Lily", "Beanstalk", "Cacao", "Pepper", "Mushroom", "Grape", "Mango", "Dragon Fruit",
    "Cactus", "Coconut", "Bamboo", "Apple", "Pumpkin", "Watermelon", "Daffodil", "Corn", "Tomato",
    "Orange Tulip", "Blueberry", "Strawberry", "Carrot"
}

local miscFruits = {
    "Foxglove", "Rose", "Lavender", "Nectarshade", "Nectarine", "Hive Fruit", "Lilac", "Pink Lily", "Purple Dahlia", "Sunflower", "Cocovine", "Succulent", "Violet Corn", "Moon Melon", "Moon Mango", "Starfruit", "Durian", "Cranberry", "Peach", "Easter Egg", "Violet Corn", "Hive Fruit", "Honeysuckle"
}

local plots = {
    {
        name = "Plot 1",
        min = Vector3.new(-4.27, 0, -135),
        max = Vector3.new(71, 0, -74),
        center = Vector3.new(( -4.27 + 71 ) / 2, 5, (-135 + -74) / 2)
    },
    {
        name = "Plot 2",
        min = Vector3.new(-137, 0, -135),
        max = Vector3.new(-61, 0, -74),
        center = Vector3.new((-137 + -61) / 2, 5, (-135 + -74) / 2)
    },
    {
        name = "Plot 3",
        min = Vector3.new(-274, 0, -135),
        max = Vector3.new(-198, 0, -74),
        center = Vector3.new((-274 + -198) / 2, 5, (-135 + -74) / 2)
    },
    {
        name = "Plot 4",
        min = Vector3.new(-274, 0, 47),
        max = Vector3.new(-197, 0, 105),
        center = Vector3.new((-274 + -197) / 2, 5, (47 + 105) / 2)
    },
    {
        name = "Plot 5",
        min = Vector3.new(-139, 0, 47),
        max = Vector3.new(-52, 0, 105),
        center = Vector3.new((-139 + -52) / 2, 5, (47 + 105) / 2)
    },
    {
        name = "Plot 6",
        min = Vector3.new(-4, 0, 47),
        max = Vector3.new(73, 0, 105),
        center = Vector3.new((-4 + 73) / 2, 5, (47 + 105) / 2)
    },
}

local selectedPlotIndex = 1 -- default plot
-- status bar setup lmfao

local function CreateStatusBar()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- screen gui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StatusBar"
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


-- check pos in plot
local function isPositionInPlot(pos, plot)
    local min, max = plot.min, plot.max
    return pos.X >= math.min(min.X, max.X) and pos.X <= math.max(min.X, max.X)
       and pos.Z >= math.min(min.Z, max.Z) and pos.Z <= math.max(min.Z, max.Z)
end

-- noclip toggle
local function setNoclip(enabled)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    if enabled and not noclipEnabled then
        noclipEnabled = true

        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local state = humanoid:GetState()
                if state == Enum.HumanoidStateType.Climbing or state == Enum.HumanoidStateType.Seated then
                    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                end
            end
        end)

    elseif not enabled and noclipEnabled then
        noclipEnabled = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end



local function isPlantAtPosition(position)
    local workspace = game:GetService("Workspace")
    local plants = workspace:FindFirstChild("Plants")
    if not plants then return false end
    
    for _, plant in pairs(plants:GetChildren()) do
        if plant.PrimaryPart then
            local plantPos = plant.PrimaryPart.Position
            local distance = (Vector3.new(position.X, plantPos.Y, position.Z) - plantPos).Magnitude
            if distance < 3 then -- 3 stud radius
                return true
            end
        end
    end
    return false
end

local function getValidPlantingPositions()
    local plot = plots[selectedPlotIndex]
    local validPositions = {}
    local y = 0
    local stepSize = 2
    
    -- scan plot
    for x = math.max(plot.min.X, -352), math.min(plot.max.X, 142), stepSize do
        for z = math.max(plot.min.Z, -212), math.min(plot.max.Z, 185), stepSize do
            local pos = Vector3.new(x, y, z)
            if isPositionInPlot(pos, plot) and not isPlantAtPosition(pos) then
                table.insert(validPositions, pos)
            end
        end
    end
    
    return validPositions
end

-- get walk positions
local function getWalkingPositions(plotIndex)
    local plot = plots[plotIndex]
    local positions = {}
    local y = 5
    local stepSize = 8 -- hooking 420 functions for max efficiency
    
    local minX = math.max(plot.min.X, -352)
    local maxX = math.min(plot.max.X, 142)
    local minZ = math.max(plot.min.Z, -212)
    local maxZ = math.min(plot.max.Z, 185)
    
    -- snake pattern
    local goingRight = true
    for z = minZ, maxZ, stepSize do
        if goingRight then
            for x = minX, maxX, stepSize do
                local pos = Vector3.new(x, y, z)
                if isPositionInPlot(pos, plot) then
                    table.insert(positions, pos)
                end
            end
        else
            for x = maxX, minX, -stepSize do
                local pos = Vector3.new(x, y, z)
                if isPositionInPlot(pos, plot) then
                    table.insert(positions, pos)
                end
            end
        end
        goingRight = not goingRight
    end
    
    return positions
end

-- walk to pos
local function walkToPosition(position)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    if not humanoid or not hrp then return false end
    
    -- set speed
    humanoid.WalkSpeed = walkingRageSpeed
    
    -- move to pos
    humanoid:MoveTo(position)
    isWalkingToTarget = true
    currentWalkingTarget = position
    
    -- wait until reach pos
    local startTime = tick()
    local timeout = 5
    
    while isWalkingToTarget and walkingRageMode do
        local distance = (hrp.Position - position).Magnitude
        
        -- check if close enough
        if distance < 3 then
            isWalkingToTarget = false
            return true
        end
        
        -- timeout check
        if tick() - startTime > timeout then
            print("[Walking Rage] Timeout reaching position:", position)
            isWalkingToTarget = false
            return false
        end
        
        wait(0.1)
    end
    
    return false
end

-- tp to pos
local function teleportTo(position)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    if hrp then
        hrp.CFrame = CFrame.new(position)
        wait(0.5) -- delay
    end
end

-- buy seeds
local function buySeeds()
    for _, fruit in ipairs(selectedBuyFruits) do
        local args = {fruit}
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(unpack(args))
        wait(0.05)
    end
end

-- buy honey
local function buyHoney()
    for _, honeyItem in ipairs(selectedHoneyItems) do
        local args = {honeyItem}
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock"):FireServer(unpack(args))
        wait(0.05)
    end
end

-- buy gear
local function buyGear()
    for _, gearItem in ipairs(selectedGearItems) do
        local args = {
            {gearItem}
        }
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(unpack(args))
        wait(0.05)
    end
end

--local args = {
--	"Master Sprinkler"
--}
--game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(unpack(args))


-- sell inv
local function sellInventory()
    local start = tick()
    local Lplr = game.Players.LocalPlayer
    local oldpos = Lplr.Character.Head.Position
    Lplr.Character:MoveTo(workspace.NPCS.Steven.PrimaryPart.Position)
    repeat task.wait(.15) until Lplr.Character.Head.Position ~= oldpos
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
    wait(0.15)
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
    wait(0.15)
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
    wait(0.15)
    Lplr.Character:MoveTo(oldpos)
    print("[AutoSell] Sold all fruit in ",tick()-start, "seconds")
    Fluent:Notify({
    Title = "AutoSell",
    Content = "Sold inventory",
    Duration = 2,
    })
end

-- plant spam
local function plantAtPosition(position, fruit)
    for _ = 1, 3 do
        local args = {position, fruit}
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(unpack(args))
    end
end

-- plant single
local function plantSingleAtPosition(position, fruit)
    local args = {position, fruit}
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(unpack(args))
end

-- walking rage farm
local function walkingRageFarm()
    local walkingPositions = getWalkingPositions(walkingRagePlotIndex)
    
    if #walkingPositions == 0 then
        print("[Balkan Rage] No valid positions found in selected plot")
        return
    end
    
    print("[Balkan Rage] Starting walk through " .. #walkingPositions .. " positions")
    
    for i, position in ipairs(walkingPositions) do
        if not walkingRageMode then break end
        
        print("[Balkan Rage] Moving to position " .. i .. "/" .. #walkingPositions)
        
        -- walk to pos
        local success = walkToPosition(position)
        
        if success and walkingRageMode then
            -- plant if enabled
            if walkingRageAutoPlant and #selectedFarmFruits > 0 then
                for _, fruit in ipairs(selectedFarmFruits) do
                    if not walkingRageMode then break end
                    plantAtPosition(position, fruit)
                end
            end
            
            wait(positionDelay)
        end
    end
    
    print("[Balkan Rage] Completed walking pattern")
end

-- rage farm
local function rageAutoFarm()
    local validPositions = getValidPlantingPositions()
    
    if #validPositions == 0 then
        print("No valid positions found in selected plot")
        return
    end
    
    print("Found " .. #validPositions .. " valid positions to plant")
    
    for _, position in ipairs(validPositions) do
        for _, fruit in ipairs(selectedFarmFruits) do
            plantAtPosition(position, fruit)
        end
    end
end

-- legit farm
local function legitAutoFarm()
    local validPositions = getValidPlantingPositions()
    
    if #validPositions == 0 then
        print("No valid positions found in selected plot")
        return
    end
    
    print("Found " .. #validPositions .. " valid positions to plant")
    
    for _, position in ipairs(validPositions) do
        for _, fruit in ipairs(selectedFarmFruits) do
            plantSingleAtPosition(position, fruit)
            wait(autoFarmInterval)
        end
    end
end

-- tp to plot center
local function teleportToPlotCenter()
    local plot = plots[selectedPlotIndex]
    teleportTo(plot.center)
end

-- ui setup

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
    Credits = Window:AddTab({ Title = "Credits", Icon = "" }),
    AutoFarm = Window:AddTab({ Title = "Autofarm", Icon = "" }),
    WalkingRage = Window:AddTab({ Title = "Balkan Rage", Icon = "" }),
    AutoCollect = Window:AddTab({ Title = "Autocollect", Icon = "" }),
    AutoBuy = Window:AddTab({ Title = "Misc", Icon = "" }),
    Modulation = Window:AddTab({ Title = "Modulation", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "" }),
}

local statusBarToggle = Tabs.Modulation:AddToggle("StatusBarToggle", {
    Title = "Show Status Bar",
    Description = "Display FPS and ping information at the top of screen",
    Default = false,
})


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

Tabs.Modulation:AddDropdown("ThemeSelector", {
    Title = "Status Bar Theme",
    Description = "Choose the background color theme for the status bar",
    Values = {"Dark", "Darker", "Amoled", "Light", "Balloon", "SoftCream", "Aqua", "Amethyst", "Rose", "Midnight", "Forest", "Sunset", "Ocean", "Emerald", "Sapphire", "Cloud", "Grape"},
    Multi = false,
    Default = "Dark",
}):OnChanged(function(themeName)
    if statusBarFrame and themeColors[themeName] then
        local color = themeColors[themeName]
        statusBarFrame.BackgroundColor3 = color
        if themeName == "Light" or themeName == "SoftCream" or themeName == "Balloon" then
            for _, child in ipairs(statusBarFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = Color3.fromRGB(0, 0, 0)
                end
            end
        else
            for _, child in ipairs(statusBarFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = Color3.fromRGB(230, 230, 230)
                end
            end
        end
    end
end)

statusBarToggle:OnChanged(function(val)
    statusBarEnabled = val
    if val then
        if not statusBarFrame then
            statusBarFrame = CreateStatusBar()
        end
        statusBarFrame.Visible = true
    else
        if statusBarFrame then
            statusBarFrame.Visible = false
        end
    end
end)
Tabs.Modulation:AddSlider("StatusBarTransparency", {
    Title = "Status Bar Transparency",
    Description = "Adjust the background transparency of the status bar",
    Min = 0,
    Max = 1,
    Default = 0.3,
    Rounding = 2,
    Callback = function(val)
        if statusBarFrame then
            statusBarFrame.BackgroundTransparency = val
        end
    end,
})


Tabs.Modulation:AddSlider("StatusBarPosX", {
    Title = "Status Bar X Position",
    Description = "Adjust the horizontal (X) position of the status bar",
    Min = -800,
    Max = 800,
    Default = 0,
    Rounding = 0,
    Callback = function(xOffset)
        if statusBarFrame then
            statusBarFrame.Position = UDim2.new(0.5, xOffset, statusBarFrame.Position.Y.Scale, statusBarFrame.Position.Y.Offset)
        end
    end,
})

Tabs.Modulation:AddSlider("StatusBarPosY", {
    Title = "Status Bar Y Position",
    Description = "Adjust the vertical (Y) position of the status bar",
    Min = -61,
    Max = 921,
    Default = 5,
    Rounding = 0,
    Callback = function(yOffset)
        if statusBarFrame then
            statusBarFrame.Position = UDim2.new(statusBarFrame.Position.X.Scale, statusBarFrame.Position.X.Offset, 0, yOffset)
        end
    end,
})

Tabs.Modulation:AddSlider("BrightnessSlider", {
    Title = "World Brightness",
    Description = "Overall brightness of the world",
    Min = 0,
    Max = 5,
    Default = game.Lighting.Brightness,
    Rounding = 2,
    Callback = function(val)
        game.Lighting.Brightness = val
    end,
})

Tabs.Modulation:AddColorpicker("AmbientColorPicker", {
    Title = "Ambient Lighting",
    Description = "Change the ambient light color",
    Default = Color3.fromRGB(128, 128, 128),
    Callback = function(color)
        game.Lighting.Ambient = color
    end
})

Tabs.Modulation:AddColorpicker("FloorColorPicker", {
    Title = "Floor Color",
    Description = "Change the floor baseplate color",
    Default = Color3.fromRGB(75, 151, 75),
    Callback = function(color)
        local baseplate = workspace:FindFirstChild("TopBaseplate")
        if baseplate then
            baseplate.Color = color
        else
            Fluent:Notify({
                Title = "Floor Color",
                Content = "TopBaseplate not found in workspace",
                Duration = 3,
            })
        end
    end
})

Tabs.Modulation:AddButton({
    Title = "Reset All Lighting",
    Description = "Reset all lighting settings to original values",
    Callback = function()
        game.Lighting.Brightness = originalBrightness
        game.Lighting.Ambient = originalAmbient
        
        local baseplate = workspace:FindFirstChild("TopBaseplate")
        if baseplate and originalFloorColor then
            baseplate.Color = originalFloorColor
        end
        
        Fluent:Notify({
            Title = "Modulation",
            Content = "All lighting settings reset to original values",
            Duration = 3,
        })
    end,
})


-- walking rage ui
Tabs.WalkingRage:AddToggle("WalkingRageToggle", {
    Title = "Enable Balkan Rage Mode",
    Description = "Walks through plot in a predictable pattern and plants fruits",
    Default = false,
}):OnChanged(function(val)
    walkingRageMode = val
    setNoclip(val) -- toggle noclip
    if not val then
        isWalkingToTarget = false
        currentWalkingTarget = nil
        -- reset speed
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 -- default sped
            end
        end
    end
end)

Tabs.WalkingRage:AddToggle("WalkingRageAutoPlant", {
    Title = "Auto Plant While Walking",
    Description = "Enable/disable auto planting during Balkan Rage mode",
    Default = false,
}):OnChanged(function(val)
    walkingRageAutoPlant = val
end)

Tabs.WalkingRage:AddSlider("WalkingRageSpeed", {
    Title = "Walking Speed",
    Description = "Speed for balkan rage mode",
    Min = 8,
    Max = 96,
    Default = 16,
    Rounding = 0,
    Callback = function(val)
        walkingRageSpeed = val
    end,
})


Tabs.WalkingRage:AddSlider("WalkingRageSpeed", {
    Title = "Delay",
    Description = "Delays betweeen positions",
    Min = 0,
    Max = 1,
    Default = 0.05,
    Rounding = 1,
    Callback = function(val)
        positionDelay = val
    end,
})

-- selection
local walkingPlotNames = {}
for _, plot in ipairs(plots) do
    table.insert(walkingPlotNames, plot.name)
end

Tabs.WalkingRage:AddDropdown("WalkingRagePlotSelector", {
    Title = "Select Plot for Balkan Rage",
    Description = "Choose which plot to walk through",
    Values = walkingPlotNames,
    Multi = false,
    Default = walkingPlotNames[1],
}):OnChanged(function(value)
    for i, name in ipairs(walkingPlotNames) do
        if name == value then
            walkingRagePlotIndex = i
            break
        end
    end
end)

-- button
Tabs.WalkingRage:AddButton({
    Title = "Start Walking Pattern",
    Description = "Manually start the walking rage pattern",
    Callback = function()
        if walkingRageMode and #selectedFarmFruits > 0 then
            task.spawn(walkingRageFarm)
        else
            Fluent:Notify({
                Title = "Balkan Rage",
                Content = "Enable Walking Rage Mode and select fruits first!",
                Duration = 3,
            })
        end
    end,
})

-- tp to pos
Tabs.WalkingRage:AddButton({
    Title = "Teleport to Selected Plot",
    Description = "Teleports you to the center of selected walking plot",
    Callback = function()
        local plot = plots[walkingRagePlotIndex]
        teleportTo(plot.center)
    end,
})

-- pattern
Tabs.WalkingRage:AddButton({
    Title = "Show Walking Positions",
    Description = "{DEBUG}",
    Callback = function()
        local positions = getWalkingPositions(walkingRagePlotIndex)
        print("[Balkan Rage] Found " .. #positions .. " walking positions:")
        for i, pos in ipairs(positions) do
            print("Position " .. i .. ": " .. tostring(pos))
        end
    end,
})

Tabs.AutoCollect:AddParagraph({
        Title = "WARNING",
        Content = "Rage autocollect harvests everything!\nThe selection is only for legit mode"
})

Tabs.Credits:AddParagraph({
        Title = "Soma",
        Content = "soma1100"
})

Tabs.Credits:AddParagraph({
        Title = "klyte",
        Content = "_klyte_"
})
-- af
local afToggle = Tabs.AutoFarm:AddToggle("AutoFarmToggle", {
    Title = "Enable AutoFarm",
    Default = false,
})

afToggle:OnChanged(function(val)
    autoFarm = val
end)

local antiafkToggle = Tabs.AutoFarm:AddToggle("AutoFarmToggle", {
    Title = "AntiAfk",
    Default = false,
})

antiafkToggle:OnChanged(function(val)
    antiAfk = val
end)

local afMode = Tabs.AutoFarm:AddDropdown("AFMode", {
    Title = "AutoFarm Mode",
    Values = {"Legit", "Rage"},
    Multi = false,
    Default = "Rage",
})

afMode:OnChanged(function(mode)
    autoFarmMode = mode
end)

Tabs.AutoCollect:AddToggle("AutoCollectToggle", {
    Title = "Auto Collect",
    Default = false,
}):OnChanged(function(val)
    autoCollect = val
end)

Tabs.AutoCollect:AddDropdown("CollectMode", {
    Title = "Collect Mode",
    Values = {"Legit", "Rage"},
    Multi = false,
    Default = "Legit",
}):OnChanged(function(val)
    autoCollectMode = val
end)

Tabs.AutoCollect:AddSlider("CollectRange", {
    Title = "Range",
    Min = 1,
    Max = 36,
    Default = 24,
    Rounding = 0,
    Callback = function(val)
        autoCollectRange = val
    end
})

Tabs.AutoCollect:AddSlider("CollectInterval", {
    Title = "Interval",
    Min = 0.01,
    Max = 1.5,
    Default = 0.1,
    Rounding = 1,
    Callback = function(val)
        autoCollectInterval = val
    end
})

Tabs.AutoCollect:AddDropdown("CollectFruitSelector", {
    Title = "Fruits to AutoCollect (Legit Mode)",
    Values = allFruits,
    Multi = true,
    Default = {},
}):OnChanged(function(selection)
    selectedCollectFruits = {}
    for fruit, enabled in pairs(selection) do
        if enabled then
            table.insert(selectedCollectFruits, fruit)
        end
    end
end)

Tabs.AutoCollect:AddDropdown("CollectMiscFruitSelector", {
    Title = "Misc fruits to AutoCollect (Legit Mode)",
    Values = miscFruits,
    Multi = true,
    Default = {},
}):OnChanged(function(selection)
    selectedCollectMiscFruits = {}
    for fruit, enabled in pairs(selection) do
        if enabled then
            table.insert(selectedCollectMiscFruits, fruit)
        end
    end
end)

Tabs.AutoFarm:AddSlider("AFInterval", {
    Title = "Interval (Legit Mode)",
    Min = 0.01,
    Max = 0.2,
    Default = 0.05,
    Rounding = 2,
    Callback = function(val)
        autoFarmInterval = val
    end,
})

-- plot
local plotNames = {}
for _, plot in ipairs(plots) do
    table.insert(plotNames, plot.name)
end

local plotDropdown = Tabs.AutoFarm:AddDropdown("PlotSelector", {
    Title = "Select Plot (Legit Mode)",
    Values = plotNames,
    Multi = false,
    Default = plotNames[1],
})

plotDropdown:OnChanged(function(value)
    for i, name in ipairs(plotNames) do
        if name == value then
            selectedPlotIndex = i
            break
        end
    end
end)

Tabs.AutoFarm:AddToggle("AutoSlot", {
    Title = "Autoseed",
    Description = "Equips seeds,",
    Default = false,
}):OnChanged(function(val)
    autoSlotSpam = val
end)

Tabs.AutoFarm:AddSlider("SlotMinSlider", {
    Title = "Slot Min",
    Min = 1,
    Max = 9,
    Default = 2,
    Rounding = 0,
    Callback = function(val)
        slotMin = val
    end,
})

Tabs.AutoFarm:AddSlider("SlotMaxSlider", {
    Title = "Slot Max",
    Min = 1,
    Max = 9,
    Default = 4,
    Rounding = 0,
    Callback = function(val)
        slotMax = val
    end,
})

Tabs.AutoFarm:AddSlider("SlotDelaySlider", {
    Title = "Slot Interval (s)",
    Min = 0.05,
    Max = 10.0,
    Default = 0.75,
    Rounding = 2,
    Callback = function(val)
        slotDelay = val
    end,
})

Tabs.AutoFarm:AddButton({
    Title = "Blacklist Current Tool",
    Description = "Use this on a shovel to prevent from autoseed selecting it",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local tool = char:FindFirstChildOfClass("Tool")

        if tool then
            local name = tool.Name
            -- no duplic
            for _, item in ipairs(blacklistedItems) do
                if item == name then
                    Fluent:Notify({
                        Title = "Blacklist",
                        Content = name .. " is already blacklisted.",
                        Duration = 5,
                    })
                    return
                end
            end

            table.insert(blacklistedItems, name)
            Fluent:Notify({
                Title = "Blacklist",
                Content = name .. " has been added to blacklist.",
                Duration = 3,
            })
        else
            Fluent:Notify({
                Title = "Blacklist",
                Content = "No tool equipped.",
                Duration = 3,
            })
        end
    end,
})

-- tp
Tabs.AutoFarm:AddButton({
    Title = "Teleport to Plot Center",
    Description = "Teleports you to the center of selected plot",
    Callback = teleportToPlotCenter,
})

-- frut
local farmFruitSelector = Tabs.AutoFarm:AddDropdown("FarmFruitSelector", {
    Title = "Select Fruits to Farm (Legit mode)",
    Description = "Choose fruits to plant during AutoFarm",
    Values = allFruits,
    Multi = true,
    Default = {""},
})

farmFruitSelector:OnChanged(function(selection)
    selectedFarmFruits = {}
    for fruit, enabled in pairs(selection) do
        if enabled then
            table.insert(selectedFarmFruits, fruit)
        end
    end
end)

-- autobuy
local autoBuyToggle = Tabs.AutoBuy:AddToggle("AutoBuy", {
    Title = "Auto Buy Fruits",
    Description = "Automatically buys selected fruits when enabled",
    Default = false,
})

autoBuyToggle:OnChanged(function(value)
    autoBuy = value
end)

local fruitSelector = Tabs.AutoBuy:AddDropdown("FruitSelector", {
    Title = "Select Fruits to Buy",
    Description = "Choose which fruits to auto buy",
    Values = allFruits,
    Multi = true,
    Default = {},
})

fruitSelector:SetValue({})

fruitSelector:OnChanged(function(selection)
    selectedBuyFruits = {}
    for fruit, enabled in pairs(selection) do
        if enabled then
            table.insert(selectedBuyFruits, fruit)
        end
    end
end)

local honeySelector = Tabs.AutoBuy:AddDropdown("HoneySelector", {
    Title = "Select Honey items to Buy",
    Description = "Choose which items to auto buy",
    Values = honeyItems,
    Multi = true,
    Default = {},
})

honeySelector:SetValue({})

honeySelector:OnChanged(function(selection)
    selectedHoneyItems = {}
    for honeyItem, enabled in pairs(selection) do 
        if enabled then
            table.insert(selectedHoneyItems, honeyItem) 
        end
    end
end)

local gearSelector = Tabs.AutoBuy:AddDropdown("GearSelector", {
    Title = "Select Gear items to Buy",
    Description = "Choose which gear items to auto buy",
    Values = gearItems,
    Multi = true,
    Default = {},
})

gearSelector:OnChanged(function(selection)
    selectedGearItems = {}
    for gearItem, enabled in pairs(selection) do
        if enabled then
            table.insert(selectedGearItems, gearItem)
        end
    end
end)

Tabs.AutoBuy:AddButton({
    Title = "Teleport to Honey Section",
    Description = "Teleports you to the honey area",
    Callback = function()
        teleportTo(Vector3.new(-100, 10, -5))
    end,
})

Tabs.AutoBuy:AddButton({
    Title = "Teleport to Gear, Cosmetics and Pet Eggs shop",
    Description = "Teleports you to the gear, cosmetics and pet eggs shop area",
    Callback = function()
        teleportTo(Vector3.new(-271, 10, -13))
    end,
})

local autoSellToggle = Tabs.AutoBuy:AddToggle("AutoSell", {
    Title = "Auto Sell Inventory",
    Description = "Automatically sells your entire inventory at set intervals (teleports to sell point)",
    Default = false,
})

autoSellToggle:OnChanged(function(value)
    autoSell = value
end)

Tabs.AutoBuy:AddSlider("SellInterval", {
    Title = "Sell Interval (seconds)",
    Description = "How often to sell inventory (seconds) ",
    Min = 1,
    Max = 120,
    Default = 47,
    Rounding = 0,
    Callback = function(val)
        sellInterval = val
    end,
})

Tabs.AutoBuy:AddButton({
    Title = "Sell Inventory Now",
    Description = "Immediately sell your entire inventory (teleports to sell point)",
    Callback = sellInventory,
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

task.spawn(function()
    local timer = 0
    while true do
        wait(1)
        if autoBuy and (#selectedBuyFruits > 0 or #selectedHoneyItems > 0 or #selectedGearItems > 0) then
            if #selectedBuyFruits > 0 then
                buySeeds()
            end
            if #selectedHoneyItems > 0 then
                buyHoney()
            end
            if #selectedGearItems > 0 then
                buyGear()
            end
            timer += 1
            if timer >= 10 then
                local buyMessage = "AutoBuy is active for:"
                if #selectedBuyFruits > 0 then
                    buyMessage = buyMessage .. "[AutoBuy] Buying Fruits: " .. table.concat(selectedBuyFruits, ", ")
                end
                if #selectedHoneyItems > 0 then
                    buyMessage = buyMessage .. "[AutoBuy] Buying Honey Items: " .. table.concat(selectedHoneyItems, ", ")
                end
                if #selectedGearItems > 0 then
                    buyMessage = buyMessage .. " [Gear: " .. table.concat(selectedGearItems, ", ") .. "]"
                end
                print(buyMessage)
                timer = 0
            end
        else
            timer = 0
        end
        if Fluent.Unloaded then break end
    end
end)

task.spawn(function()
    while true do
        if autoSell then
            sellInventory()
            wait(sellInterval)
        else
            wait(1)
        end
        if Fluent.Unloaded then break end
    end
end)

task.spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    while true do
        if autoSlotSpam and slotMin <= slotMax then
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local equippedTool = char:FindFirstChildOfClass("Tool")

            -- if hand empty
            if not equippedTool and humanoid then
                local backpack = player:WaitForChild("Backpack")
                local tools = {}

                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, item)
                    end
                end

                -- try to equip 1 by 1
                for _, tool in ipairs(tools) do
                    if not autoSlotSpam then break end

                    -- skip
                    local isBlacklisted = false
                    for _, item in ipairs(blacklistedItems) do
                        if item == tool.Name then
                            isBlacklisted = true
                            break
                        end
                    end
                    if isBlacklisted then continue end

                    if not char:FindFirstChildOfClass("Tool") then
                        humanoid:EquipTool(tool)
                        wait(slotDelay)
                    else
                        break
                    end
                end
            end
        end

        wait(1)
        if Fluent.Unloaded then break end
    end
end)

-- auto farm
task.spawn(function()
    while true do
        if autoFarm and #selectedFarmFruits > 0 then
            if autoFarmMode == "Rage" then
                rageAutoFarm()
            elseif autoFarmMode == "Legit" then
                legitAutoFarm()
            end
            wait(1)
        else
            wait(1)
        end
        if Fluent.Unloaded then break end
    end
end)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

Players.LocalPlayer.Idled:Connect(function()
	if antiAfk then
		local VirtualUser = game:GetService('VirtualUser')
 
        game:GetService('Players').LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
	end
end)

-- balkan rage
task.spawn(function()
    while true do
        if walkingRageMode and #selectedFarmFruits > 0 then
            walkingRageFarm()
            wait(0.1)
        else
            wait(0.1)
        end
        if Fluent.Unloaded then break end
    end
end)

task.spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    local function ReturnPlayerFarm(Player)
        for i,Farm in pairs(workspace.Farm:GetChildren()) do
            local Owner = Farm.Important.Data.Owner.Value
            if Owner == tostring(Player) then
                return Farm
            end
        end
    end
    
    local function FindPrompts(obj, depth, maxDepth, out)
        if depth > maxDepth then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("ProximityPrompt") then
                table.insert(out, child)
            end
            FindPrompts(child, depth + 1, maxDepth, out)
        end
    end
    
    local function GrabAllPlants(Player) 
        local P = {}
        local playerFarm = ReturnPlayerFarm(Player)
        if not playerFarm then return P end
        
        for i,Plant in pairs(playerFarm.Important.Plants_Physical:GetChildren()) do
            local Prompts = {}
            FindPrompts(Plant, 0, 4, Prompts)
            P[#P + 1] = {Plant,Prompts}
        end
        return P
    end
    
    local function rageCollect()
        local Start = tick()
        local Plants = GrabAllPlants(game.Players.LocalPlayer)
        local OldPos = game.Players.LocalPlayer.Character.Head.Position
        local TotalPrompts = 0
        
        for i,v in pairs(Plants) do
            local Plant,Prompts = v[1],v[2] 
            if Plant.PrimaryPart and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Plant.PrimaryPart.Position).Magnitude > 35 then
                game.Players.LocalPlayer.Character:MoveTo(Plant.PrimaryPart.Position)
                print("moved to",Plant)
                task.wait(.1)
            else
                print("no need to move",Plant,#Prompts,Plant.PrimaryPart)
            end
            print("Harvesting",Plant,#Prompts)
            for i,v in pairs(Prompts) do
                fireproximityprompt(v)
                TotalPrompts = TotalPrompts + 1
                print("Harvested",Plant)
            end
            print("done",Plant)
        end
        game.Players.LocalPlayer.Character:MoveTo(OldPos)
        print("Finished picking", TotalPrompts,"fruit in", tick() - Start,"seconds")
    end
    
    local function legitCollect()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        for _, farm in ipairs(workspace:WaitForChild("Farm"):GetChildren()) do
                --print("[AutoCollect] Scanning farm:", farm.Name)

                local success, err = pcall(function()
                    local importantFolder = farm:FindFirstChild("Important")
                    if importantFolder and importantFolder:FindFirstChild("Plants_Physical") then
                        local plantsFolder = importantFolder:FindFirstChild("Plants_Physical")

                        for _, plant in ipairs(plantsFolder:GetChildren()) do
                            local plantName = plant.Name
                            local isRegularFruit = table.find(selectedCollectFruits, plantName)
                            local isMiscFruit = table.find(selectedCollectMiscFruits, plantName)
                            
                            if isRegularFruit or isMiscFruit then
                                --print("[AutoCollect] Found matching plant:", plantName, isMiscFruit and "(Misc)" or "(Regular)")

                                local prompt = nil
                                
                                -- misc fruit ig
                                if isMiscFruit and customPromptPaths2[plantName] then
                                    prompt = customPromptPaths2[plantName](plant)
                                    --print("[AutoCollect] Using customPromptPaths2 for", plantName)
                                -- cstomPromptpaths
                                elseif customPromptPaths[plantName] then
                                    prompt = customPromptPaths[plantName](plant)
                                    --print("[AutoCollect] Using customPromptPaths for", plantName)
                                else
                                    local fruits = plant:FindFirstChild("Fruits")
                                    local named = fruits and fruits:FindFirstChild(plantName)
                                    local fruit1 = named and named:FindFirstChild("1")
                                    prompt = fruit1 and fruit1:FindFirstChildOfClass("ProximityPrompt")
                                    --print("[AutoCollect] Using default prompt path for", plantName)
                                end

                                if prompt then
                                    local distance = (hrp.Position - prompt.Parent.Position).Magnitude
                                    --print(("[AutoCollect] Distance to %s = %.2f studs"):format(plantName, distance))

                                    if distance <= tonumber(autoCollectRange) then
                                        --print(("[AutoCollect:%s] Firing prompt for %s"):format(autoCollectMode, plantName))
                                        fireproximityprompt(prompt, 1)
                                        
                                        -- ddeelay
                                        if autoCollectMode == "Legit" then
                                            wait(autoCollectInterval)
                                        end
                                    else
                                        --print(("[AutoCollect:%s] Skipped %s, out of range (%.2f > %.2f)"):format(
                                        --    autoCollectMode, plantName, distance, autoCollectRange))
                                    end
                                else
                                    --print("[AutoCollect] Prompt not found for", plantName)
                                end
                            end
                        end
                    else
                        --print("[AutoCollect] Missing Important or Plants_Physical in", farm.Name)
                    end
                end)

                if not success then
                    warn("[AutoCollect] Error processing", farm.Name, "=>", err)
                end
            end
        end
    while true do
        if autoCollect and (#selectedCollectFruits > 0 or #selectedCollectMiscFruits > 0) then
            if autoCollectMode == "Rage" then
                rageCollect()
                wait(autoCollectInterval)
            else
                legitCollect()
                wait(1)
            end
        else
            wait(1)
        end
        if Fluent.Unloaded then break end
    end
end)

Fluent:Notify({
    Title = "Acid",
    Content = "Loaded Grow A Garden",
    Duration = 2,
})
