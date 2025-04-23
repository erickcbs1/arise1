-- Jump Module
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