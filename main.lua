
-- Arquivo principal que carrega a interface e scripts
print("Iniciando...")
loadstring(readfile("src/ui/gui.lua"))()
loadstring(readfile("src/scripts/funcs.lua"))()
print("Injetado Com Sucesso")