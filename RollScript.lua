-- LocalScript no botão RollButton

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local screenGui = gui:WaitForChild("ScreenGui")

local cartasFolder = ReplicatedStorage:WaitForChild("Cartas")
local rollModule = require(cartasFolder:WaitForChild("RollModule"))

local contador = cartasFolder:WaitForChild("ContadorValue")
local isDouble = cartasFolder:WaitForChild("IsDoubleRollActive")
local counterTemplate = cartasFolder:WaitForChild("CounterLabel")

-- Cria contador visual
local counterLabel = counterTemplate:Clone()
counterLabel.Parent = screenGui

-- Config cores
local TIERS = {10, 100, 1000, 10000}
local COLORS = {
	Color3.fromRGB(100, 180, 255),
	Color3.fromRGB(180, 100, 255),
	Color3.fromRGB(255, 200, 50),
	Color3.fromRGB(255, 0, 0),
}

-- Atualiza GUI com contador e tier corretos
local function applyVisual()
	local currentTier = rollModule.GetTier()
	local text = tostring(contador.Value) .. " / " .. tostring(TIERS[currentTier])
	counterLabel.Text = text
	counterLabel.TextColor3 = COLORS[currentTier]
end

contador.Changed:Connect(applyVisual)
applyVisual()

-- Função fade-out
local function fadeOutCard(card, duration)
	local back = card:FindFirstChild("Back")
	local front = card:FindFirstChild("Front")
	if not back or not front then return end

	local frontTexts = {}
	for _, obj in ipairs(front:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			table.insert(frontTexts, obj)
		end
	end

	local steps = 20
	local stepTime = duration / steps
	for i = 1, steps do
		local alpha = i / steps
		back.ImageTransparency = alpha
		front.ImageTransparency = alpha
		for _, txt in ipairs(frontTexts) do
			txt.TextTransparency = alpha
		end
		wait(stepTime)
	end
	card:Destroy()
end

-- Função animação de 1 carta
local function animateCard(card)
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

	local moveUpInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local upGoal = { Position = UDim2.fromScale(0.5, 0.17) }
	local moveUpTween = TweenService:Create(card, moveUpInfo, upGoal)
	moveUpTween:Play()

	moveUpTween.Completed:Connect(function()
		local flipInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local shrinkGoal = { Size = UDim2.new(0, 0, originalSize.Y.Scale, 0) }
		local shrinkTween = TweenService:Create(card, flipInfo, shrinkGoal)
		shrinkTween:Play()

		shrinkTween.Completed:Connect(function()
			back.Visible = false
			front.Visible = true

			local expandTween = TweenService:Create(card, flipInfo, { Size = originalSize })
			expandTween:Play()
			expandTween.Completed:Connect(function()
				-- remove a carta após 1 segundo
				fadeOutCard(card,0.5)
				script.Parent.Active = true
			end)
		end)
	end)
end

-- Função animação de 2 cartas
local function animateTwoCards(card1, card2)

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

		local moveUpInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local upGoal = { Position = finalPosition }
		local moveUpTween = TweenService:Create(card, moveUpInfo, upGoal)
		moveUpTween:Play()

		moveUpTween.Completed:Connect(function()
			local flipInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local shrinkGoal = { Size = UDim2.new(0, 0, originalSize.Y.Scale, 0) }
			local shrinkTween = TweenService:Create(card, flipInfo, shrinkGoal)
			shrinkTween:Play()

			shrinkTween.Completed:Connect(function()
				back.Visible = false
				front.Visible = true
				local expandTween = TweenService:Create(card, flipInfo, { Size = originalSize })
				expandTween:Play()

				expandTween.Completed:Connect(function()
					-- Fade-out suave após 1s
					task.delay(0.5, function()
						fadeOutCard(card, 0.5) -- 0.5s de fade
					end)
				end)
			end)
		end)
	end

	-- Agora lado a lado
	animateSingleCard(card1, UDim2.fromScale(0.35, 0.17))
	animateSingleCard(card2, UDim2.fromScale(0.65, 0.17))

	wait(1.5)
	script.Parent.Active = true
end

local canClick = true
local COOLDOWN_TIME = 1.5

script.Parent.MouseButton1Click:Connect(function()
	if not canClick then return end
	canClick = false
	script.Parent.Active = false

	local rollsToDo = isDouble.Value and 2 or 1
	local rolledCards = {}

	for i = 1, rollsToDo do
		local cardName = rollModule.DarRoll()
		local cardTemplate = cartasFolder:FindFirstChild(cardName)
		if cardTemplate then
			local clonedCard = cardTemplate:Clone()
			clonedCard.Parent = screenGui
			table.insert(rolledCards, clonedCard)
		end
	end

	-- Animação
	if #rolledCards == 1 then
		animateCard(rolledCards[1])
	elseif #rolledCards == 2 then
		animateTwoCards(rolledCards[1], rolledCards[2])
	end

	task.delay(COOLDOWN_TIME, function()
		canClick = true
	end)
end)
