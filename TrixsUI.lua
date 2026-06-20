-- TrixUI Library
-- Pure UI logic. No game-specific code here.
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

    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 250, 0, 300)
    self.mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.screenGui
    Instance.new("UICorner", self.mainFrame).CornerRadius = UDim.new(0, 8)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(84, 101, 255)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Name or "TrixUI"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Parent = titleBar

    -- Tab Buttons Container (Sits in the top right of the title bar)
    self.tabHolder = Instance.new("Frame")
    self.tabHolder.Size = UDim2.new(0.5, -80, 1, 0)
    self.tabHolder.Position = UDim2.new(0.5, 0, 0, 0)
    self.tabHolder.BackgroundTransparency = 1
    self.tabHolder.Parent = titleBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = self.tabHolder

    -- Content Container (Where tab pages go)
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Size = UDim2.new(1, -20, 1, -50)
    self.contentContainer.Position = UDim2.new(0, 10, 0, 45)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.ClipsDescendants = true
    self.contentContainer.Parent = self.mainFrame

    -- Window Controls
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -65, 0, 5)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(84, 101, 255)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 18
    minimizeButton.Parent = titleBar
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 6)

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -32, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        self.contentContainer.Visible = not isMinimized
        self.mainFrame.Size = isMinimized and UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 300)
        minimizeButton.Text = isMinimized and "+" or "_"
    end)

    closeButton.MouseButton1Click:Connect(function() self.screenGui:Destroy() end)

    -- Dragging Logic
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
    -- Hide all existing tabs first
    for _, tab in pairs(self.tabs) do
        tab.page.Visible = false
        tab.btn.BackgroundColor3 = Color3.fromRGB(60, 75, 200) -- Inactive color
    end

    -- Create Tab Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -60, 0, 7)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Active color
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(84, 101, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = self.tabHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    -- Create Tab Page (Scrolling Frame)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(84, 101, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = true
    page.Parent = self.contentContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = page

    local tabData = {btn = btn, page = page, layoutOrder = 0}
    table.insert(self.tabs, tabData)

    -- Tab Switching Logic
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
            t.page.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(60, 75, 200)
            t.btn.TextColor3 = Color3.fromRGB(150, 150, 200)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextColor3 = Color3.fromRGB(84, 101, 255)
    end)

    -- Return Tab Class
    local Tab = {}
    Tab.__index = Tab
    setmetatable(Tab, {__index = function(_, key) return tabData[key] end})

    function Tab:Section(text)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local sectionLabel = Instance.new("TextLabel")
        sectionLabel.Size = UDim2.new(1, 0, 0, 25)
        sectionLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sectionLabel.BorderSizePixel = 0
        sectionLabel.Text = text
        sectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        sectionLabel.Font = Enum.Font.GothamBold
        sectionLabel.TextSize = 13
        sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        sectionLabel.LayoutOrder = tabData.layoutOrder
        sectionLabel.Parent = page
        Instance.new("UICorner", sectionLabel).CornerRadius = UDim.new(0, 5)
        Instance.new("UIPadding", sectionLabel).PaddingLeft = UDim.new(0, 10)
    end

    function Tab:Button(text, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(84, 101, 255)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 14
        button.LayoutOrder = tabData.layoutOrder
        button.Parent = page
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
        button.MouseButton1Click:Connect(function() callback(button) end)
    end

    function Tab:Toggle(text, default, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local toggled = default
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.LayoutOrder = tabData.layoutOrder
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = frame

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 40, 0, 20)
        track.Position = UDim2.new(1, -50, 0.5, -10)
        track.BackgroundColor3 = toggled and Color3.fromRGB(84, 101, 255) or Color3.fromRGB(100, 100, 100)
        track.BorderSizePixel = 0
        track.Parent = frame
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
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
            track.BackgroundColor3 = toggled and Color3.fromRGB(84, 101, 255) or Color3.fromRGB(100, 100, 100)
            indicator.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            callback(toggled)
        end)
    end

    function Tab:Slider(text, min, max, default, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local currentValue = default
        local isDraggingSlider = false
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 45)
        container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        container.BorderSizePixel = 0
        container.LayoutOrder = tabData.layoutOrder
        container.Parent = page
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(currentValue)
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 6)
        track.Position = UDim2.new(0, 10, 0, 32)
        track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        track.BorderSizePixel = 0
        track.Parent = container
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        local pct = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(84, 101, 255)
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
