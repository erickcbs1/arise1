

-- --[[ UTILS ]] --

local Utils = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ThirdPartyUserService = game:GetService("ThirdPartyUserService")
local LocalPlayer = Players.LocalPlayer

-- Check if value is valid
function Utils.isValid(value)
    return value ~= nil and value ~= ""
end

-- Check if an instance exists
function Utils.instanceExists(instance)
    return typeof(instance) == "Instance" and instance ~= nil and instance.Parent ~= nil
end

-- Get character safely
function Utils.getCharacter()
    local character = LocalPlayer.Character
    if not Utils.instanceExists(character) then return nil end
    return character
end

-- Get humanoid safely
function Utils.getHumanoid()
    local character = Utils.getCharacter()
    if not character then return nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not Utils.instanceExists(humanoid) then return nil end
    
    return humanoid
end

-- Get root part safely
function Utils.getRootPart()
    local character = Utils.getCharacter()
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not Utils.instanceExists(rootPart) then return nil end
    
    return rootPart
end

-- Get player from character
function Utils.getPlayerFromCharacter(character)
    if not Utils.instanceExists(character) then return nil end
    return Players:GetPlayerFromCharacter(character)
end

-- Check if a player is an enemy
function Utils.isEnemy(player)
    if player == LocalPlayer then return false end
    if not player or not player:IsA("Player") then return false end
    
    -- If teams are used
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    
    -- Assume all other players are enemies if no team system
    return true
end

-- Calculate distance between two positions
function Utils.getDistance(position1, position2)
    return (position1 - position2).Magnitude
end

-- Get all players in radius
function Utils.getPlayersInRadius(radius, teamCheck)
    local results = {}
    local rootPart = Utils.getRootPart()
    if not rootPart then return results end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Team check
        if teamCheck and not Utils.isEnemy(player) then continue end
        
        local character = player.Character
        if not Utils.instanceExists(character) then continue end
        
        local playerRootPart = character:FindFirstChild("HumanoidRootPart")
        if not Utils.instanceExists(playerRootPart) then continue end
        
        -- Check distance
        local distance = Utils.getDistance(rootPart.Position, playerRootPart.Position)
        if distance <= radius then
            table.insert(results, {
                player = player,
                character = character,
                rootPart = playerRootPart,
                distance = distance
            })
        end
    end
    
    -- Sort by distance
    table.sort(results, function(a, b)
        return a.distance < b.distance
    end)
    
    return results
end

-- Create a protective system
function Utils.protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game.CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game.CoreGui
    end
end

-- Get game place info
function Utils.getGameInfo()
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    
    if success then
        return info
    else
        return {
            Name = "Unknown Game",
            CreatorName = "Unknown Creator",
            PlaceId = game.PlaceId
        }
    end
end

-- Check if exploit supports a feature
function Utils.hasFeature(feature)
    if feature == "httpRequest" then
        return (syn and syn.request) or http_request or request or (http and http.request)
    elseif feature == "getNamecall" then
        return getnamecallmethod ~= nil
    elseif feature == "setReadOnly" then
        return setreadonly ~= nil
    elseif feature == "isClosure" then
        return is_synapse_function or iskrnlclosure or isexecutorclosure
    elseif feature == "getUpvalues" then
        return debug.getupvalues ~= nil
    elseif feature == "saveInstance" then
        return saveinstance ~= nil
    elseif feature == "gethui" then
        return gethui ~= nil
    elseif feature == "identifyexecutor" then
        return identifyexecutor ~= nil
    elseif feature == "firesignal" then
        return firesignal ~= nil
    end
    
    return false
end

-- Get executor name
function Utils.getExecutorName()
    if identifyexecutor then
        local success, result = pcall(identifyexecutor)
        if success then
            return result
        end
    end
    
    return "Unknown Executor"
end

-- Format time
function Utils.formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

-- Lerp between two values
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Smooth lerp (with ease)
function Utils.smoothLerp(a, b, t)
    t = t * t * (3 - 2 * t) -- Smoothstep
    return Utils.lerp(a, b, t)
end

return Utils

--[[ FILE: gui/theme.lua ]]--

-- Theme Manager - GUI appearance settings
local Theme = {}

-- Available themes
Theme.Themes = {
    dark = {
        -- Main colors
        background = Color3.fromRGB(25, 25, 30),
        backgroundLight = Color3.fromRGB(35, 35, 40),
        backgroundDark = Color3.fromRGB(20, 20, 25),
        
        -- Primary/accent colors
        primary = Color3.fromRGB(45, 120, 255),
        primaryLight = Color3.fromRGB(65, 140, 255),
        secondary = Color3.fromRGB(255, 165, 0),
        secondaryLight = Color3.fromRGB(255, 185, 20),
        
        -- Text colors
        textPrimary = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 180),
        
        -- Tab colors
        tabActive = Color3.fromRGB(45, 120, 255),
        tabInactive = Color3.fromRGB(40, 40, 45),
        tabHover = Color3.fromRGB(50, 50, 55),
        textActive = Color3.fromRGB(255, 255, 255),
        textInactive = Color3.fromRGB(180, 180, 180),
        
        -- Button colors
        success = Color3.fromRGB(40, 180, 99),
        successLight = Color3.fromRGB(50, 200, 120),
        warning = Color3.fromRGB(255, 165, 0),
        warningLight = Color3.fromRGB(255, 185, 20),
        danger = Color3.fromRGB(220, 50, 50),
        dangerLight = Color3.fromRGB(240, 70, 70),
        
        -- Toggle colors
        toggleOn = Color3.fromRGB(40, 180, 99),
        toggleOff = Color3.fromRGB(80, 80, 85)
    },
    
    light = {
        -- Main colors
        background = Color3.fromRGB(240, 240, 240),
        backgroundLight = Color3.fromRGB(250, 250, 250),
        backgroundDark = Color3.fromRGB(230, 230, 230),
        
        -- Primary/accent colors
        primary = Color3.fromRGB(0, 120, 215),
        primaryLight = Color3.fromRGB(30, 140, 235),
        secondary = Color3.fromRGB(255, 150, 0),
        secondaryLight = Color3.fromRGB(255, 170, 20),
        
        -- Text colors
        textPrimary = Color3.fromRGB(30, 30, 30),
        textSecondary = Color3.fromRGB(100, 100, 100),
        
        -- Tab colors
        tabActive = Color3.fromRGB(0, 120, 215),
        tabInactive = Color3.fromRGB(225, 225, 225),
        tabHover = Color3.fromRGB(210, 210, 210),
        textActive = Color3.fromRGB(255, 255, 255),
        textInactive = Color3.fromRGB(50, 50, 50),
        
        -- Button colors
        success = Color3.fromRGB(40, 170, 90),
        successLight = Color3.fromRGB(50, 190, 110),
        warning = Color3.fromRGB(240, 140, 0),
        warningLight = Color3.fromRGB(255, 160, 10),
        danger = Color3.fromRGB(220, 50, 50),
        dangerLight = Color3.fromRGB(240, 70, 70),
        
        -- Toggle colors
        toggleOn = Color3.fromRGB(40, 170, 90),
        toggleOff = Color3.fromRGB(180, 180, 180)
    }
}

-- Set the current theme (dark by default)
Theme.Current = Theme.Themes.dark

-- Switch theme
function Theme:SwitchTheme(themeName)
    if self.Themes[themeName] then
        self.Current = self.Themes[themeName]
        return true
    end
    return false
end

return Theme

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

function Components:UpdateToggleState(bg, handle, enabled)
	local goal = enabled and {BackgroundColor3 = Theme.Current.toggleOn, Position = UDim2.new(1, -22, 0.5, -10)} 
	                          or {BackgroundColor3 = Theme.Current.toggleOff, Position = UDim2.new(0, 2, 0.5, -10)}

	TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundColor3 = goal.BackgroundColor3}):Play()
	TweenService:Create(handle, TweenInfo.new(0.3), {Position = goal.Position}):Play()
end


return Components

-- Initialize GUI


-- --[[ GUI MANAGER ]] --

function GuiManager:Initialize(config)
    self.config = config
    self.visible = true
    self.minimized = false
    self.activeTab = "Main"
    
    -- Create the main GUI container
    self:CreateMainContainer()
    
    return self
end

-- Create the main GUI container
function GuiManager:CreateMainContainer()
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "QuantumHacksGui"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    pcall(function() syn.protect_gui(self.screenGui) end) -- Protection if available
    self.screenGui.Parent = game.CoreGui
    
    -- Create main frame
    self.mainFrame = Components:CreateMainFrame(self.config)
    self.mainFrame.Parent = self.screenGui
    
    -- Create title bar
    self.titleBar = Components:CreateTitleBar(self.config.title or "Quantum Hacks")
    self.titleBar.Parent = self.mainFrame
    
    -- Make GUI draggable
    self:MakeDraggable()
    
    -- Create tab container and main content area
    self.tabContainer = Components:CreateTabContainer()
    self.tabContainer.Parent = self.mainFrame
    
    self.contentContainer = Components:CreateContentContainer()
    self.contentContainer.Parent = self.mainFrame
    
    -- Create default tabs
    self:CreateTabs()
end

-- Create default tabs
function GuiManager:CreateTabs()
    local tabs = {"Main", "Movement", "Visual", "Combat", "Misc", "Settings"}
    
    for i, tabName in ipairs(tabs) do
        local tab = Components:CreateTab(tabName, i == 1)
        tab.Parent = self.tabContainer
        
        -- Tab click behavior
        tab.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
        
        -- Create content frame for this tab
        local contentFrame = Components:CreateContentFrame(tabName)
        contentFrame.Visible = (i == 1) -- Only first tab visible initially
        contentFrame.Parent = self.contentContainer
        
        -- Store reference to content frame
        self["content" .. tabName] = contentFrame
    end
end

-- Switch active tab
function GuiManager:SwitchTab(tabName)
    -- Hide all content frames
    for _, child in pairs(self.contentContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = false
        end
    end
    
    -- Update tab visuals
    for _, child in pairs(self.tabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            local isActive = (child.Name == tabName)
            child.BackgroundColor3 = isActive and Theme.Current.tabActive or Theme.Current.tabInactive
            child.TextColor3 = isActive and Theme.Current.textActive or Theme.Current.textInactive
        end
    end
    
    -- Show selected content
    if self["content" .. tabName] then
        self["content" .. tabName].Visible = true
        self.activeTab = tabName
    end
end

-- Toggle GUI visibility
function GuiManager:ToggleVisibility()
    self.visible = not self.visible
    self.screenGui.Enabled = self.visible
    
    -- Play animation
    if self.visible then
        self.mainFrame:TweenSize(
            UDim2.new(0, 350, 0, 400),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.3,
            true
        )
    end
end

-- Get current position
function GuiManager:GetPosition()
    return self.mainFrame.Position
end

-- Set position
function GuiManager:SetPosition(position)
    self.mainFrame.Position = position
end

-- Make the GUI draggable
function GuiManager:MakeDraggable()
    local UserInputService = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Add a module button to appropriate tab
function GuiManager:AddModuleButton(module)
    local tab = module.category or "Misc"
    local contentFrame = self["content" .. tab]
    
    if contentFrame then
        local button = Components:CreateModuleButton(module)
        button.Parent = contentFrame
        
        return button
    end
    
    return nil
end

return GuiManager


-- Initialize module manager


-- --[[ MODULE MANAGER ]] --

function ModuleManager:Initialize(framework)
    self.framework = framework
    self.modules = {}
    
    -- Register all modules
    self:RegisterModule(FlyModule)
    self:RegisterModule(NoClipModule)
    self:RegisterModule(ESPModule)
    self:RegisterModule(GodModeModule)
    self:RegisterModule(SpeedModule)
    self:RegisterModule(JumpModule)
    
    -- Create GUI elements for each module
    self:CreateModuleGUI()
    
    return self
end

-- Register a module
function ModuleManager:RegisterModule(module)
    if not module or not module.name then return end
    
    -- Initialize the module if needed
    if module.initialize then
        module:initialize(self.framework)
    end
    
    -- Add to modules list
    self.modules[module.name] = module
end

-- Create GUI elements for modules
function ModuleManager:CreateModuleGUI()
    for _, module in pairs(self.modules) do
        -- Create GUI element based on module category
        local button = self.framework.gui:AddModuleButton(module)
        
        -- Store button reference
        if button then
            module.button = button
        end
    end
end

-- Process keybind
function ModuleManager:ProcessKeybind(keyCode)
    for _, module in pairs(self.modules) do
        if module.keybind and module.keybind == keyCode then
            module.enabled = not module.enabled
            
            -- Update toggle in UI
            if module.button then
                local toggleBg = module.button:FindFirstChild("ToggleBackground")
                local toggleHandle = toggleBg and toggleBg:FindFirstChild("ToggleHandle")
                
                if toggleBg and toggleHandle then
                    self.framework.gui.Components:UpdateToggleState(toggleBg, toggleHandle, module.enabled)
                end
            end
            
            -- Call toggle function
            if module.toggle then
                module.toggle(module.enabled)
            end
        end
    end
end

-- Get settings for all modules
function ModuleManager:GetSettings()
    local settings = {}
    
    for name, module in pairs(self.modules) do
        settings[name] = {
            enabled = module.enabled
        }
        
        -- Add additional settings
        if module.getSettings then
            local moduleSettings = module:getSettings()
            for key, value in pairs(moduleSettings) do
                settings[name][key] = value
            end
        end
    end
    
    return settings
end

-- Apply saved settings to modules
function ModuleManager:ApplySettings(settings)
    for name, moduleSetting in pairs(settings) do
        local module = self.modules[name]
        
        if module then
            -- Apply enabled state
            if moduleSetting.enabled ~= nil then
                module.enabled = moduleSetting.enabled
                
                -- Call toggle function
                if module.toggle then
                    module.toggle(module.enabled)
                end
                
                -- Update UI
                if module.button then
                    local toggleBg = module.button:FindFirstChild("ToggleBackground")
                    local toggleHandle = toggleBg and toggleBg:FindFirstChild("ToggleHandle")
                    
                    if toggleBg and toggleHandle then
                        self.framework.gui.Components:UpdateToggleState(toggleBg, toggleHandle, module.enabled)
                    end
                end
            end
            
            -- Apply other settings
            if module.applySettings then
                module:applySettings(moduleSetting)
            end
        end
    end
end

return ModuleManager


--[[ FILE: modules/esp.lua ]]--

-- ESP Module


-- --[[ MODULE: ESP ]] --

local ESPModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Module properties
ESPModule.name = "ESP"
ESPModule.description = "See players through walls"
ESPModule.category = "Visual"
ESPModule.keybind = Enum.KeyCode.E
ESPModule.enabled = false

-- ESP settings
ESPModule.showNames = true
ESPModule.showBoxes = true
ESPModule.showDistance = true
ESPModule.showHealth = true
ESPModule.showTeam = true
ESPModule.teamCheck = true
ESPModule.maxDistance = 10000
ESPModule.refreshRate = 0.2 -- Update ESP every x seconds for performance

-- Module connections and containers
ESPModule.renderConnection = nil
ESPModule.playerAddedConnection = nil
ESPModule.playerRemovingConnection = nil
ESPModule.lastRefresh = 0
ESPModule.espObjects = {}

-- ESP colors
ESPModule.colors = {
    enemy = Color3.fromRGB(255, 0, 0),
    friendly = Color3.fromRGB(0, 255, 0),
    neutral = Color3.fromRGB(255, 255, 0)
}

-- Initialize module
function ESPModule:initialize(framework)
    self.framework = framework
    
    -- Setup player added/removed events
    self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if self.enabled then
            self:createESP(player)
        end
    end)
    
    self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        self:removeESP(player)
    end)
end

-- Toggle function
function ESPModule:toggle(state)
    self.enabled = state
    
    if state then
        self:startESP()
    else
        self:stopESP()
    end
end

-- Start ESP
function ESPModule:startESP()
    -- Create ESP for all existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:createESP(player)
        end
    end
    
    -- Setup render connection for updates
    self.renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        self:updateESP(deltaTime)
    end)
end

-- Create ESP for a player
function ESPModule:createESP(player)
    if player == LocalPlayer then return end
    
    -- Create container for this player's ESP objects
    self.espObjects[player] = {
        highlight = nil,
        billboard = nil,
        character = nil
    }
    
    -- If player already has a character
    if player.Character then
        self:setupCharacterESP(player, player.Character)
    end
    
    -- Listen for character added
    player.CharacterAdded:Connect(function(character)
        if self.enabled and self.espObjects[player] then
            self:setupCharacterESP(player, character)
        end
    end)
end

-- Setup ESP for a character
function ESPModule:setupCharacterESP(player, character)
    if not self.espObjects[player] then return end
    
    -- Store character reference
    self.espObjects[player].character = character
    
    -- Create highlight
    if self.showBoxes then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = self:getPlayerColor(player)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.2
        highlight.Parent = character
        
        self.espObjects[player].highlight = highlight
    end
    
    -- Create billboard GUI for text
    if self.showNames or self.showDistance or self.showHealth then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        billboard.AlwaysOnTop = true
        
        -- Create text label
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESPText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = self:getPlayerColor(player)
        textLabel.TextStrokeTransparency = 0.3
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.Parent = billboard
        
        billboard.Parent = character
        self.espObjects[player].billboard = billboard
    end
end

-- Update ESP visibility and information
function ESPModule:updateESP(deltaTime)
    -- Only update at refresh rate
    self.lastRefresh = self.lastRefresh + deltaTime
    if self.lastRefresh < self.refreshRate then return end
    self.lastRefresh = 0
    
    -- Update ESP for all players
    for player, espData in pairs(self.espObjects) do
        if not player or not player:IsDescendantOf(Players) then
            self:removeESP(player)
            continue
        end
        
        local character = player.Character
        if not character or not espData.character or character ~= espData.character then
            if character and self.enabled then
                self:setupCharacterESP(player, character)
            end
            continue
        end
        
        -- Check if character is alive
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart or humanoid.Health <= 0 then continue end
        
        -- Check distance
        local distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance > self.maxDistance then
            self:setESPVisibility(espData, false)
            continue
        end
        
        -- Team check
        if self.teamCheck and LocalPlayer.Team == player.Team and LocalPlayer.Team ~= nil then
            if not self.showTeam then
                self:setESPVisibility(espData, false)
                continue
            else
                -- Update color for team members
                self:updateESPColor(espData, self.colors.friendly)
            end
        else
            self:updateESPColor(espData, self:getPlayerColor(player))
        end
        
        -- Show ESP
        self:setESPVisibility(espData, true)
        
        -- Update text information
        if espData.billboard then
            local textLabel = espData.billboard:FindFirstChild("ESPText")
            if textLabel then
                local text = ""
                
                -- Name
                if self.showNames then
                    text = text .. player.Name .. "\n"
                end
                
                -- Distance
                if self.showDistance then
                    text = text .. math.floor(distance) .. " studs\n"
                end
                
                -- Health
                if self.showHealth and humanoid then
                    local healthPercentage = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    text = text .. "HP: " .. healthPercentage .. "%"
                end
                
                textLabel.Text = text
            end
        end
    end
end

-- Set ESP visibility
function ESPModule:setESPVisibility(espData, visible)
    if espData.highlight then
        espData.highlight.Enabled = visible
    end
    
    if espData.billboard then
        espData.billboard.Enabled = visible
    end
end

-- Update ESP color
function ESPModule:updateESPColor(espData, color)
    if espData.highlight then
        espData.highlight.FillColor = color
    end
    
    if espData.billboard then
        local textLabel = espData.billboard:FindFirstChild("ESPText")
        if textLabel then
            textLabel.TextColor3 = color
        end
    end
end

-- Get color for player based on team
function ESPModule:getPlayerColor(player)
    if LocalPlayer.Team and player.Team then
        if LocalPlayer.Team == player.Team then
            return self.colors.friendly
        else
            return self.colors.enemy
        end
    end
    
    return self.colors.neutral
end

-- Remove ESP for a player
function ESPModule:removeESP(player)
    local espData = self.espObjects[player]
    if not espData then return end
    
    -- Clean up ESP objects
    if espData.highlight and espData.highlight.Parent then
        espData.highlight:Destroy()
    end
    
    if espData.billboard and espData.billboard.Parent then
        espData.billboard:Destroy()
    end
    
    -- Remove from table
    self.espObjects[player] = nil
end

-- Stop ESP
function ESPModule:stopESP()
    -- Disconnect render connection
    if self.renderConnection then
        self.renderConnection:Disconnect()
        self.renderConnection = nil
    end
    
    -- Remove all ESP objects
    for player, _ in pairs(self.espObjects) do
        self:removeESP(player)
    end
    
    -- Clear table
    self.espObjects = {}
end

-- Clean up when module is unloaded
function ESPModule:cleanup()
    self:stopESP()
    
    if self.playerAddedConnection then
        self.playerAddedConnection:Disconnect()
        self.playerAddedConnection = nil
    end
    
    if self.playerRemovingConnection then
        self.playerRemovingConnection:Disconnect()
        self.playerRemovingConnection = nil
    end
end

-- Get module settings
function ESPModule:getSettings()
    return {
        showNames = self.showNames,
        showBoxes = self.showBoxes,
        showDistance = self.showDistance,
        showHealth = self.showHealth,
        showTeam = self.showTeam,
        teamCheck = self.teamCheck,
        maxDistance = self.maxDistance
    }
end

-- Apply saved settings
function ESPModule:applySettings(settings)
    for key, value in pairs(settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    -- Refresh ESP if it's enabled
    if self.enabled then
        self:stopESP()
        self:startESP()
    end
end

return ESPModule

--[[ FILE: modules/fly.lua ]]--

-- Fly Module


-- --[[ MODULE: FLY ]] --

local FlyModule = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Module properties
FlyModule.name = "Flight"
FlyModule.description = "Fly around freely"
FlyModule.category = "Movement"
FlyModule.keybind = Enum.KeyCode.F
FlyModule.enabled = false
FlyModule.speed = 2

-- Module connections
FlyModule.renderConnection = nil
FlyModule.bodyVelocity = nil

-- Initialize module
function FlyModule:initialize(framework)
    self.framework = framework
    
    -- Create settings
    self.speedMultiplier = 1
end

-- Toggle function
function FlyModule:toggle(state)
    self.enabled = state
    
    if state then
        self:startFlying()
    else
        self:stopFlying()
    end
end

-- Start flying
function FlyModule:startFlying()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Store original properties
    self.originalGravity = workspace.Gravity
    self.originalWalkSpeed = humanoid.WalkSpeed
    self.originalJumpPower = humanoid.JumpPower
    
    -- Create BodyVelocity for flying
    self.bodyVelocity = Instance.new("BodyVelocity")
    self.bodyVelocity.Name = "FlightForce"
    self.bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    self.bodyVelocity.Parent = rootPart
    
    -- Connect rendering to update flight
    self.renderConnection = RunService.RenderStepped:Connect(function()
        self:updateFlight()
    end)
    
    -- Apply anti-fall damage when enabled
    humanoid.StateChanged:Connect(function(oldState, newState)
        if self.enabled and newState == Enum.HumanoidStateType.Freefall then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- Update flight movement
function FlyModule:updateFlight()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or not self.bodyVelocity then return end
    
    -- Calculate movement direction
    local camera = workspace.CurrentCamera
    local flyDirection = Vector3.new(0, 0, 0)
    
    -- WASD movement
    local moveVector = humanoid.MoveDirection
    
    if moveVector.Magnitude > 0 then
        flyDirection = flyDirection + camera.CFrame:VectorToWorldSpace(moveVector)
    end
    
    -- Up/Down movement
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        flyDirection = flyDirection + Vector3.new(0, 1, 0)
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        flyDirection = flyDirection + Vector3.new(0, -1, 0)
    end
    
    -- Calculate speed
    local speed = self.speed * 60 * self.speedMultiplier
    
    -- Apply velocity
    if flyDirection.Magnitude > 0 then
        self.bodyVelocity.Velocity = flyDirection.Unit * speed
    else
        self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Stop flying
function FlyModule:stopFlying()
    if self.renderConnection then
        self.renderConnection:Disconnect()
        self.renderConnection = nil
    end
    
    if self.bodyVelocity and self.bodyVelocity.Parent then
        self.bodyVelocity:Destroy()
        self.bodyVelocity = nil
    end
    
    -- Restore original properties
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = self.originalWalkSpeed or 16
            humanoid.JumpPower = self.originalJumpPower or 50
        end
    end
    
    workspace.Gravity = self.originalGravity or 196.2
end

-- Get module settings
function FlyModule:getSettings()
    return {
        speedMultiplier = self.speedMultiplier
    }
end

-- Apply saved settings
function FlyModule:applySettings(settings)
    if settings.speedMultiplier then
        self.speedMultiplier = settings.speedMultiplier
    end
end

return FlyModule

--[[ FILE: modules/godmode.lua ]]--

-- God Mode Module


-- --[[ MODULE: GODMODE ]] --

local GodModeModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Module properties
GodModeModule.name = "God Mode"
GodModeModule.description = "Become invincible"
GodModeModule.category = "Combat"
GodModeModule.keybind = Enum.KeyCode.G
GodModeModule.enabled = false

-- Module connections
GodModeModule.healthConnection = nil
GodModeModule.characterAddedConnection = nil

-- Module settings
GodModeModule.autoHeal = true
GodModeModule.preventFallDamage = true
GodModeModule.preventDrowning = true
GodModeModule.method = "SetHealth" -- Options: "SetHealth", "HookDamage", "Forcefield"

-- Initialize module
function GodModeModule:initialize(framework)
    self.framework = framework
    
    -- Connect to character added event
    self.characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if self.enabled then
            self:applyGodMode(character)
        end
    end)
end

-- Toggle function
function GodModeModule:toggle(state)
    self.enabled = state
    
    if state then
        local character = LocalPlayer.Character
        if character then
            self:applyGodMode(character)
        end
    else
        self:removeGodMode()
    end
end

-- Apply God Mode to character
function GodModeModule:applyGodMode(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Store original properties
    self.originalMaxHealth = humanoid.MaxHealth
    self.originalHealth = humanoid.Health
    
    -- Different methods of god mode
    if self.method == "SetHealth" then
        -- Method 1: Set health to a very high value
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        -- Connect to health changed to keep health at max
        self.healthConnection = humanoid.HealthChanged:Connect(function(health)
            if health < humanoid.MaxHealth and self.autoHeal then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    elseif self.method == "HookDamage" then
        -- Method 2: Hook into damage events
        local hookHealth = Instance.new("NumberValue")
        hookHealth.Name = "HookHealth"
        hookHealth.Value = 100
        hookHealth.Parent = humanoid
        
        -- Store original health-related functions
        local oldTakeDamage = humanoid.TakeDamage
        local oldSetHealth = humanoid.Health
        
        -- Override health functions
        humanoid.TakeDamage = function() end
        humanoid.Health = hookHealth.Value
        
        -- Connect to health changed
        self.healthConnection = hookHealth.Changed:Connect(function(value)
            if value < 100 and self.autoHeal then
                hookHealth.Value = 100
            end
        end)
    elseif self.method == "Forcefield" then
        -- Method 3: Create a forcefield
        local forcefield = Instance.new("ForceField")
        forcefield.Name = "GodModeForceField"
        forcefield.Visible = false
        forcefield.Parent = character
        
        self.forcefield = forcefield
    end
    
    -- Additional protections
    if self.preventFallDamage then
        -- Connect to state changed to prevent fall damage
        humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
    
    if self.preventDrowning then
        -- Override oxygen to prevent drowning
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    end
end

-- Remove God Mode
function GodModeModule:removeGodMode()
    if self.healthConnection then
        self.healthConnection:Disconnect()
        self.healthConnection = nil
    end
    
    -- Remove forcefield if it exists
    if self.forcefield and self.forcefield.Parent then
        self.forcefield:Destroy()
        self.forcefield = nil
    end
    
    -- Restore original health
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if self.originalMaxHealth then
                humanoid.MaxHealth = self.originalMaxHealth
            end
            
            if self.originalHealth then
                humanoid.Health = self.originalHealth
            end
            
            -- Re-enable swimming state
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        end
    end
end

-- Clean up when module is unloaded
function GodModeModule:cleanup()
    self:removeGodMode()
    
    if self.characterAddedConnection then
        self.characterAddedConnection:Disconnect()
        self.characterAddedConnection = nil
    end
end

-- Get module settings
function GodModeModule:getSettings()
    return {
        autoHeal = self.autoHeal,
        preventFallDamage = self.preventFallDamage,
        preventDrowning = self.preventDrowning,
        method = self.method
    }
end

-- Apply saved settings
function GodModeModule:applySettings(settings)
    for key, value in pairs(settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    -- Refresh god mode if it's enabled
    if self.enabled then
        self:removeGodMode()
        
        local character = LocalPlayer.Character
        if character then
            self:applyGodMode(character)
        end
    end
end

return GodModeModule

--[[ FILE: modules/jump.lua ]]--

-- Jump Module


-- --[[ MODULE: JUMP ]] --

local JumpModule = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Module properties
JumpModule.name = "Jump Power"
JumpModule.description = "Boost jump height"
JumpModule.category = "Movement"
JumpModule.keybind = Enum.KeyCode.J
JumpModule.enabled = false

-- Jump settings
JumpModule.jumpMultiplier = 2.5
JumpModule.maxJumpPower = 250
JumpModule.infiniteJump = true

-- Module connections
JumpModule.jumpConnection = nil
JumpModule.characterAddedConnection = nil

-- Initialize module
function JumpModule:initialize(framework)
    self.framework = framework
    
    -- Connect to character added event
    self.characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if self.enabled then
            self:applyJumpBoost(character)
        end
    end)
    
    -- Setup infinite jump
    self.jumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if self.enabled and self.infiniteJump and input.KeyCode == Enum.KeyCode.Space then
            self:doInfiniteJump()
        end
    end)
end

-- Toggle function
function JumpModule:toggle(state)
    self.enabled = state
    
    if state then
        local character = LocalPlayer.Character
        if character then
            self:applyJumpBoost(character)
        end
    else
        self:resetJumpPower()
    end
end

-- Apply jump boost to character
function JumpModule:applyJumpBoost(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Store original jump power
    self.originalJumpPower = humanoid.JumpPower
    
    -- Apply jump boost
    humanoid.JumpPower = math.min(
        self.originalJumpPower * self.jumpMultiplier,
        self.maxJumpPower
    )
    
    -- Enable using Humanoid.UseJumpPower if available
    pcall(function()
        humanoid.UseJumpPower = true
    end)
end

-- Perform infinite jump
function JumpModule:doInfiniteJump()
    if not self.infiniteJump then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.Parent then return end
    
    -- Only allow infinite jump if not already jumping
    if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and
       humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        -- Apply velocity-based jump for more consistent results
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Create temporary BodyVelocity for the jump
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "InfiniteJumpForce"
            bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVel.Velocity = Vector3.new(0, math.sqrt(humanoid.JumpPower) * 5, 0)
            bodyVel.Parent = rootPart
            
            -- Remove the force after a short time
            task.delay(0.15, function()
                if bodyVel and bodyVel.Parent then
                    bodyVel:Destroy()
                end
            end)
        end
    end
end

-- Reset jump power to normal
function JumpModule:resetJumpPower()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Restore original jump power
    if self.originalJumpPower then
        humanoid.JumpPower = self.originalJumpPower
    end
end

-- Clean up when module is unloaded
function JumpModule:cleanup()
    self:resetJumpPower()
    
    if self.characterAddedConnection then
        self.characterAddedConnection:Disconnect()
        self.characterAddedConnection = nil
    end
    
    if self.jumpConnection then
        self.jumpConnection:Disconnect()
        self.jumpConnection = nil
    end
end

-- Get module settings
function JumpModule:getSettings()
    return {
        jumpMultiplier = self.jumpMultiplier,
        maxJumpPower = self.maxJumpPower,
        infiniteJump = self.infiniteJump
    }
end

-- Apply saved settings
function JumpModule:applySettings(settings)
    for key, value in pairs(settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    -- Refresh jump power if module is enabled
    if self.enabled then
        self:resetJumpPower()
        
        local character = LocalPlayer.Character
        if character then
            self:applyJumpBoost(character)
        end
    end
end

return JumpModule

--[[ FILE: modules/noclip.lua ]]--

-- NoClip Module


-- --[[ MODULE: NOCLIP ]] --

local NoClipModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Module properties
NoClipModule.name = "NoClip"
NoClipModule.description = "Pass through objects"
NoClipModule.category = "Movement"
NoClipModule.keybind = Enum.KeyCode.N
NoClipModule.enabled = false

-- Module connections
NoClipModule.steppedConnection = nil
NoClipModule.characterAddedConnection = nil
NoClipModule.cachedParts = {}

-- Initialize module
function NoClipModule:initialize(framework)
    self.framework = framework
    
    -- Connect to character added event to handle respawns
    self.characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        if self.enabled then
            self:disableCollisions(newCharacter)
        end
    end)
end

-- Toggle function
function NoClipModule:toggle(state)
    self.enabled = state
    
    if state then
        self:startNoClip()
    else
        self:stopNoClip()
    end
end

-- Start NoClip
function NoClipModule:startNoClip()
    local character = LocalPlayer.Character
    if character then
        self:disableCollisions(character)
    end
    
    -- Connect to stepped to continuously disable collisions
    self.steppedConnection = RunService.Stepped:Connect(function()
        if not self.enabled then return end
        
        local character = LocalPlayer.Character
        if character then
            self:disableCollisions(character)
        end
    end)
end

-- Disable collisions for all parts in character
function NoClipModule:disableCollisions(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Store original collision state
            if self.cachedParts[part] == nil then
                self.cachedParts[part] = part.CanCollide
            end
            
            -- Disable collision
            part.CanCollide = false
        end
    end
end

-- Stop NoClip
function NoClipModule:stopNoClip()
    if self.steppedConnection then
        self.steppedConnection:Disconnect()
        self.steppedConnection = nil
    end
    
    -- Restore original collision settings
    for part, originalState in pairs(self.cachedParts) do
        if part and part:IsA("BasePart") and part.Parent then
            part.CanCollide = originalState
        end
    end
    
    -- Clear cache
    self.cachedParts = {}
end

-- Clean up when module is unloaded
function NoClipModule:cleanup()
    self:stopNoClip()
    
    if self.characterAddedConnection then
        self.characterAddedConnection:Disconnect()
        self.characterAddedConnection = nil
    end
end

return NoClipModule

--[[ FILE: modules/speed.lua ]]--

-- Speed Module


-- --[[ MODULE: SPEED ]] --

local SpeedModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Module properties
SpeedModule.name = "Speed Boost"
SpeedModule.description = "Increase movement speed"
SpeedModule.category = "Movement"
SpeedModule.keybind = Enum.KeyCode.Q
SpeedModule.enabled = false

-- Speed settings
SpeedModule.speedMultiplier = 3
SpeedModule.maxSpeed = 100
SpeedModule.sprintKey = Enum.KeyCode.LeftShift
SpeedModule.sprintMultiplier = 1.5

-- Module connections
SpeedModule.updateConnection = nil
SpeedModule.characterAddedConnection = nil

-- Initialize module
function SpeedModule:initialize(framework)
    self.framework = framework
    
    -- Connect to character added event
    self.characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if self.enabled then
            self:applySpeed(character)
        end
    end)
end

-- Toggle function
function SpeedModule:toggle(state)
    self.enabled = state
    
    if state then
        local character = LocalPlayer.Character
        if character then
            self:applySpeed(character)
        end
    else
        self:resetSpeed()
    end
end

-- Apply speed to character
function SpeedModule:applySpeed(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Store original walk speed
    self.originalWalkSpeed = humanoid.WalkSpeed
    
    -- Apply speed boost
    humanoid.WalkSpeed = self.originalWalkSpeed * self.speedMultiplier
    
    -- Setup sprinting if not already connected
    if not self.updateConnection then
        self.updateConnection = RunService.Heartbeat:Connect(function()
            self:updateSpeed()
        end)
    end
end

-- Update speed (for sprint)
function SpeedModule:updateSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Check for sprint key
    if UserInputService:IsKeyDown(self.sprintKey) then
        humanoid.WalkSpeed = math.min(
            self.originalWalkSpeed * self.speedMultiplier * self.sprintMultiplier,
            self.maxSpeed
        )
    else
        humanoid.WalkSpeed = self.originalWalkSpeed * self.speedMultiplier
    end
end

-- Reset speed to normal
function SpeedModule:resetSpeed()
    if self.updateConnection then
        self.updateConnection:Disconnect()
        self.updateConnection = nil
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Restore original walk speed
    if self.originalWalkSpeed then
        humanoid.WalkSpeed = self.originalWalkSpeed
    end
end

-- Clean up when module is unloaded
function SpeedModule:cleanup()
    self:resetSpeed()
    
    if self.characterAddedConnection then
        self.characterAddedConnection:Disconnect()
        self.characterAddedConnection = nil
    end
end

-- Get module settings
function SpeedModule:getSettings()
    return {
        speedMultiplier = self.speedMultiplier,
        maxSpeed = self.maxSpeed,
        sprintMultiplier = self.sprintMultiplier
    }
end

-- Apply saved settings
function SpeedModule:applySettings(settings)
    for key, value in pairs(settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    -- Refresh speed if module is enabled
    if self.enabled then
        self:resetSpeed()
        
        local character = LocalPlayer.Character
        if character then
            self:applySpeed(character)
        end
    end
end

return SpeedModule

-- Framework initialization


-- --[[ FRAMEWORK ]] --

function HackFramework:Initialize(config)
    self.config = config or {}
    self.active = true
    
    -- Initialize managers
    self.gui = GuiManager:Initialize(self.config)
    self.modules = ModuleManager:Initialize(self)
    
    -- Load saved settings if enabled
    if self.config.saveSettings then
        self:LoadSettings()
    end
    
    -- Setup default keybinds
    self:SetupKeybinds()
    
    return self
end

-- Setup keybind controls
function HackFramework:SetupKeybinds()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Main toggle keybind
            if input.KeyCode == (self.config.toggleKey or Enum.KeyCode.RightControl) then
                self.gui:ToggleVisibility()
            end
            
            -- Process other keybinds
            self.modules:ProcessKeybind(input.KeyCode)
        end
    end)
end

-- Save current settings
function HackFramework:SaveSettings()
    if not self.config.saveSettings then return end
    
    local settings = {
        position = self.gui:GetPosition(),
        modules = self.modules:GetSettings()
    }
    
    -- Convert to JSON and save using Roblox's built-in HttpService
    local HttpService = game:GetService("HttpService")
    local json = HttpService:JSONEncode(settings)
    
    -- Use a safer storage method than WriteCFrame
    pcall(function()
        local key = "QuantumHacksSettings_" .. game.PlaceId
        if syn then
            syn.write_clipboard(json) -- Some exploits allow writing to clipboard
        elseif writefile then
            writefile(key .. ".json", json)
        end
    end)
end

-- Load saved settings
function HackFramework:LoadSettings()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local key = "QuantumHacksSettings_" .. game.PlaceId
        local json
        
        if syn and readfile then
            if isfile(key .. ".json") then
                json = readfile(key .. ".json")
            end
        elseif readfile then
            if isfile(key .. ".json") then
                json = readfile(key .. ".json")
            end
        end
        
        if json then
            local settings = HttpService:JSONDecode(json)
            
            -- Apply settings
            if settings.position then
                self.gui:SetPosition(settings.position)
            end
            
            if settings.modules then
                self.modules:ApplySettings(settings.modules)
            end
        end
    end)
end

return HackFramework


--[[ FILE: main.lua ]]--

-- Main Entry Point for Quantum Hacks
-- All components are loaded via HttpGet

-- Base URL for raw GitHub content
local baseUrl = "https://raw.githubusercontent.com/erickcbs1/arise1/main/"

-- Utility function to load modules with error handling
local function loadModule(path)
    local success, content = pcall(function()
        return game:HttpGet(baseUrl .. path)
    end)
    
    if not success then
        warn("Failed to fetch module: " .. path .. "\nError: " .. tostring(content))
        return nil
    end

    -- Add error context to help with debugging
    local wrapped = string.format([[
        local success, result = pcall(function()
            local moduleFunc = function()
                %s
            end
            return moduleFunc()
        end)

        if not success then
            warn("Error in module: %s\n" .. result)
            return nil
        end

        return result
    ]], content, path)
    
    local func, err = loadstring(wrapped)
    if not func then
        warn("Failed to parse module: " .. path .. "\nError: " .. tostring(err))
        return nil
    end
    
    local successExec, result = pcall(func)
    if not successExec then
        warn("Failed to execute module: " .. path .. "\nError: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Load core modules with fallbacks
local Utils = loadModule("utils.lua") or {}
local Theme = loadModule("gui/theme.lua") or {
    Current = {
        background = Color3.fromRGB(25, 25, 30),
        primary = Color3.fromRGB(45, 120, 255),
        textPrimary = Color3.fromRGB(255, 255, 255)
    }
}
local Components = loadModule("gui/components.lua") or {}
local GuiManager = loadModule("gui/manager.lua") or {}

-- Load hack modules with validation
local function loadHackModule(path, fallback)
    local module = loadModule("modules/" .. path) or fallback
    if module then
        -- Ensure required properties exist
        module.name = module.name or "Unknown Module"
        module.description = module.description or ""
        module.category = module.category or "Misc"
        module.enabled = module.enabled or false
        module.toggle = module.toggle or function() end
    end
    return module
end

local modules = {
    FlyModule = loadHackModule("fly.lua", {
        name = "Flight",
        description = "Basic flight functionality",
        category = "Movement",
        enabled = false,
        toggle = function() end
    }),
    NoClipModule = loadHackModule("noclip.lua"),
    ESPModule = loadHackModule("esp.lua"),
    GodModeModule = loadHackModule("godmode.lua"),
    SpeedModule = loadHackModule("speed.lua"),
    JumpModule = loadHackModule("jump.lua")
}

-- Initialize hack framework
local HackFramework = {
    config = {
        title = "Quantum Hacks v1.0",
        theme = "dark",
        defaultPosition = UDim2.new(0.5, -175, 0.5, -200),
        toggleKey = Enum.KeyCode.RightControl,
        saveSettings = true
    },
    modules = {},
    active = true
}

-- Framework initialization
function HackFramework:Initialize()
    -- Create basic GUI if GuiManager failed to load
    if not GuiManager.Initialize then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "QuantumHacksGui"
        
        -- Protect GUI from game detection
        pcall(function() syn.protect_gui(screenGui) end)
        screenGui.Parent = game:GetService("CoreGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 100)
        frame.Position = UDim2.new(0.5, -100, 0.5, -50)
        frame.BackgroundColor3 = Theme.Current.background
        frame.Parent = screenGui
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = "Quantum Hacks Lite"
        text.TextColor3 = Theme.Current.textPrimary
        text.Parent = frame
        
        return
    end
    
    -- Initialize GUI manager
    self.gui = GuiManager:Initialize(self.config)
    
    -- Initialize valid modules
    for name, module in pairs(modules) do
        if module and type(module) == "table" then
            if module.initialize then
                module:initialize(self)
            end
            table.insert(self.modules, module)
        end
    end
    
    -- Setup keybinds
    self:SetupKeybinds()
    
    return self
end

-- Setup keybind controls
function HackFramework:SetupKeybinds()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Main toggle keybind
            if input.KeyCode == self.config.toggleKey then
                if self.gui and self.gui.ToggleVisibility then
                    self.gui:ToggleVisibility()
                end
            end
            
            -- Process module keybinds
            for _, module in ipairs(self.modules) do
                if module.keybind and module.keybind == input.KeyCode then
                    module.enabled = not module.enabled
                    if module.toggle then
                        pcall(function() module:toggle(module.enabled) end)
                    end
                end
            end
        end
    end)
end

-- Start the framework
local success, err = pcall(function()
    HackFramework:Initialize()
end)

if not success then
    warn("Failed to initialize Quantum Hacks:\n" .. tostring(err))
    -- Create minimal error GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QuantumHacksError"
    pcall(function() syn.protect_gui(screenGui) end)
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    frame.Parent = screenGui
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.Text = "Failed to load Quantum Hacks\nCheck console for details"
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextWrapped = true
    text.Parent = frame
end

return HackFramework
