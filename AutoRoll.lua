-- LocalScript dentro do botão AutoRoll

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local cartasFolder = ReplicatedStorage:WaitForChild("Cartas")
local rollModule = require(cartasFolder:WaitForChild("RollModule"))
local isDouble = cartasFolder:WaitForChild("IsDoubleRollActive")
local contador = cartasFolder:WaitForChild("ContadorValue")
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local autoRollButton = script.Parent
local COOLDOWN_TIME = 1.2
local autoRolling = false

-- Cores do botão
local defaultBackgroundColor = Color3.fromRGB(0, 84, 84)
local activeBackgroundColor = Color3.fromRGB(0, 150, 255)

local function updateButtonVisual()
	autoRollButton.BackgroundColor3 = autoRolling and activeBackgroundColor or defaultBackgroundColor
end

-- Função fade-out (igual ao RollButton)
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
	if not back or not front then return end

	local originalSize = card.Size
	back.Visible = true
	front.Visible = false
	card.Position = UDim2.fromScale(0.5, 1.0)

	local moveUpTween = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.17) })
	moveUpTween:Play()

	moveUpTween.Completed:Connect(function()
		local flipTween1 = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0,0,originalSize.Y.Scale,0) })
		flipTween1:Play()
		flipTween1.Completed:Connect(function()
			back.Visible = false
			front.Visible = true
			local flipTween2 = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = originalSize })
			flipTween2:Play()
			flipTween2.Completed:Connect(function()
				fadeOutCard(card,0.5)
			end)
		end)
	end)
end

-- Função animação de 2 cartas
local function animateTwoCards(card1, card2)
	local function animateSingleCard(card, finalPosition)
		local back = card:FindFirstChild("Back")
		local front = card:FindFirstChild("Front")
		if not back or not front then return end

		local originalSize = card.Size
		back.Visible = true
		front.Visible = false
		card.Position = UDim2.fromScale(0.5, 1.0)

		local moveUpTween = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = finalPosition })
		moveUpTween:Play()
		moveUpTween.Completed:Connect(function()
			local flipTween1 = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0,0,originalSize.Y.Scale,0) })
			flipTween1:Play()
			flipTween1.Completed:Connect(function()
				back.Visible = false
				front.Visible = true
				local flipTween2 = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = originalSize })
				flipTween2:Play()
				flipTween2.Completed:Connect(function()
					task.delay(0.5, function()
						fadeOutCard(card,0.5)
					end)
				end)
			end)
		end)
	end

	animateSingleCard(card1, UDim2.fromScale(0.35, 0.17))
	animateSingleCard(card2, UDim2.fromScale(0.65, 0.17))
end

-- Função de autoroll
local function performRoll()
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

	if #rolledCards == 1 then
		animateCard(rolledCards[1])
	elseif #rolledCards == 2 then
		animateTwoCards(rolledCards[1], rolledCards[2])
	end
end

-- Loop de AutoRoll
local function startAutoRoll()
	if autoRolling then return end
	autoRolling = true
	updateButtonVisual()
	spawn(function()
		while autoRolling do
			performRoll()
			wait(COOLDOWN_TIME)
		end
	end)
end

local function stopAutoRoll()
	autoRolling = false
	updateButtonVisual()
end

-- Clique no botão
autoRollButton.MouseButton1Click:Connect(function()
	if autoRolling then
		stopAutoRoll()
	else
		startAutoRoll()
	end
end)
