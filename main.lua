print("Iniciando...")

-- Criação da GUI
local gui = {}
local funcs = {}

function gui:Setup(funcs)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 250, 0, 320)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -160)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Active = true
    Frame.Draggable = true

    local UIListLayout = Instance.new("UIListLayout", Frame)
    UIListLayout.Padding = UDim.new(0, 5)

    local function CreateButton(name, callback)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.MouseButton1Click:Connect(callback)
    end

    CreateButton("Ativar Voo", funcs.Fly)
    CreateButton("Ativar NoClip", funcs.NoClip)
    CreateButton("Super Pulo", funcs.SuperJump)
    CreateButton("Speed Hack", funcs.Speed)
    CreateButton("Teleportar para Cima", funcs.TeleportUp)
    CreateButton("Resetar Personagem", funcs.ResetCharacter)
    CreateButton("Toggle ESP", funcs.ToggleESP)
end

-- Funções principais
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

-- Inicialização
gui:Setup(funcs)
print("Injetado Com Sucesso")
