local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local library = {}
library.Theme = "Summer"
library.Animation = "Bounce"

-- Themes table (can add more)
local themes = {
    Summer = {
        BackgroundColor = Color3.fromRGB(255, 200, 150),
        AccentColor = Color3.fromRGB(255, 140, 0),
        GradientColors = {Color3.fromRGB(255, 195, 160), Color3.fromRGB(255, 165, 79)}
    },
    Winter = {
        BackgroundColor = Color3.fromRGB(200, 230, 255),
        AccentColor = Color3.fromRGB(70, 130, 180),
        GradientColors = {Color3.fromRGB(170, 210, 255), Color3.fromRGB(100, 160, 220)}
    },
    Sky = {
        BackgroundColor = Color3.fromRGB(180, 220, 255),
        AccentColor = Color3.fromRGB(100, 180, 255),
        GradientColors = {Color3.fromRGB(130, 200, 255), Color3.fromRGB(80, 160, 220)}
    }
}

-- Utility to create UI with gradient and theme
local function createFrame(props)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = props.BackgroundColor or Color3.new(1,1,1)
    frame.Size = props.Size or UDim2.new(0,200,0,300)
    frame.Position = props.Position or UDim2.new(0,0,0,0)
    frame.BorderSizePixel = 0
    frame.Parent = props.Parent
    if props.RoundCorners then
        local uic = Instance.new("UICorner", frame)
        uic.CornerRadius = UDim.new(0, 8)
    end
    if props.GradientColors then
        local grad = Instance.new("UIGradient", frame)
        grad.Color = ColorSequence.new(props.GradientColors)
        grad.Rotation = props.GradientRotation or 90
    end
    return frame
end

-- Tween helpers for animations
local function bounceTween(obj)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tweenUp = TweenService:Create(obj, tweenInfo, {Position = UDim2.new(0.5, -obj.Size.X.Offset/2, 0.5, -obj.Size.Y.Offset/2)})
    local tweenDown = TweenService:Create(obj, tweenInfo, {Position = UDim2.new(0.5, -obj.Size.X.Offset/2, 0.6, -obj.Size.Y.Offset/2)})
    tweenUp:Play()
    tweenUp.Completed:Wait()
    tweenDown:Play()
    tweenDown.Completed:Wait()
end

local function scaleInTween(obj)
    obj.AnchorPoint = Vector2.new(0.5,0.5)
    obj.Position = UDim2.new(0.5, -obj.Size.X.Offset/2, 0.5, -obj.Size.Y.Offset/2)
    obj.Size = UDim2.new(0,0,0,0)
    local tween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,300,0,400)})
    tween:Play()
    tween.Completed:Wait()
end

-- Main GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VerticalGuiLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main frame (centered, but off by default)
local MainFrame = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(0, 300, 0, 400),
    Position = UDim2.new(0.5, -150, 0.5, -200),
    BackgroundColor = themes[library.Theme].BackgroundColor,
    GradientColors = themes[library.Theme].GradientColors,
    RoundCorners = true,
}
MainFrame.Visible = false
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)

-- Vertical layout for sections inside MainFrame
local SectionsContainer = Instance.new("ScrollingFrame", MainFrame)
SectionsContainer.Size = UDim2.new(1, -20, 1, -20)
SectionsContainer.Position = UDim2.new(0, 10, 0, 10)
SectionsContainer.BackgroundTransparency = 1
SectionsContainer.ScrollBarThickness = 5
SectionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", SectionsContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Bottom bar for tabs/buttons
local BottomBar = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 1, -40),
    BackgroundColor = Color3.fromRGB(20,20,20),
    RoundCorners = false
}

-- Buttons: Tab Mode, GUI Mode, Settings
local function createButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Name = name.."Btn"
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.TextSize = 18
    btn.Parent = BottomBar
    local uic = Instance.new("UICorner", btn)
    uic.CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80,80,80) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40,40,40) end)
    return btn
end

local tabBtn = createButton("Tab Mode", UDim2.new(0, 10, 0, 0))
local guiBtn = createButton("GUI Mode", UDim2.new(0, 140, 0, 0))
local settingsBtn = createButton("Settings", UDim2.new(0, 270, 0, 0))

-- State variables
local currentMode = "Tab"
local tabs = {}
local toggles = {}

-- Function to clear sections
local function clearSections()
    for _, child in pairs(SectionsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- Create a Section inside MainFrame
function library:Section(title)
    local sectionFrame = createFrame{
        Parent = SectionsContainer,
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundColor = themes[library.Theme].AccentColor,
        RoundCorners = true,
        GradientColors = themes[library.Theme].GradientColors
    }
    local titleLbl = Instance.new("TextLabel", sectionFrame)
    titleLbl.Text = title
    titleLbl.Size = UDim2.new(1, -10, 0, 30)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextColor3 = Color3.new(1,1,1)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 22
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local contentFrame = Instance.new("Frame", sectionFrame)
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    
    local contentLayout = Instance.new("UIListLayout", contentFrame)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    
    return {
        Frame = sectionFrame,
        Content = contentFrame,
        AddToggle = function(self, name, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 30)
            toggleFrame.BackgroundTransparency = 0
            toggleFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = self.Content
            local uic = Instance.new("UICorner", toggleFrame)
            uic.CornerRadius = UDim.new(0, 6)

            local label = Instance.new("TextLabel", toggleFrame)
            label.Text = name
            label.Size = UDim2.new(0.75, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 18
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Position = UDim2.new(0, 10, 0, 0)

            local toggleBtn = Instance.new("TextButton", toggleFrame)
            toggleBtn.Size = UDim2.new(0, 50, 0, 20)
            toggleBtn.Position = UDim2.new(1, -60, 0, 5)
            toggleBtn.BackgroundColor3 = default and themes[library.Theme].AccentColor or Color3.fromRGB(60,60,60)
            toggleBtn.BorderSizePixel = 0
            toggleBtn.Text = ""
            toggleBtn.AutoButtonColor = false
            local uic2 = Instance.new("UICorner", toggleBtn)
            uic2.CornerRadius = UDim.new(0, 4)

            local toggled = default or false
            local function updateToggle()
                if toggled then
                    toggleBtn.BackgroundColor3 = themes[library.Theme].AccentColor
                else
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                end
            end

            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
                if callback then
                    callback(toggled)
                end
            end)
            updateToggle()
            return toggleBtn
        end
    }
end

-- Tabs: simple square gui like Fluent UI style
local TabModeFrame = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(0, 400, 0, 300),
    Position = UDim2.new(0.5, -200, 0.4, -150),
    BackgroundColor = themes[library.Theme].BackgroundColor,
    GradientColors = themes[library.Theme].GradientColors,
    RoundCorners = true,
}
TabModeFrame.Visible = false
TabModeFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local TabButtonsContainer = Instance.new("Frame", TabModeFrame)
TabButtonsContainer.Size = UDim2.new(1, 0, 0, 40)
TabButtonsContainer.Position = UDim2.new(0, 0, 0, 0)
TabButtonsContainer.BackgroundTransparency = 1

local TabContentContainer = Instance.new("Frame", TabModeFrame)
TabContentContainer.Size = UDim2.new(1, -20, 1, -60)
TabContentContainer.Position = UDim2.new(0, 10, 0, 50)
TabContentContainer.BackgroundTransparency = 1

local TabButtonsLayout = Instance.new("UIListLayout", TabButtonsContainer)
TabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonsLayout.Padding = UDim.new(0, 6)

local currentTab = nil

function library:CreateTab(name)
    local tabBtn = Instance.new("TextButton", TabButtonsContainer)
    tabBtn.Text = name
    tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.BorderSizePixel = 0
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 18
    tabBtn.TextColor3 = Color3.new(1,1,1)
    local uic = Instance.new("UICorner", tabBtn)
    uic.CornerRadius = UDim.new(0, 6)

    local tabContent = Instance.new("Frame", TabContentContainer)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false

    tabBtn.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.Visible = false
        end
        tabContent.Visible = true
        currentTab = tabContent
    end)

    -- Automatically activate first tab
    if not currentTab then
        tabBtn.MouseButton1Click:Invoke()
        tabBtn.MouseButton1Click()
    end

    return tabContent
end

-- Settings page (for themes and animations)
local SettingsFrame = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(0, 300, 0, 200),
    Position = UDim2.new(0.5, -150, 0.3, -100),
    BackgroundColor = themes[library.Theme].BackgroundColor,
    GradientColors = themes[library.Theme].GradientColors,
    RoundCorners = true,
}
SettingsFrame.Visible = false
SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local settingsLayout = Instance.new("UIListLayout", SettingsFrame)
settingsLayout.Padding = UDim.new(0, 15)
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function addSettingsOption(name, options, current, callback)
    local container = Instance.new("Frame", SettingsFrame)
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", container)
    label.Text = name
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left

    local dropdown = Instance.new("TextButton", container)
    dropdown.Text = current
    dropdown.Size = UDim2.new(0.4, 0, 1, 0)
    dropdown.Position = UDim2.new(0.55, 0, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(50,50,50)
    dropdown.BorderSizePixel = 0
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 16
    dropdown.TextColor3 = Color3.new(1,1,1)
    local uic = Instance.new("UICorner", dropdown)
    uic.CornerRadius = UDim.new(0, 6)

    local dropdownOpen = false
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0.4, 0, 0, #options * 30)
    dropdownList.Position = UDim2.new(0.55, 0, 1, 0)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40,40,40)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = container
    local uic2 = Instance.new("UICorner", dropdownList)
    uic2.CornerRadius = UDim.new(0, 6)

    for i,opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropdownList)
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
        optBtn.Text = opt
        optBtn.BackgroundTransparency = 1
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 16
        optBtn.TextColor3 = Color3.new(1,1,1)
        optBtn.BorderSizePixel = 0
        optBtn.MouseEnter:Connect(function() optBtn.BackgroundTransparency = 0.7 end)
        optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)
        optBtn.MouseButton1Click:Connect(function()
            dropdown.Text = opt
            dropdownList.Visible = false
            dropdownOpen = false
            if callback then callback(opt) end
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        dropdownList.Visible = dropdownOpen
    end)
end

-- Setup settings options
addSettingsOption("Theme", {"Summer","Winter","Sky"}, library.Theme, function(newTheme)
    library.Theme = newTheme
    -- Update GUI colors for main frames
    for _, frame in pairs({MainFrame, TabModeFrame, SettingsFrame}) do
        frame.BackgroundColor3 = themes[newTheme].BackgroundColor
        local grad = frame:FindFirstChildOfClass("UIGradient")
        if grad then
            grad.Color = ColorSequence.new(themes[newTheme].GradientColors)
        else
            local newGrad = Instance.new("UIGradient", frame)
            newGrad.Color = ColorSequence.new(themes[newTheme].GradientColors)
        end
    end
end)

addSettingsOption("Animation", {"Bounce", "Scale In"}, library.Animation, function(newAnim)
    library.Animation = newAnim
end)

-- Side config loader (stuck to right wall)
local configLoader = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(0, 40, 0, 150),
    Position = UDim2.new(1, -40, 0.5, -75),
    BackgroundColor = Color3.fromRGB(40,40,40),
    RoundCorners = true,
}
configLoader.AnchorPoint = Vector2.new(1, 0.5)

local uic = Instance.new("UICorner", configLoader)
uic.CornerRadius = UDim.new(0, 8)

local isExpanded = false

local toggleButton = Instance.new("TextButton", configLoader)
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleButton.Text = "Config"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.BorderSizePixel = 0
local toggleUIC = Instance.new("UICorner", toggleButton)
toggleUIC.CornerRadius = UDim.new(0, 8)

local configContent = Instance.new("ScrollingFrame", configLoader)
configContent.Size = UDim2.new(1, -10, 1, -50)
configContent.Position = UDim2.new(0, 5, 0, 45)
configContent.BackgroundColor3 = Color3.fromRGB(30,30,30)
configContent.BorderSizePixel = 0
configContent.Visible = false
local configLayout = Instance.new("UIListLayout", configContent)
configLayout.SortOrder = Enum.SortOrder.LayoutOrder
configLayout.Padding = UDim.new(0, 8)
configContent.CanvasSize = UDim2.new(0, 0, 1, 0)

-- Example config buttons
local function addConfigButton(name, callback)
    local btn = Instance.new("TextButton", configContent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = themes[library.Theme].AccentColor
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    local uic = Instance.new("UICorner", btn)
    uic.CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = themes[library.Theme].BackgroundColor end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = themes[library.Theme].AccentColor end)
    btn.MouseButton1Click:Connect(callback)
end

addConfigButton("Load Config 1", function() print("Loaded config 1!") end)
addConfigButton("Load Config 2", function() print("Loaded config 2!") end)

toggleButton.MouseButton1Click:Connect(function()
    if isExpanded then
        -- Collapse
        configLoader:TweenSizeAndPosition(UDim2.new(0, 40, 0, 150), UDim2.new(1, -40, 0.5, -75), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        configContent.Visible = false
    else
        -- Expand to middle center
        configLoader:TweenSizeAndPosition(UDim2.new(0, 300, 0, 300), UDim2.new(0.5, -150, 0.5, -150), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        configContent.Visible = true
    end
    isExpanded = not isExpanded
end)

-- Switch modes logic
local function switchToMode(mode)
    currentMode = mode
    if library.Animation == "Bounce" then
        if mode == "Tab" then
            MainFrame.Visible = false
            SettingsFrame.Visible = false
            TabModeFrame.Visible = true
            bounceTween(TabModeFrame)
        elseif mode == "GUI" then
            TabModeFrame.Visible = false
            SettingsFrame.Visible = false
            MainFrame.Visible = true
            bounceTween(MainFrame)
        elseif mode == "Settings" then
            TabModeFrame.Visible = false
            MainFrame.Visible = false
            SettingsFrame.Visible = true
            bounceTween(SettingsFrame)
        end
    else
        -- ScaleIn animation
        if mode == "Tab" then
            MainFrame.Visible = false
            SettingsFrame.Visible = false
            TabModeFrame.Visible = true
            scaleInTween(TabModeFrame)
        elseif mode == "GUI" then
            TabModeFrame.Visible = false
            SettingsFrame.Visible = false
            MainFrame.Visible = true
            scaleInTween(MainFrame)
        elseif mode == "Settings" then
            TabModeFrame.Visible = false
            MainFrame.Visible = false
            SettingsFrame.Visible = true
            scaleInTween(SettingsFrame)
        end
    end
end

-- button events
tabBtn.MouseButton1Click:Connect(function() switchToMode("Tab") end)
guiBtn.MouseButton1Click:Connect(function() switchToMode("GUI") end)
settingsBtn.MouseButton1Click:Connect(function() switchToMode("Settings") end)

-- start in tab 
switchToMode("Tab")


return library()
