-- Fly Module
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