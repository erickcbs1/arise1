-- Module Manager - Handles all hack modules
local ModuleManager = {}
local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/arise1/main/modules/fly.lua"))()
local NoClipModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/arise1/main/modules/noclip.lua"))()
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/arise1/main/modules/esp.lua"))()
local GodModeModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/arise1/main/modules/godmode.lua"))()
local SpeedModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/arise1/main/modules/speed.lua"))()
local JumpModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/arise1/main/modules/jump.lua"))()

-- Initialize module manager
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
