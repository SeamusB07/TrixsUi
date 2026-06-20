-- ==========================================
-- TRIXUI LIBRARY (MODERN DARK EDITION)
-- ==========================================

-- 1. THEME CONFIGURATION (Change these to instantly restyle the whole UI!)
local Theme = {
    Background = Color3.fromRGB(20, 20, 22),     -- Rich Black
    Topbar = Color3.fromRGB(15, 15, 17),         -- Darker Black
    Elements = Color3.fromRGB(30, 30, 34),       -- Soft Dark Gray
    Accent = Color3.fromRGB(0, 195, 255),        -- Vibrant Cyan
    AccentHover = Color3.fromRGB(50, 215, 255),  -- Lighter Cyan (For hovering)
    Text = Color3.fromRGB(230, 230, 235),        -- Soft White
    MutedText = Color3.fromRGB(130, 130, 140),   -- Muted Gray
    ToggleOff = Color3.fromRGB(60, 60, 65)       -- Dark Gray
}

local TrixUI = {}
TrixUI.__index = TrixUI

-- Window Class
local Window = {}
Window.__index = Window

function TrixUI.new(config)
    local self = setmetatable({}, Window)
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = config.Name or "TrixUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = game:GetService("CoreGui")

    -- Main Container
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 260, 0, 320)
    self.mainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
    self.mainFrame.BackgroundColor3 = Theme.Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.screenGui
    Instance.new("UICorner", self.mainFrame).CornerRadius = UDim.new(0, 10)

    -- Top Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 42)
    titleBar.BackgroundColor3 = Theme.Topbar
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0, 14, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Name or "TrixUI"
    titleText.TextColor3 = Theme.Text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 15
    titleText.Parent = titleBar

    -- Tab Holder
    self.tabHolder = Instance.new("Frame")
    self.tabHolder.Size = UDim2.new(0.5, -80, 1, 0)
    self.tabHolder.Position = UDim2.new(0.5, 0, 0, 0)
    self.tabHolder.BackgroundTransparency = 1
    self.tabHolder.Parent = titleBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.tabHolder

    -- Content Container
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Size = UDim2.new(1, -24, 1, -52)
    self.contentContainer.Position = UDim2.new(0, 12, 0, 46)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.ClipsDescendants = true
    self.contentContainer.Parent = self.mainFrame

    -- Window Controls
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 28, 0, 28)
    minimizeButton.Position = UDim2.new(1, -64, 0, 7)
    minimizeButton.BackgroundColor3 = Theme.Elements
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "—"
    minimizeButton.TextColor3 = Theme.MutedText
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 14
    minimizeButton.Parent = titleBar
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 6)

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -32, 0, 7)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = titleBar
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        self.contentContainer.Visible = not isMinimized
        self.mainFrame.Size = isMinimized and UDim2.new(0, 260, 0, 42) or UDim2.new(0, 260, 0, 320)
        minimizeButton.Text = isMinimized and "+" or "—"
    end)

    closeButton.MouseButton1Click:Connect(function() self.screenGui:Destroy() end)

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    self.tabs = {}
    return self
end

function Window:CreateTab(title)
    for _, tab in pairs(self.tabs) do
        tab.page.Visible = false
        tab.btn.TextColor3 = Theme.MutedText
        tab.btn.BackgroundTransparency = 1
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.BackgroundColor3 = Theme.Accent
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Theme.Background
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = self.tabHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Elements
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = true
    page.Parent = self.contentContainer

    -- INCREASED PADDING FOR BETTER SPACING
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 12) 
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = page

    local tabData = {btn = btn, page = page, layoutOrder = 0}
    table.insert(self.tabs, tabData)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
            t.page.Visible = false
            t.btn.TextColor3 = Theme.MutedText
            t.btn.BackgroundTransparency = 1
        end
        page.Visible = true
        btn.TextColor3 = Theme.Background
        btn.BackgroundTransparency = 0
    end)

    -- Tab Elements Class
    local Tab = {}
    Tab.__index = Tab
    setmetatable(Tab, {__index = function(_, key) return tabData[key] end})

    function Tab:Section(text)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 26)
        frame.BackgroundColor3 = Theme.Elements
        frame.BorderSizePixel = 0
        frame.LayoutOrder = tabData.layoutOrder
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.MutedText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
    end

    function Tab:Button(text, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = Theme.Accent
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Theme.Background
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.LayoutOrder = tabData.layoutOrder
        button.Parent = page
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

        -- Modern Hover Effect
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Theme.AccentHover
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Theme.Accent
        end)

        button.MouseButton1Click:Connect(function() callback(button) end)
    end

    function Tab:Toggle(text, default, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local toggled = default
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Theme.Elements
        frame.BorderSizePixel = 0
        frame.LayoutOrder = tabData.layoutOrder
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -55, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = frame

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 38, 0, 18)
        track.Position = UDim2.new(1, -50, 0.5, -9)
        track.BackgroundColor3 = toggled and Theme.Accent or Theme.ToggleOff
        track.BorderSizePixel = 0
        track.Parent = frame
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 14, 0, 14)
        indicator.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Parent = track
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        local clickDetector = Instance.new("TextButton")
        clickDetector.Size = UDim2.new(1, 0, 1, 0)
        clickDetector.BackgroundTransparency = 1
        clickDetector.Text = ""
        clickDetector.Parent = frame

        clickDetector.MouseButton1Click:Connect(function()
            toggled = not toggled
            track.BackgroundColor3 = toggled and Theme.Accent or Theme.ToggleOff
            indicator.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            callback(toggled)
        end)
    end

    function Tab:Slider(text, min, max, default, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local currentValue = default
        local isDraggingSlider = false
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 48)
        container.BackgroundColor3 = Theme.Elements
        container.BorderSizePixel = 0
        container.LayoutOrder = tabData.layoutOrder
        container.Parent = page
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 7)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 22)
        label.Position = UDim2.new(0, 12, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(currentValue)
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, 34)
        track.BackgroundColor3 = Theme.ToggleOff
        track.BorderSizePixel = 0
        track.Parent = container
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        local pct = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 14, 0, 14)
        thumb.Position = UDim2.new(pct, -7, 0.5, -7)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.Parent = track
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * relativeX)
            local newPct = (currentValue - min) / (max - min)
            fill.Size = UDim2.new(newPct, 0, 1, 0)
            thumb.Position = UDim2.new(newPct, -7, 0.5, -7)
            label.Text = text .. ": " .. tostring(currentValue)
            callback(currentValue)
        end

        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSlider = true
                updateSlider(input)
            end
        end)
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSlider = true
                updateSlider(input)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingSlider = false end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
    end

    return Tab
end

return TrixUI
