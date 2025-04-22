
-- Arquivo principal que carrega a interface e scripts
print("Iniciando...")
local HttpService = game:GetService("HttpService")

local funcsCode = HttpService:GetAsync("https://raw.githubusercontent.com/erickcbs1/arise/main/src/scripts/funcs.lua") 
local guiCode = HttpService:GetAsync("https://raw.githubusercontent.com/erickcbs1/arise/main/src/ui/gui.lua")

local funcs = loadstring(funcsCode)()
local gui = loadstring(guiCode)()

gui:Setup(funcs)
print("Injetado Com Sucesso")
