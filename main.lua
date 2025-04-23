-- Main Entry Point
local HackFramework = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repository/main/hackframework.lua"))()

-- Initialize hack framework with configuration
local config = {
    title = "Quantum Hacks v1.0",
    theme = "dark", -- "dark" or "light"
    defaultPosition = UDim2.new(0.5, -175, 0.5, -200),
    toggleKey = Enum.KeyCode.RightControl,
    saveSettings = true
}

-- Start the hack framework
HackFramework:Initialize(config)

print("Quantum Hacks initialized successfully")