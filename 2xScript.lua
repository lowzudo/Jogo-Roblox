-- LocalScript dentro do seu 2xRollButton

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cartasFolder = ReplicatedStorage:WaitForChild("Cartas")
local isDoubleRollActive = cartasFolder:WaitForChild("IsDoubleRollActive")

local button = script.Parent

-- Referências para a cor de fundo e para o ícone de status
local defaultBackgroundColor = Color3.fromRGB(0, 84, 84)
local activeBackgroundColor = Color3.fromRGB(0, 150, 255)

local statusIndicator = button:WaitForChild("CorrectlyButton")

-- Função para atualizar o estado visual do botão
local function updateButtonStatus()
	if isDoubleRollActive.Value then
		-- Modo 2x ativado
		button.BackgroundColor3 = activeBackgroundColor
		-- Se você quiser mudar a cor da imagem do botão também, adicione aqui
			button.ImageColor3 = Color3.fromRGB(255, 255, 255) 
		statusIndicator.Visible = true
	else
		-- Modo 2x desativado
		button.BackgroundColor3 = defaultBackgroundColor
		-- Se você quiser mudar a cor da imagem do botão também, adicione aqui
			button.ImageColor3 = defaultBackgroundColor
		statusIndicator.Visible = false
	end
end

-- Conecta a função ao evento Changed, para que o botão atualize seu status sempre que o valor for alterado.
isDoubleRollActive.Changed:Connect(updateButtonStatus)

-- Chama a função uma vez para definir o estado inicial do botão
updateButtonStatus()

-- Evento de clique do botão
button.MouseButton1Click:Connect(function()
	-- Apenas muda o valor. O evento .Changed cuidará do visual.
	isDoubleRollActive.Value = not isDoubleRollActive.Value
	print("Modo 2x ativado/desativado.")
end)