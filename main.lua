print("Iniciando...")

-- Criação da GUI
local gui = {}
local funcs = {}

function gui:Setup(funcs)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 350, 0, 500)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.Text = "Menu de Hacks - Aprimorado"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold

    local UIListLayout = Instance.new("UIListLayout", Frame)
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateButton(name, callback)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 18
        btn.MouseButton1Click:Connect(callback)
    end

    CreateButton("Ativar Voo", funcs.Fly)
    CreateButton("Ativar NoClip", funcs.NoClip)
    CreateButton("Super Pulo", funcs.SuperJump)
    CreateButton("Speed Hack", funcs.Speed)
    CreateButton("Teleportar para Cima", funcs.TeleportUp)
    CreateButton("Resetar Personagem", funcs.ResetCharacter)
    CreateButton("Toggle ESP (Com Nome)", funcs.ToggleESP)
    CreateButton("Toggle God Mode", funcs.GodMode)
    CreateButton("Remover GUI", function() ScreenGui:Destroy() end)
end

-- Funções principais
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = function() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

function funcs.Fly()
    local torso = Character():WaitForChild("HumanoidRootPart")
    local flying = false
    local bv = Instance.new("BodyVelocity", torso)
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)

    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            flying = not flying
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if flying then
            bv.Velocity = Vector3.new(0, 50, 0) + LocalPlayer:GetMouse().Hit.lookVector * 50
        else
            bv.Velocity = Vector3.zero
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

    -- Bypass integrado
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if tostring(self) == "Kick" then
            return
        end
        return oldNamecall(self, unpack(args))
    end)
end

function funcs.SuperJump()
    Character():FindFirstChildOfClass("Humanoid").JumpPower = 150

    -- Proteção para evitar detecção
    for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
        v:Disable()
    end
end

function funcs.Speed()
    Character():FindFirstChildOfClass("Humanoid").WalkSpeed = 100

    -- Bypass para impedir detecção
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if tostring(self) == "Kick" then
            return
        end
        return oldNamecall(self, unpack(args))
    end)
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
            if obj:IsA("BillboardGui") and obj.Name == "ESPName" then
                obj:Destroy()
            end
        end
    else
        _G.ESPEnabled = true
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.Parent = player.Character

                local billboard = Instance.new("BillboardGui", player.Character)
                billboard.Name = "ESPName"
                billboard.Size = UDim2.new(0, 150, 0, 50)
                billboard.Adornee = player.Character:WaitForChild("HumanoidRootPart")
                billboard.AlwaysOnTop = true

                local textLabel = Instance.new("TextLabel", billboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = player.Name
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.SourceSansBold
            end
        end
    end
end

function funcs.GodMode()
    local humanoid = Character():FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end

    -- Proteção contra detecção
    for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
        v:Disable()
    end
end

-- Inicialização
gui:Setup(funcs)
print("Injetado Com Sucesso")
