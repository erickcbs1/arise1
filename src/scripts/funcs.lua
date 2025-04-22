local plr = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local mouse = plr:GetMouse()

local flying = false
local turbo = false
local velocidade = 100
local humanoide, hrp

local noclip = false
local guiVisivel = true

local frame = game.CoreGui:WaitForChild("PainelDebug"):WaitForChild("FramePrincipal")

local function criarBotao(texto, ordem, func)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 15, 0, 35 + (ordem * 35))
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Text = texto
    btn.MouseButton1Click:Connect(func)
end

criarBotao("Voo (Shift = Turbo)", 0, function()
    flying = not flying
    humanoide = plr.Character:FindFirstChildWhichIsA("Humanoid")
    hrp = plr.Character:WaitForChild("HumanoidRootPart")
end)

criarBotao("NoClip", 1, function()
    noclip = not noclip
end)

criarBotao("Super Pulo", 2, function()
    local h = plr.Character:FindFirstChildWhichIsA("Humanoid")
    if h then h.JumpPower = 200 end
end)

criarBotao("Speed Hack", 3, function()
    local h = plr.Character:FindFirstChildWhichIsA("Humanoid")
    if h then h.WalkSpeed = 100 end
end)

criarBotao("🪂 Teleportar pra Cima", 4, function()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0) end
end)

criarBotao("Resetar", 5, function()
    plr:LoadCharacter()
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        turbo = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        guiVisivel = not guiVisivel
        game.CoreGui.PainelDebug.Enabled = guiVisivel
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        turbo = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if flying and hrp then
        local dir = Vector3.zero
        local cam = workspace.CurrentCamera
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) and not guiVisivel then dir -= Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            local speed = turbo and 300 or velocidade
            hrp.Velocity = dir.Unit * speed
        else
            hrp.Velocity = Vector3.zero
        end
    end

    if noclip and plr.Character then
        for _, part in pairs(plr.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
