print("Iniciando...")

-- Criação da GUI
local gui = {}
local funcs = {}
local isFlying = false
local noclipActive = false
local guiVisible = true -- Para controlar a visibilidade da GUI

function gui:Setup(funcs)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "ScriptGui"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 400, 0, 600)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -300)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Name = "MainFrame"

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Menu de Hacks Aprimorado"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Name = "Title"

    local UIListLayout = Instance.new("UIListLayout", Frame)
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateToggleButton(name, stateCallback)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(1, -40, 0, 40)
        btn.Text = name .. " (Desativado)"
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 18

        local isActive = false
        btn.MouseButton1Click:Connect(function()
            isActive = not isActive
            btn.Text = name .. (isActive and " (Ativado)" or " (Desativado)")
            btn.BackgroundColor3 = isActive and Color3.fromRGB(0, 128, 0) or Color3.fromRGB(45, 45, 45)
            stateCallback(isActive)
        end)
    end

    -- Criar botões de ativar/desativar
    CreateToggleButton("Ativar Voo", funcs.Fly)
    CreateToggleButton("Ativar NoClip", funcs.NoClip)
    CreateToggleButton("Toggle ESP (Com Nome)", funcs.ToggleESP)
    CreateToggleButton("God Mode", funcs.GodMode)

    local RemoveGuiButton = Instance.new("TextButton", Frame)
    RemoveGuiButton.Size = UDim2.new(1, -40, 0, 40)
    RemoveGuiButton.Text = "Remover GUI"
    RemoveGuiButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    RemoveGuiButton.TextColor3 = Color3.new(1, 1, 1)
    RemoveGuiButton.Font = Enum.Font.SourceSansBold
    RemoveGuiButton.TextSize = 18
    RemoveGuiButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Evento para minimizar/restaurar a GUI
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
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        isFlying = true

        game:GetService("RunService").RenderStepped:Connect(function()
            if isFlying then
                local moveVector = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + workspace.CurrentCamera.CFrame.RightVector
                end
                bv.Velocity = moveVector * 50
            else
                bv.Velocity = Vector3.zero
                bv:Destroy()
            end
        end)
    else
        isFlying = false
    end
end

function funcs.NoClip(state)
    noclipActive = state
    if noclipActive then
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
                textLabel.Font = Enum.Font.SourceSansBold
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
    if state then
        local humanoid = Character():FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

-- Inicialização
gui:Setup(funcs)
print("Injetado Com Sucesso")
