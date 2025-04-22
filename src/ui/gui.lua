local gui = {}

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

return gui
