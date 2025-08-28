-- LocalScript dentro do seu botão de roll (RollButton)

-- Serviços
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player e GUI
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local screenGui = gui:WaitForChild("ScreenGui")

-- Pasta das cartas
local cartasFolder = ReplicatedStorage:WaitForChild("Cartas")
print("[DEBUG] CartasFolder encontrado:", cartasFolder)

-- Carregar módulo Roll
local rollModule
local success, err = pcall(function()
	rollModule = require(cartasFolder:WaitForChild("RollModule"))
end)
if not success then
	warn("[DEBUG] ERRO ao carregar RollModule:", err)
else
	print("[DEBUG] RollModule carregado com sucesso:", rollModule)
end

-- Valores de estado
local contador = cartasFolder:WaitForChild("ContadorValue")
local isDouble = cartasFolder:WaitForChild("IsDoubleRollActive")
local counterTemplate = cartasFolder:WaitForChild("CounterLabel")
print("[DEBUG] Valores encontrados - Contador:", contador.Value, "IsDouble:", isDouble.Value)

-- Cria contador visual
local counterLabel = counterTemplate:Clone()
counterLabel.Parent = screenGui
print("[DEBUG] CounterLabel clonado e adicionado ao ScreenGui")

-- Config visuais
local TIERS = {100, 1000, 10000, 100000}
local COLORS = {
	Color3.fromRGB(100, 180, 255),
	Color3.fromRGB(180, 100, 255),
	Color3.fromRGB(255, 200, 50),
	Color3.fromRGB(255, 0, 0),
}
local tier = 1
local function applyVisual()
	local text = tostring(contador.Value) .. " / " .. tostring(TIERS[tier])
	counterLabel.Text = text
	counterLabel.TextColor3 = COLORS[tier]
	print("[DEBUG] Counter atualizado:", text, "Cor Tier:", tier)
end
contador.Changed:Connect(applyVisual)
applyVisual()

-- Função animação de 1 carta
local function animateCard(card)
	print("[DEBUG] Iniciando animação de 1 carta:", card.Name)
	local back = card:FindFirstChild("Back")
	local front = card:FindFirstChild("Front")

	if not back or not front then
		warn("[DEBUG] ERRO: Carta não tem Back/Front ->", card.Name)
		return
	end

	local originalSize = card.Size
	back.Visible = true
	front.Visible = false
	card.Position = UDim2.fromScale(0.5, 1.0)

	local moveUpInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local upGoal = { Position = UDim2.fromScale(0.5, 0.17) }
	local moveUpTween = TweenService:Create(card, moveUpInfo, upGoal)
	moveUpTween:Play()
	print("[DEBUG] Tween de subida iniciado")

	moveUpTween.Completed:Connect(function()
		print("[DEBUG] Tween de subida finalizado -> iniciando flip")
		local flipInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local shrinkGoal = { Size = UDim2.new(0, 0, originalSize.Y.Scale, 0) }
		local shrinkTween = TweenService:Create(card, flipInfo, shrinkGoal)
		shrinkTween:Play()

		shrinkTween.Completed:Connect(function()
			print("[DEBUG] Flip metade concluído, trocando para frente")
			back.Visible = false
			front.Visible = true

			local expandTween = TweenService:Create(card, flipInfo, { Size = originalSize })
			expandTween:Play()
			expandTween.Completed:Connect(function()
				print("[DEBUG] Animação concluída para carta:", card.Name)
				script.Parent.Active = true
			end)
		end)
	end)
end

-- Função animação de 2 cartas
local function animateTwoCards(card1, card2)
	print("[DEBUG] Iniciando animação de 2 cartas:", card1.Name, card2.Name)

	local function animateSingleCard(card, finalPosition)
		local back = card:FindFirstChild("Back")
		local front = card:FindFirstChild("Front")

		if not back or not front then
			warn("[DEBUG] ERRO: Carta não tem Back/Front ->", card.Name)
			return
		end

		local originalSize = card.Size
		back.Visible = true
		front.Visible = false
		card.Position = UDim2.fromScale(0.5, 1.0)

		local moveUpInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local upGoal = { Position = finalPosition }
		local moveUpTween = TweenService:Create(card, moveUpInfo, upGoal)
		moveUpTween:Play()

		moveUpTween.Completed:Connect(function()
			local flipInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local shrinkGoal = { Size = UDim2.new(0, 0, originalSize.Y.Scale, 0) }
			local shrinkTween = TweenService:Create(card, flipInfo, shrinkGoal)
			shrinkTween:Play()

			shrinkTween.Completed:Connect(function()
				back.Visible = false
				front.Visible = true
				local expandTween = TweenService:Create(card, flipInfo, { Size = originalSize })
				expandTween:Play()
			end)
		end)
	end

	-- Agora lado a lado
	animateSingleCard(card1, UDim2.fromScale(0.35, 0.17))
	animateSingleCard(card2, UDim2.fromScale(0.65, 0.17))

	wait(1.5)
	script.Parent.Active = true
	print("[DEBUG] Animação de 2 cartas concluída")
end

-- Clique do botão
script.Parent.MouseButton1Click:Connect(function()
	print("[DEBUG] Botão clicado")
	script.Parent.Active = false

	if rollModule and rollModule.DarRoll then
		print("[DEBUG] Chamando DarRoll()...")
		if isDouble.Value then
			local cardName1 = rollModule.DarRoll()
			local cardName2 = rollModule.DarRoll()
			print("[DEBUG] Resultados 2x:", cardName1, cardName2)

			local cardTemplate1 = cartasFolder:FindFirstChild(cardName1)
			local cardTemplate2 = cartasFolder:FindFirstChild(cardName2)

			if cardTemplate1 and cardTemplate2 then
				print("[DEBUG] Cartas encontradas para 2x, clonando...")
				local clonedCard1 = cardTemplate1:Clone()
				local clonedCard2 = cardTemplate2:Clone()
				clonedCard1.Parent = screenGui
				clonedCard2.Parent = screenGui
				animateTwoCards(clonedCard1, clonedCard2)
			else
				warn("[DEBUG] Uma ou ambas as cartas do 2x não foram encontradas!")
				script.Parent.Active = true
			end
		else
			local cardName = rollModule.DarRoll()
			print("[DEBUG] Resultado 1x:", cardName)

			local cardTemplate = cartasFolder:FindFirstChild(cardName)
			if cardTemplate then
				print("[DEBUG] Carta encontrada:", cardName, "-> clonando")
				local clonedCard = cardTemplate:Clone()
				clonedCard.Parent = screenGui
				animateCard(clonedCard)
			else
				warn("[DEBUG] Carta", cardName, "não encontrada em Cartas!")
				script.Parent.Active = true
			end
		end
	else
		warn("[DEBUG] RollModule não encontrado ou DarRoll ausente!")
		script.Parent.Active = true
	end
end)
