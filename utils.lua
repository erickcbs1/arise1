-- Utility Functions
local Utils = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Check if value is valid
function Utils.isValid(value)
    return value ~= nil and value ~= ""
end

-- Check if an instance exists
function Utils.instanceExists(instance)
    return typeof(instance) == "Instance" and instance ~= nil and instance.Parent ~= nil
end

-- Get character safely
function Utils.getCharacter()
    local character = LocalPlayer.Character
    if not Utils.instanceExists(character) then return nil end
    return character
end

-- Get humanoid safely
function Utils.getHumanoid()
    local character = Utils.getCharacter()
    if not character then return nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not Utils.instanceExists(humanoid) then return nil end
    
    return humanoid
end

-- Get root part safely
function Utils.getRootPart()
    local character = Utils.getCharacter()
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not Utils.instanceExists(rootPart) then return nil end
    
    return rootPart
end

-- Get player from character
function Utils.getPlayerFromCharacter(character)
    if not Utils.instanceExists(character) then return nil end
    return Players:GetPlayerFromCharacter(character)
end

-- Check if a player is an enemy
function Utils.isEnemy(player)
    if player == LocalPlayer then return false end
    if not player or not player:IsA("Player") then return false end
    
    -- If teams are used
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    
    -- Assume all other players are enemies if no team system
    return true
end

-- Calculate distance between two positions
function Utils.getDistance(position1, position2)
    return (position1 - position2).Magnitude
end

-- Get all players in radius
function Utils.getPlayersInRadius(radius, teamCheck)
    local results = {}
    local rootPart = Utils.getRootPart()
    if not rootPart then return results end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Team check
        if teamCheck and not Utils.isEnemy(player) then continue end
        
        local character = player.Character
        if not Utils.instanceExists(character) then continue end
        
        local playerRootPart = character:FindFirstChild("HumanoidRootPart")
        if not Utils.instanceExists(playerRootPart) then continue end
        
        -- Check distance
        local distance = Utils.getDistance(rootPart.Position, playerRootPart.Position)
        if distance <= radius then
            table.insert(results, {
                player = player,
                character = character,
                rootPart = playerRootPart,
                distance = distance
            })
        end
    end
    
    -- Sort by distance
    table.sort(results, function(a, b)
        return a.distance < b.distance
    end)
    
    return results
end

-- Create a protective system
function Utils.protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game.CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game.CoreGui
    end
end

-- Get game place info
function Utils.getGameInfo()
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    
    if success then
        return info
    else
        return {
            Name = "Unknown Game",
            CreatorName = "Unknown Creator",
            PlaceId = game.PlaceId
        }
    end
end

-- Check if exploit supports a feature
function Utils.hasFeature(feature)
    if feature == "httpRequest" then
        return (syn and syn.request) or http_request or request or (http and http.request)
    elseif feature == "getNamecall" then
        return getnamecallmethod ~= nil
    elseif feature == "setReadOnly" then
        return setreadonly ~= nil
    elseif feature == "isClosure" then
        return is_synapse_function or iskrnlclosure or isexecutorclosure
    elseif feature == "getUpvalues" then
        return debug.getupvalues ~= nil
    elseif feature == "saveInstance" then
        return saveinstance ~= nil
    elseif feature == "gethui" then
        return gethui ~= nil
    elseif feature == "identifyexecutor" then
        return identifyexecutor ~= nil
    elseif feature == "firesignal" then
        return firesignal ~= nil
    end
    
    return false
end

-- Get executor name
function Utils.getExecutorName()
    if identifyexecutor then
        local success, result = pcall(identifyexecutor)
        if success then
            return result
        end
    end
    
    return "Unknown Executor"
end

-- Format time
function Utils.formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

-- Lerp between two values
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Smooth lerp (with ease)
function Utils.smoothLerp(a, b, t)
    t = t * t * (3 - 2 * t) -- Smoothstep
    return Utils.lerp(a, b, t)
end

return Utils