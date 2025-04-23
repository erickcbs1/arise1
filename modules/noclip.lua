-- NoClip Module
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