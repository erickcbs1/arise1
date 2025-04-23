-- GUI Components - Reusable UI elements
local Components = {}
local Theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repository/main/gui/theme.lua"))()
local TweenService = game:GetService("TweenService")

-- Create the main frame
function Components:CreateMainFrame(config)
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 350, 0, 400)
    frame.Position = config.defaultPosition or UDim2.new(0.5, -175, 0.5, -200)
    frame.BackgroundColor3 = Theme.Current.background
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Add shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.SliceScale = 1
    shadow.ZIndex = -1
    shadow.Parent = frame
    
    -- Create smooth entrance animation
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local goalSize = UDim2.new(0, 350, 0, 400)
    local goalPosition = config.defaultPosition or UDim2.new(0.5, -175, 0.5, -200)
    
    -- Remove anchor point after animation
    frame.AnchorPoint = Vector2.new(0, 0)
    
    local tween = TweenService:Create(frame, tweenInfo, {Size = goalSize, Position = goalPosition})
    tween:Play()
    
    return frame
end

-- Create title bar
function Components:CreateTitleBar(title)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Theme.Current.primary
    titleBar.BorderSizePixel = 0
    
    -- Add corner rounding only to top corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = titleBar
    
    -- Add a frame to remove bottom corners rounding
    local bottomCover = Instance.new("Frame")
    bottomCover.Name = "BottomCover"
    bottomCover.Size = UDim2.new(1, 0, 0.5, 0)
    bottomCover.Position = UDim2.new(0, 0, 0.5, 0)
    bottomCover.BackgroundColor3 = Theme.Current.primary
    bottomCover.BorderSizePixel = 0
    bottomCover.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = Theme.Current.textPrimary
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Theme.Current.danger
    closeButton.Text = "✖"
    closeButton.TextColor3 = Theme.Current.textPrimary
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.BorderSizePixel = 0
    closeButton.AutoButtonColor = false
    
    -- Add corner to close button
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Close button hover effect
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Current.dangerLight}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Current.danger}):Play()
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        -- Destroy the GUI with animation
        local mainFrame = titleBar.Parent
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        -- Set anchor point for center shrinking
        mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        local originalPosition = mainFrame.Position
        local centerX = originalPosition.X.Scale + (originalPosition.X.Offset + mainFrame.Size.X.Offset/2)/game.Workspace.CurrentCamera.ViewportSize.X
        local centerY = originalPosition.Y.Scale + (originalPosition.Y.Offset + mainFrame.Size.Y.Offset/2)/game.Workspace.CurrentCamera.ViewportSize.Y
        mainFrame.Position = UDim2.new(centerX, 0, centerY, 0)
        
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
        tween:Play()
        
        tween.Completed:Connect(function()
            mainFrame.Parent:Destroy()
        end)
    end)
    
    closeButton.Parent = titleBar
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0, 5)
    minimizeButton.BackgroundColor3 = Theme.Current.secondary
    minimizeButton.Text = "—"
    minimizeButton.TextColor3 = Theme.Current.textPrimary
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 14
    minimizeButton.BorderSizePixel = 0
    minimizeButton.AutoButtonColor = false
    
    -- Add corner to minimize button
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeButton
    
    -- Minimize button hover effect
    minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Current.secondaryLight}):Play()
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Current.secondary}):Play()
    end)
    
    -- Minimize button functionality
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        local mainFrame = titleBar.Parent
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if minimized then
            -- Store original size
            if not mainFrame:GetAttribute("OriginalHeight") then
                mainFrame:SetAttribute("OriginalHeight", mainFrame.Size.Y.Offset)
            end
            
            -- Minimize
            local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 40)})
            tween:Play()
        else
            -- Restore
            local originalHeight = mainFrame:GetAttribute("OriginalHeight") or 400
            local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, originalHeight)})
            tween:Play()
        end
    end)
    
    minimizeButton.Parent = titleBar
    
    return titleBar
end

-- Create tab container
function Components:CreateTabContainer()
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 35)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Theme.Current.backgroundLight
    tabContainer.BorderSizePixel = 0
    
    -- Add list layout for tabs
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = tabContainer
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = tabContainer
    
    return tabContainer
end

-- Create a tab button
function Components:CreateTab(name, isActive)
    local tab = Instance.new("TextButton")
    tab.Name = name
    tab.Size = UDim2.new(0, 70, 0, 25)
    tab.BackgroundColor3 = isActive and Theme.Current.tabActive or Theme.Current.tabInactive
    tab.Text = name
    tab.TextColor3 = isActive and Theme.Current.textActive or Theme.Current.textInactive
    tab.Font = Enum.Font.Gotham
    tab.TextSize = 14
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tab
    
    -- Hover effect
    tab.MouseEnter:Connect(function()
        if tab.BackgroundColor3 ~= Theme.Current.tabActive then
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Current.tabHover}):Play()
        end
    end)
    
    tab.MouseLeave:Connect(function()
        if tab.BackgroundColor3 ~= Theme.Current.tabActive then
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Current.tabInactive}):Play()
        end
    end)
    
    return tab
end

-- Create content container
function Components:CreateContentContainer()
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, -75)
    contentContainer.Position = UDim2.new(0, 0, 0, 75)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    
    return contentContainer
end

-- Create content frame for each tab
function Components:CreateContentFrame(name)
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = name .. "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -20)
    contentFrame.Position = UDim2.new(0, 10, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Theme.Current.primary
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will auto-adjust
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = contentFrame
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = contentFrame
    
    return contentFrame
end

-- Create a module button with toggle
function Components:CreateModuleButton(module)
    local moduleFrame = Instance.new("Frame")
    moduleFrame.Name = module.name .. "Module"
    moduleFrame.Size = UDim2.new(1, -20, 0, 45)
    moduleFrame.BackgroundColor3 = Theme.Current.backgroundDark
    moduleFrame.BorderSizePixel = 0
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = moduleFrame
    
    -- Module name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ModuleName"
    nameLabel.Size = UDim2.new(0.7, -10, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = module.name
    nameLabel.TextColor3 = Theme.Current.textPrimary
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = moduleFrame
    
    -- Module description (if provided)
    if module.description then
        nameLabel.Size = UDim2.new(0.7, -10, 0.5, 0)
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "ModuleDescription"
        descLabel.Size = UDim2.new(0.7, -10, 0.5, 0)
        descLabel.Position = UDim2.new(0, 10, 0.5, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = module.description
        descLabel.TextColor3 = Theme.Current.textSecondary
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = moduleFrame
    end
    
    -- Create toggle switch
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "ToggleBackground"
    toggleBackground.Size = UDim2.new(0, 50, 0, 24)
    toggleBackground.Position = UDim2.new(1, -60, 0.5, -12)
    toggleBackground.BackgroundColor3 = Theme.Current.toggleOff
    toggleBackground.BorderSizePixel = 0
    
    -- Add corner to toggle
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBackground
    
    -- Create toggle handle
    local toggleHandle = Instance.new("Frame")
    toggleHandle.Name = "ToggleHandle"
    toggleHandle.Size = UDim2.new(0, 20, 0, 20)
    toggleHandle.Position = UDim2.new(0, 2, 0.5, -10)
    toggleHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleHandle.BorderSizePixel = 0
    
    -- Add corner to handle
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = toggleHandle
    
    toggleHandle.Parent = toggleBackground
    toggleBackground.Parent = moduleFrame
    
    -- Make toggle clickable
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            module.enabled = not module.enabled
            self:UpdateToggleState(toggleBackground, toggleHandle, module.enabled)
            
            -- Call module toggle function
            if module.toggle then
                module.toggle(module.enabled)
            end
        end
    end)
    
    -- Initial state
    if module.enabled then
        self:UpdateToggleState(toggleBackground, toggleHandle, true)
    end
    
    -- Keybind display (if provided)
    if module.keybind then
        local keybindLabel = Instance.new("TextLabel")
        keybindLabel.Name = "KeybindLabel"
        keybindLabel.Size = UDim2.new(0, 40, 0, 20)
        keybindLabel.Position = UDim2.new(1, -120, 0.5, -10)
        keybindLabel.BackgroundColor3 = Theme.Current.backgroundLight
        keybindLabel.BorderSizePixel = 0
        keybindLabel.Text = string.sub(tostring(module.keybind), 14)
        keybindLabel.TextColor3 = Theme.Current.textSecondary
        keybindLabel.Font = Enum.Font.Code
        keybindLabel.TextSize = 12
        
        -- Add corner
        local keybindCorner = Instance.new("UICorner")
        keybindCorner.CornerRadius = UDim.new(0, 4)
        keybindCorner.Parent = keybindLabel
        
        keybindLabel.Parent = moduleFrame
    end
    
    return moduleFrame
end

-- Update toggle state with animation
function Components:UpdateToggleState(background, handle, enabled)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if enabled then
        -- Animate to ON state
        TweenService:Create(background, tweenInfo, {BackgroundColor3 = Theme.Current.toggleOn}):Play()
        TweenService:Create(handle, tweenInfo, {Position = UDim2.new(0, 28, 0.5, -10)}):Play()
    else
        -- Animate to OFF state
        TweenService:Create(background, tweenInfo, {BackgroundColor3 = Theme.Current.toggleOff}):Play()
        TweenService:Create(handle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
    end
end

-- Create a slider component
function Components:CreateSlider(name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "Slider"
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.BackgroundColor3 = Theme.Current.backgroundDark
    sliderFrame.BorderSizePixel = 0
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = sliderFrame
    
    -- Slider name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "SliderName"
    nameLabel.Size = UDim2.new(1, -20, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.Current.textPrimary
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = sliderFrame
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 0, 25)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Current.textSecondary
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    -- Slider background
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "SliderBackground"
    sliderBackground.Size = UDim2.new(1, -20, 0, 10)
    sliderBackground.Position = UDim2.new(0, 10, 0, 35)
    sliderBackground.BackgroundColor3 = Theme.Current.backgroundLight
    sliderBackground.BorderSizePixel = 0
    
    -- Slider background corner
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 5)
    bgCorner.Parent = sliderBackground
    
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Current.primary
    sliderFill.BorderSizePixel = 0
    
    -- Slider fill corner
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = sliderFill
    
    sliderFill.Parent = sliderBackground
    
    -- Slider handle
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    
    -- Handle corner
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = sliderHandle
    
    sliderHandle.Parent = sliderBackground
    sliderBackground.Parent = sliderFrame
    
    -- Slider functionality
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local sliding = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        
        -- Update visuals
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderHandle.Position = UDim2.new(pos, -8, 0.5, -8)
        valueLabel.Text = tostring(value)
        
        -- Call callback
        callback(value)
    end
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return sliderFrame
end

return Components