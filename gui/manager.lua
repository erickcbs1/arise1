-- GUI Manager - Handles all GUI elements
local GuiManager = {}
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repository/main/gui/components.lua"))()
local Theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repository/main/gui/theme.lua"))()

-- Initialize GUI
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