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
        local module = {}
        local success, result = pcall(function()
            %s
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
    
    local success, result = pcall(func)
    if not success then
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
