-- God Mode Module
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