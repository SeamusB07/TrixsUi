-- ==========================================
-- TRIXUI LIBRARY (MODERN DARK EDITION v2)
-- ==========================================

local Theme = {
    Background = Color3.fromRGB(20, 20, 22),
    Topbar = Color3.fromRGB(15, 15, 17),
    Elements = Color3.fromRGB(30, 30, 34),
    Accent = Color3.fromRGB(0, 195, 255),
    AccentHover = Color3.fromRGB(50, 215, 255),
    Text = Color3.fromRGB(230, 230, 235),
    MutedText = Color3.fromRGB(130, 130, 140),
    ToggleOff = Color3.fromRGB(60, 60, 65)
}

local TrixUI = {}
TrixUI.__index = TrixUI

local Window = {}
Window.__index = Window

function TrixUI.new(config)
    local self = setmetatable({}, Window)
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = config.Name or "TrixUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = game:GetService("CoreGui")

    -- Slightly wider to accommodate better spacing
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 480, 0, 340)
    self.mainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
    self.mainFrame.BackgroundColor3 = Theme.Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.screenGui
    Instance.new("UICorner", self.mainFrame).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = Theme.Topbar
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    -- FIX: Title text is locked to max 120px wide and truncates with "..." if too long
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 180, 1, 0)
    titleText.Position = UDim2.new(0, 16, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Name or "TrixUI"
    titleText.TextColor3 = Theme.Text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextTruncate = Enum.TextTruncate.AtEnd
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 15
    titleText.Parent = titleBar

    -- FIX: Tab holder is anchored strictly to the right side, far away from the title
    self.tabHolder = Instance.new("Frame")
    self.tabHolder.Size = UDim2.new(0, 140, 1, 0)
    self.tabHolder.Position = UDim2.new(1, -110, 0, 0)
    self.tabHolder.AnchorPoint = Vector2.new(1, 0)
    self.tabHolder.BackgroundTransparency = 1
    self.tabHolder.Parent = titleBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.tabHolder

    -- Content Container (Increased padding)
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Size = UDim2.new(1, -28, 1, -56)
    self.contentContainer.Position = UDim2.new(0, 14, 0, 50)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.ClipsDescendants = true
    self.contentContainer.Parent = self.mainFrame

    -- Window Controls
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -68, 0, 7)
    minimizeButton.BackgroundColor3 = Theme.Elements
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "—"
    minimizeButton.TextColor3 = Theme.MutedText
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 14
    minimizeButton.Parent = titleBar
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 6)

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -34, 0, 7)
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
        self.mainFrame.Size = isMinimized and UDim2.new(0, 280, 0, 44) or UDim2.new(0, 280, 0, 340)
        minimizeButton.Text = isMinimized and "+" or "—"
    end)

    closeButton.MouseButton1Click:Connect(function() self.screenGui:Destroy() end)

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
    btn.Size = UDim2.new(0, 50, 0, 26)
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

    -- FIX: Increased padding to 14px for much better breathing room
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 14)
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

    local Tab = {}
    Tab.__index = Tab
    setmetatable(Tab, {__index = function(_, key) return tabData[key] end})

    function Tab:Section(text)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 28) -- Slightly taller
        frame.BackgroundColor3 = Theme.Elements
        frame.BorderSizePixel = 0
        frame.LayoutOrder = tabData.layoutOrder
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -14, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
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
        button.Size = UDim2.new(1, 0, 0, 38) -- Slightly taller
        button.BackgroundColor3 = Theme.Accent
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Theme.Background
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.LayoutOrder = tabData.layoutOrder
        button.Parent = page
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

        button.MouseEnter:Connect(function() button.BackgroundColor3 = Theme.AccentHover end)
        button.MouseLeave:Connect(function() button.BackgroundColor3 = Theme.Accent end)

        button.MouseButton1Click:Connect(function() callback(button) end)
    end

    function Tab:Toggle(text, default, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local toggled = default
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 34) -- Slightly taller
        frame.BackgroundColor3 = Theme.Elements
        frame.BorderSizePixel = 0
        frame.LayoutOrder = tabData.layoutOrder
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -55, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.Parent = frame

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 40, 0, 20)
        track.Position = UDim2.new(1, -54, 0.5, -10)
        track.BackgroundColor3 = toggled and Theme.Accent or Theme.ToggleOff
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
            track.BackgroundColor3 = toggled and Theme.Accent or Theme.ToggleOff
            indicator.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            callback(toggled)
        end)
    end

    function Tab:Slider(text, min, max, default, callback)
        tabData.layoutOrder = tabData.layoutOrder + 1
        local currentValue = default
        local isDraggingSlider = false
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50) -- Slightly taller
        container.BackgroundColor3 = Theme.Elements
        container.BorderSizePixel = 0
        container.LayoutOrder = tabData.layoutOrder
        container.Parent = page
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -24, 0, 24)
        label.Position = UDim2.new(0, 14, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(currentValue)
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -28, 0, 6)
        track.Position = UDim2.new(0, 14, 0, 36)
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
        thumb.Size = UDim2.new(0, 16, 0, 16)
        thumb.Position = UDim2.new(pct, -8, 0.5, -8)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.Parent = track
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * relativeX)
            local newPct = (currentValue - min) / (max - min)
            fill.Size = UDim2.new(newPct, 0, 1, 0)
            thumb.Position = UDim2.new(newPct, -8, 0.5, -8)
            label.Text = text .. ": " .. tostring(currentValue)
            callback(currentValue)
        end

        function Tab:Dropdown(text, options, callback)
            local isOpen = false
            local currentSelection = text -- Default text shown
            
            -- 1.Base Frame
            local dropDownContainer = Instance.new("Frame")
            dropDownContainer.Size = UDim2.new(1, 0, 0, 34)
            dropDownContainer.BackgroundColor3 = Theme.Elements
            dropDownContainer.BorderSizePixel = 0
            Instance.new("UICorner", dropDownContainer).CornerRadius = UDim.new(0,8)
            dropDownContainer.LayoutOrder = tabData.layoutOrder
            dropDownContainer.Parent = page

            -- 2. Options List Container
            local optionsList = Instance.new("Frame")
            optionsList.Size = UDim2.new(1, 0, 0, 0)
            optionsList.AutomaticSize = Enum.AutomaticSize.Y
            optionsList.BackgroundColor3 = Theme.Elements
            optionsList.Visible = false
            optionsList.LayoutOrder = tabData.layoutOrder + 0.1
            optionsList.Parent = page

            --3 UIlistlayout
            local optionLayout = Instance.new("UIListLayout")
            optionLayout.Padding = UDim.new(0,4)
            optionLayout.Parent = optionsList

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -24, 0, 24)
            label.Position = UDim2.new(0, 14, 0, 2)
            label.BackgroundTransparency = 1
            label.Text = currentSelection
            label.TextColor3 = Theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.Parent = dropDownContainer

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 30, 1, 0) -- 30 pixels wide, fill height
            arrow.Position = UDim2.new(1, -30, 0, 0) -- Glued to the right edge
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Theme.MutedText
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 12
            arrow.Parent = dropDownContainer

                        -- 3 & 4. Loop through options and create buttons
            for i, optionName in pairs(options) do
                local optionBtn = Instance.new("TextButton")
                optionBtn.Size = UDim2.new(1, 0, 0, 28) 
                optionBtn.BackgroundColor3 = Theme.Elements
                optionBtn.BorderSizePixel = 0
                optionBtn.Text = optionName
                optionBtn.TextColor3 = Theme.Text
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.TextSize = 12
                Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 6)
                optionBtn.Parent = optionsList
                
                -- The Click Event for each option
                optionBtn.MouseButton1Click:Connect(function()
                    -- 1. Update the text on the main label
                    label.Text = optionName 
                    currentSelection = optionName
                    
                    -- 2. Fire the callback to tell the script what was chosen
                    callback(optionName)
                    
                    -- 3. Close the menu
                    optionsList.Visible = false
                    isOpen = false
                    arrow.Text = "▼"
                end)
            end

            -- 5. Toggle logic on the Base Container click
            -- (We use an invisible button over the whole container so it's clickable)
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 0, 1, 0)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = dropDownContainer

            clickDetector.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    optionsList.Visible = true
                    arrow.Text = "▲"
                else
                    optionsList.Visible = false
                    arrow.Text = "▼"
                end
            end)

        end -- End of Tab:Dropdown


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
