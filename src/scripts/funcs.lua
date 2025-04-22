local funcs = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = function() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end

function funcs.Fly()
    local torso = Character():WaitForChild("HumanoidRootPart")
    local flying = true
    local bv = Instance.new("BodyVelocity", torso)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    game:GetService("RunService").RenderStepped:Connect(function()
        if flying then
            bv.Velocity = LocalPlayer:GetMouse().Hit.lookVector * 50
        end
    end)
end

function funcs.NoClip()
    game:GetService("RunService").Stepped:Connect(function()
        for _, v in pairs(Character():GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end

function funcs.SuperJump()
    Character():FindFirstChildOfClass("Humanoid").JumpPower = 150
end

function funcs.Speed()
    Character():FindFirstChildOfClass("Humanoid").WalkSpeed = 100
end

function funcs.TeleportUp()
    Character():MoveTo(Character().HumanoidRootPart.Position + Vector3.new(0, 50, 0))
end

function funcs.ResetCharacter()
    Character():BreakJoints()
end

function funcs.ToggleESP()
    if _G.ESPEnabled then
        _G.ESPEnabled = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then
                obj:Destroy()
            end
        end
    else
        _G.ESPEnabled = true
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.Parent = player.Character
            end
        end
    end
end

return funcs
