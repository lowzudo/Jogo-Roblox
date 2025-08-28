local Lighting = game:GetService("Lighting")


-- Ajusta brilho para não ficar escuro
Lighting.Brightness = 5
Lighting.OutdoorAmbient = Color3.fromRGB(80, 0, 80)

-- Cria o Sky básico (sem texturas, apenas cor de fundo)
local sky = Instance.new("Sky")
sky.Name = "FuturisticSky"
sky.SkyboxBk = "" -- vazio deixa preto
sky.SkyboxDn = ""
sky.SkyboxFt = ""
sky.SkyboxLf = ""
sky.SkyboxRt = ""
sky.SkyboxUp = ""
sky.Parent = Lighting

-- Atmosfera roxa suave
local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.25 -- não escurece demais
atmosphere.Offset = 0
atmosphere.Color = Color3.fromRGB(120, 0, 150) -- roxo futurista
atmosphere.Glare = 0 -- sem brilho exagerado
atmosphere.Haze = 0.15 -- leve névoa futurista
atmosphere.Parent = Lighting

-- Iluminação geral do mapa
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(150, 80, 200) -- tom roxo escuro
Lighting.Ambient = Color3.fromRGB(100, 50, 150) -- luz ambiente suave
Lighting.FogEnd = 1000
Lighting.FogColor = Color3.fromRGB(60, 0, 100)

-- Define horário futurista (por exemplo, noite cedo)
Lighting.ClockTime = 14