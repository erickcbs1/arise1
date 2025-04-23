-- Speed Module
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