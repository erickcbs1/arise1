-- Gui de Hacks Aprimorado (Estilo Moderno)
print("Iniciando...")

local gui = {}
local funcs = {}
local isFlying = false
local noclipActive = false
local flyConnection = nil
local noclipConnection = nil
local guiVisible = true

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
    Frame.ClipsDescendants = true

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Painel de Hacks"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Name = "Title"

    local UIListLayout = Instance.new("UIListLayout", Frame)
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function CreateToggleButton(name, stateCallback)
        local holder = Instance.new("Frame", Frame)
        holder.Size = UDim2.new(1, -20, 0, 40)
        holder.BackgroundTransparency = 1

        local btn = Instance.new("TextButton", holder)
        btn.Size = UDim2.new(0.8, 0, 1, 0)
        btn.Position = UDim2.new(0, 0, 0, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 18
        btn.Name = "ToggleButton"

        local status = Instance.new("TextLabel", holder)
        status.Size = UDim2.new(0.2, 0, 1, 0)
        status.Position = UDim2.new(0.8, 0, 0, 0)
        status.Text = "OFF"
        status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        status.TextColor3 = Color3.new(1, 1, 1)
        status.Font = Enum.Font.SourceSansBold
        status.TextSize = 18
        status.Name = "StatusLabel"

        local isActive = false
        btn.MouseButton1Click:Connect(function()
            isActive = not isActive
            status.Text = isActive and "ON" or "OFF"
            status.BackgroundColor3 = isActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
            stateCallback(isActive)
        end)
    end

    CreateToggleButton("Ativar Voo", funcs.Fly)
    CreateToggleButton("Ativar NoClip", funcs.NoClip)
    CreateToggleButton("Toggle ESP", funcs.ToggleESP)
    CreateToggleButton("God Mode", funcs.GodMode)

    local RemoveGuiButton = Instance.new("TextButton", Frame)
    RemoveGuiButton.Size = UDim2.new(1, -20, 0, 40)
    RemoveGuiButton.Text = "Encerrar Script"
    RemoveGuiButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    RemoveGuiButton.TextColor3 = Color3.new(1, 1, 1)
    RemoveGuiButton.Font = Enum.Font.SourceSansBold
    RemoveGuiButton.TextSize = 18
    RemoveGuiButton.MouseButton1Click:Connect(function()
        isFlying = false
        noclipActive = false
        if flyConnection then flyConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") or obj:IsA("BillboardGui") then
                obj:Destroy()
            end
        end
        ScreenGui:Destroy()
    end)

    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
            guiVisible = not guiVisible
            Frame.Visible = guiVisible
        end
    end)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function Character()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function funcs.Fly(state)
    if flyConnection then flyConnection:Disconnect() end
    isFlying = state
    if state then
        local torso = Character():WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = torso

        flyConnection = RunService.RenderStepped:Connect(function()
            if isFlying then
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + workspace.CurrentCamera.CFrame.RightVector end
                bv.Velocity = move.Unit * 60
            else
                bv:Destroy()
            end
        end)
    end
end

function funcs.NoClip(state)
    noclipActive = state
    if noclipConnection then noclipConnection:Disconnect() end
    if noclipActive then
        noclipConnection = RunService.Stepped:Connect(function()
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
print("Injetado com sucesso")
