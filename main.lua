-- Melhor versão da GUI com estilo inspirado na imagem enviada
print("Iniciando...")

-- Criação da GUI
local gui = {}
local funcs = {}
local isFlying = false
local noclipActive = false
local guiVisible = true

function gui:Setup(funcs)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "ScriptGui"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 450, 0, 500)
    Frame.Position = UDim2.new(0.5, -225, 0.5, -250)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Name = "MainFrame"
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundTransparency = 0.1

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Painel de Hacks"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Name = "Title"

    local UIListLayout = Instance.new("UIListLayout", Frame)
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Title.LayoutOrder = 0

    local function CreateToggleButton(name, stateCallback)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Text = name .. " (Desativado)"
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 18

        local UIC = Instance.new("UICorner", btn)
        UIC.CornerRadius = UDim.new(0, 8)

        local isActive = false
        btn.MouseButton1Click:Connect(function()
            isActive = not isActive
            btn.Text = name .. (isActive and " (Ativado)" or " (Desativado)")
            btn.BackgroundColor3 = isActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
            stateCallback(isActive)
        end)

        btn.LayoutOrder = #Frame:GetChildren()
    end

    CreateToggleButton("Ativar Voo", funcs.Fly)
    CreateToggleButton("Ativar NoClip", funcs.NoClip)
    CreateToggleButton("Toggle ESP (Com Nome)", funcs.ToggleESP)
    CreateToggleButton("God Mode", funcs.GodMode)

    local RemoveGuiButton = Instance.new("TextButton", Frame)
    RemoveGuiButton.Size = UDim2.new(0.9, 0, 0, 40)
    RemoveGuiButton.Text = "Remover GUI"
    RemoveGuiButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    RemoveGuiButton.TextColor3 = Color3.new(1, 1, 1)
    RemoveGuiButton.Font = Enum.Font.GothamBold
    RemoveGuiButton.TextSize = 18
    Instance.new("UICorner", RemoveGuiButton).CornerRadius = UDim.new(0, 8)

    RemoveGuiButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    RemoveGuiButton.LayoutOrder = #Frame:GetChildren()

    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
            guiVisible = not guiVisible
            Frame.Visible = guiVisible
        end
    end)
end

-- Funções principais
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = function() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local UserInputService = game:GetService("UserInputService")

function funcs.Fly(state)
    if state then
        local torso = Character():WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity", torso)
        bv.Name = "FlyVelocity"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        isFlying = true

        game:GetService("RunService").RenderStepped:Connect(function()
            if isFlying and bv.Parent then
                local moveVector = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector += workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector -= workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector -= workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector += workspace.CurrentCamera.CFrame.RightVector
                end
                bv.Velocity = moveVector.Unit * 75
            end
        end)
    else
        isFlying = false
        local torso = Character():FindFirstChild("HumanoidRootPart")
        if torso then
            local bv = torso:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
        end
    end
end

function funcs.NoClip(state)
    noclipActive = state
    game:GetService("RunService").Stepped:Connect(function()
        if noclipActive then
            for _, v in pairs(Character():GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end

function funcs.ToggleESP(state)
    if state then
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
                textLabel.Font = Enum.Font.GothamBold
            end
        end
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then
                obj:Destroy()
            end
            if obj:IsA("BillboardGui") and obj.Name == "ESPName" then
                obj:Destroy()
            end
        end
    end
end

function funcs.GodMode(state)
    local humanoid = Character():FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = state and math.huge or 100
        humanoid.Health = state and math.huge or 100
    end
end

-- Inicialização
gui:Setup(funcs)
print("Injetado com sucesso")
