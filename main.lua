
-- Arquivo principal que carrega a interface e scripts
print("Iniciando...")
local funcs = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/arise/main/src/scripts/funcs.lua"))()
local gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/arise/main/src/ui/gui.lua"))()
gui:Setup(funcs)
print("Injetado Com Sucesso")
