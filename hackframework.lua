-- Hack Framework - Main Handler
local HackFramework = {}
local GuiManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/repository/main/gui/manager.lua"))()
local ModuleManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/repository/main/modules/manager.lua"))()
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/erickcbs1/repository/main/utils.lua"))()

-- Framework initialization
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
