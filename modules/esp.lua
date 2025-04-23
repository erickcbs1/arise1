-- ESP Module
local ESPModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Module properties
ESPModule.name = "ESP"
ESPModule.description = "See players through walls"
ESPModule.category = "Visual"
ESPModule.keybind = Enum.KeyCode.E
ESPModule.enabled = false

-- ESP settings
ESPModule.showNames = true
ESPModule.showBoxes = true
ESPModule.showDistance = true
ESPModule.showHealth = true
ESPModule.showTeam = true
ESPModule.teamCheck = true
ESPModule.maxDistance = 10000
ESPModule.refreshRate = 0.2 -- Update ESP every x seconds for performance

-- Module connections and containers
ESPModule.renderConnection = nil
ESPModule.playerAddedConnection = nil
ESPModule.playerRemovingConnection = nil
ESPModule.lastRefresh = 0
ESPModule.espObjects = {}

-- ESP colors
ESPModule.colors = {
    enemy = Color3.fromRGB(255, 0, 0),
    friendly = Color3.fromRGB(0, 255, 0),
    neutral = Color3.fromRGB(255, 255, 0)
}

-- Initialize module
function ESPModule:initialize(framework)
    self.framework = framework
    
    -- Setup player added/removed events
    self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if self.enabled then
            self:createESP(player)
        end
    end)
    
    self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        self:removeESP(player)
    end)
end

-- Toggle function
function ESPModule:toggle(state)
    self.enabled = state
    
    if state then
        self:startESP()
    else
        self:stopESP()
    end
end

-- Start ESP
function ESPModule:startESP()
    -- Create ESP for all existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:createESP(player)
        end
    end
    
    -- Setup render connection for updates
    self.renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        self:updateESP(deltaTime)
    end)
end

-- Create ESP for a player
function ESPModule:createESP(player)
    if player == LocalPlayer then return end
    
    -- Create container for this player's ESP objects
    self.espObjects[player] = {
        highlight = nil,
        billboard = nil,
        character = nil
    }
    
    -- If player already has a character
    if player.Character then
        self:setupCharacterESP(player, player.Character)
    end
    
    -- Listen for character added
    player.CharacterAdded:Connect(function(character)
        if self.enabled and self.espObjects[player] then
            self:setupCharacterESP(player, character)
        end
    end)
end

-- Setup ESP for a character
function ESPModule:setupCharacterESP(player, character)
    if not self.espObjects[player] then return end
    
    -- Store character reference
    self.espObjects[player].character = character
    
    -- Create highlight
    if self.showBoxes then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = self:getPlayerColor(player)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.2
        highlight.Parent = character
        
        self.espObjects[player].highlight = highlight
    end
    
    -- Create billboard GUI for text
    if self.showNames or self.showDistance or self.showHealth then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        billboard.AlwaysOnTop = true
        
        -- Create text label
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESPText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = self:getPlayerColor(player)
        textLabel.TextStrokeTransparency = 0.3
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.Parent = billboard
        
        billboard.Parent = character
        self.espObjects[player].billboard = billboard
    end
end

-- Update ESP visibility and information
function ESPModule:updateESP(deltaTime)
    -- Only update at refresh rate
    self.lastRefresh = self.lastRefresh + deltaTime
    if self.lastRefresh < self.refreshRate then return end
    self.lastRefresh = 0
    
    -- Update ESP for all players
    for player, espData in pairs(self.espObjects) do
        if not player or not player:IsDescendantOf(Players) then
            self:removeESP(player)
            continue
        end
        
        local character = player.Character
        if not character or not espData.character or character ~= espData.character then
            if character and self.enabled then
                self:setupCharacterESP(player, character)
            end
            continue
        end
        
        -- Check if character is alive
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart or humanoid.Health <= 0 then continue end
        
        -- Check distance
        local distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance > self.maxDistance then
            self:setESPVisibility(espData, false)
            continue
        end
        
        -- Team check
        if self.teamCheck and LocalPlayer.Team == player.Team and LocalPlayer.Team ~= nil then
            if not self.showTeam then
                self:setESPVisibility(espData, false)
                continue
            else
                -- Update color for team members
                self:updateESPColor(espData, self.colors.friendly)
            end
        else
            self:updateESPColor(espData, self:getPlayerColor(player))
        end
        
        -- Show ESP
        self:setESPVisibility(espData, true)
        
        -- Update text information
        if espData.billboard then
            local textLabel = espData.billboard:FindFirstChild("ESPText")
            if textLabel then
                local text = ""
                
                -- Name
                if self.showNames then
                    text = text .. player.Name .. "\n"
                end
                
                -- Distance
                if self.showDistance then
                    text = text .. math.floor(distance) .. " studs\n"
                end
                
                -- Health
                if self.showHealth and humanoid then
                    local healthPercentage = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    text = text .. "HP: " .. healthPercentage .. "%"
                end
                
                textLabel.Text = text
            end
        end
    end
end

-- Set ESP visibility
function ESPModule:setESPVisibility(espData, visible)
    if espData.highlight then
        espData.highlight.Enabled = visible
    end
    
    if espData.billboard then
        espData.billboard.Enabled = visible
    end
end

-- Update ESP color
function ESPModule:updateESPColor(espData, color)
    if espData.highlight then
        espData.highlight.FillColor = color
    end
    
    if espData.billboard then
        local textLabel = espData.billboard:FindFirstChild("ESPText")
        if textLabel then
            textLabel.TextColor3 = color
        end
    end
end

-- Get color for player based on team
function ESPModule:getPlayerColor(player)
    if LocalPlayer.Team and player.Team then
        if LocalPlayer.Team == player.Team then
            return self.colors.friendly
        else
            return self.colors.enemy
        end
    end
    
    return self.colors.neutral
end

-- Remove ESP for a player
function ESPModule:removeESP(player)
    local espData = self.espObjects[player]
    if not espData then return end
    
    -- Clean up ESP objects
    if espData.highlight and espData.highlight.Parent then
        espData.highlight:Destroy()
    end
    
    if espData.billboard and espData.billboard.Parent then
        espData.billboard:Destroy()
    end
    
    -- Remove from table
    self.espObjects[player] = nil
end

-- Stop ESP
function ESPModule:stopESP()
    -- Disconnect render connection
    if self.renderConnection then
        self.renderConnection:Disconnect()
        self.renderConnection = nil
    end
    
    -- Remove all ESP objects
    for player, _ in pairs(self.espObjects) do
        self:removeESP(player)
    end
    
    -- Clear table
    self.espObjects = {}
end

-- Clean up when module is unloaded
function ESPModule:cleanup()
    self:stopESP()
    
    if self.playerAddedConnection then
        self.playerAddedConnection:Disconnect()
        self.playerAddedConnection = nil
    end
    
    if self.playerRemovingConnection then
        self.playerRemovingConnection:Disconnect()
        self.playerRemovingConnection = nil
    end
end

-- Get module settings
function ESPModule:getSettings()
    return {
        showNames = self.showNames,
        showBoxes = self.showBoxes,
        showDistance = self.showDistance,
        showHealth = self.showHealth,
        showTeam = self.showTeam,
        teamCheck = self.teamCheck,
        maxDistance = self.maxDistance
    }
end

-- Apply saved settings
function ESPModule:applySettings(settings)
    for key, value in pairs(settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    -- Refresh ESP if it's enabled
    if self.enabled then
        self:stopESP()
        self:startESP()
    end
end

return ESPModule