-- Main Entry Point for Quantum Hacks
-- All components are loaded via HttpGet

-- Base URL for raw GitHub content
local baseUrl = "https://raw.githubusercontent.com/erickcbs1/arise1/main/"

-- Utility function to load modules
local function loadModule(path)
    local success, content = pcall(function()
        return game:HttpGet(baseUrl .. path)
    end)
    
    if success then
        local func, err = loadstring(content)
        if func then
            return func()
        else
            warn("Failed to load module: " .. path .. "\nError: " .. tostring(err))
            return nil
        end
    else
        warn("Failed to fetch module: " .. path .. "\nError: " .. tostring(content))
        return nil
    end
end

-- Load all required modules
local Utils = loadModule("utils.lua")
local Theme = loadModule("gui/theme.lua")
local Components = loadModule("gui/components.lua")
local GuiManager = loadModule("gui/manager.lua")

-- Load hack modules
local FlyModule = loadModule("modules/fly.lua")
local NoClipModule = loadModule("modules/noclip.lua")
local ESPModule = loadModule("modules/esp.lua")
local GodModeModule = loadModule("modules/godmode.lua")
local SpeedModule = loadModule("modules/speed.lua")
local JumpModule = loadModule("modules/jump.lua")

-- Initialize hack framework
local HackFramework = {}

-- Framework initialization
function HackFramework:Initialize(config)
    self.config = config or {}
    self.active = true
    
    -- Initialize managers
    self.gui = GuiManager:Initialize(self.config)
    
    -- Register and initialize modules
    self.modules = {
        FlyModule,
        NoClipModule,
        ESPModule,
        GodModeModule,
        SpeedModule,
        JumpModule
    }
    
    -- Initialize each module
    for _, module in ipairs(self.modules) do
        if module and module.initialize then
            module:initialize(self)
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
            if input.KeyCode == (self.config.toggleKey or Enum.KeyCode.RightControl) then
                self.gui:ToggleVisibility()
            end
            
            -- Process module keybinds
            for _, module in ipairs(self.modules) do
                if module.keybind and module.keybind == input.KeyCode then
                    module.enabled = not module.enabled
                    if module.toggle then
                        module:toggle(module.enabled)
                    end
                end
            end
        end
    end)
end

-- Initialize with configuration
local config = {
    title = "Quantum Hacks v1.0",
    theme = "dark",
    defaultPosition = UDim2.new(0.5, -175, 0.5, -200),
    toggleKey = Enum.KeyCode.RightControl,
    saveSettings = true
}

-- Start the framework
local framework = HackFramework:Initialize(config)

-- Print success message
print("Quantum Hacks initialized successfully")

return framework
