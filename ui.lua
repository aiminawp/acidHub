local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local library = {}
library.Theme = "Summer"
library.Animation = "Bounce"

local themes = {
    Summer = {
        BackgroundColor = Color3.fromRGB(255, 200, 150),
        AccentColor = Color3.fromRGB(255, 140, 0),
        GradientColors = {Color3.fromRGB(255, 195, 160), Color3.fromRGB(255, 165, 79)},
    },
    Winter = {
        BackgroundColor = Color3.fromRGB(200, 230, 255),
        AccentColor = Color3.fromRGB(70, 130, 180),
        GradientColors = {Color3.fromRGB(170, 210, 255), Color3.fromRGB(100, 160, 220)},
    },
    Sky = {
        BackgroundColor = Color3.fromRGB(180, 220, 255),
        AccentColor = Color3.fromRGB(100, 180, 255),
        GradientColors = {Color3.fromRGB(130, 200, 255), Color3.fromRGB(80, 160, 220)},
    },
}

local function createFrame(props)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = props.BackgroundColor or Color3.new(1, 1, 1)
    frame.Size = props.Size or UDim2.new(0, 200, 0, 300)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
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

local function bounceTween(obj)
    local info = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local centerPos = UDim2.new(0.5, -obj.Size.X.Offset / 2, 0.5, -obj.Size.Y.Offset / 2)
    local tweenUp = TweenService:Create(obj, info, {Position = centerPos})
    local tweenDown = TweenService:Create(obj, info, {Position = UDim2.new(centerPos.X.Scale, centerPos.X.Offset, 0.6, centerPos.Y.Offset)})
    tweenUp:Play()
    tweenUp.Completed:Wait()
    tweenDown:Play()
    tweenDown.Completed:Wait()
end

local function scaleInTween(obj)
    obj.AnchorPoint = Vector2.new(0.5, 0.5)
    obj.Position = UDim2.new(0.5, -obj.Size.X.Offset / 2, 0.5, -obj.Size.Y.Offset / 2)
    obj.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 400)})
    tween:Play()
    tween.Completed:Wait()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VerticalGuiLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(0, 300, 0, 400),
    Position = UDim2.new(0.5, -150, 0.5, -200),
    BackgroundColor = themes[library.Theme].BackgroundColor,
    GradientColors = themes[library.Theme].GradientColors,
    RoundCorners = true,
}
MainFrame.Visible = false
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local SectionsContainer = Instance.new("ScrollingFrame", MainFrame)
SectionsContainer.Size = UDim2.new(1, -20, 1, -20)
SectionsContainer.Position = UDim2.new(0, 10, 0, 10)
SectionsContainer.BackgroundTransparency = 1
SectionsContainer.ScrollBarThickness = 5
SectionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", SectionsContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local BottomBar = createFrame{
    Parent = ScreenGui,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 1, -40),
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    RoundCorners = false,
}

local function createButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 18
    btn.Parent = BottomBar
    local uic = Instance.new("UICorner", btn)
    uic.CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    return btn
end

local tabBtn = createButton("Tab Mode", UDim2.new(0, 10, 0, 0))
local guiBtn = createButton("GUI Mode", UDim2.new(0, 140, 0, 0))
local settingsBtn = createButton("Settings", UDim2.new(0, 270, 0, 0))

local currentMode = "Tab"

local function clearSections()
    for _, child in pairs(SectionsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

function library:Section(title)
    local sectionFrame = createFrame{
        Parent = SectionsContainer,
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundColor = themes[library.Theme].AccentColor,
        RoundCorners = true,
        GradientColors = themes[library.Theme].GradientColors,
    }
    local titleLbl = Instance.new("TextLabel", sectionFrame)
    titleLbl.Text = title
    titleLbl.Size = UDim2.new(1, -10, 0, 30)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextColor3 = Color3.new(1, 1, 1)
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
            toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = self.Content
            local uic = Instance.new("UICorner", toggleFrame)
            uic.CornerRadius = UDim.new(0, 6)

            local label = Instance.new("TextLabel", toggleFrame)
            label.Text = name
            label.Size = UDim2.new(0.75, 0, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 18
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggleBtn = Instance.new("TextButton", toggleFrame)
            toggleBtn.Size = UDim2.new(0, 50, 0, 20)
            toggleBtn.Position = UDim2.new(1, -60, 0, 5)
            toggleBtn.BackgroundColor3 = default and themes[library.Theme].AccentColor or Color3.fromRGB(60, 60, 60)
            toggleBtn.BorderSizePixel = 0
            toggleBtn.Text = ""
            toggleBtn.AutoButtonColor = false
            local uic2 = Instance.new("UICorner", toggleBtn)
            uic2.CornerRadius = UDim.new(0, 4)

            local toggled = default or false
            local function updateToggle()
                toggleBtn.BackgroundColor3 = toggled and themes[library.Theme].AccentColor or Color3.fromRGB(60, 60, 60)
                if callback then callback(toggled) end
            end
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
            end)
            updateToggle()

            return toggleFrame
        end,
    }
end

local function showGui()
    MainFrame.Visible = true
    if library.Animation == "Bounce" then
        bounceTween(MainFrame)
    elseif library.Animation == "ScaleIn" then
        scaleInTween(MainFrame)
    else
        MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    end
end

local function hideGui()
    MainFrame.Visible = false
end

tabBtn.MouseButton1Click:Connect(function()
    currentMode = "Tab"
    clearSections()
    showGui()
end)

guiBtn.MouseButton1Click:Connect(function()
    currentMode = "GUI"
    clearSections()
    showGui()
end)

settingsBtn.MouseButton1Click:Connect(function()
    clearSections()
    local settingsSection = library:Section("Settings")
    settingsSection:AddToggle("Enable Animation", true, function(enabled)
        if enabled then
            library.Animation = "Bounce"
        else
            library.Animation = "None"
        end
    end)
    settingsSection.Frame.Parent = SectionsContainer
    showGui()
end)

-- Start hidden, show on pressing RightControl
hideGui()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        if MainFrame.Visible then
            hideGui()
        else
            showGui()
        end
    end
end)

return library
