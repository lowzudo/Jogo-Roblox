local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local screenGui = gui:WaitForChild("ScreenGui")
local inventoryFrame = screenGui:WaitForChild("InventoryFrame")
local button = script.Parent
local closeButton = inventoryFrame:WaitForChild("CloseButton")

-- Cria um blocker invisível (se não existir ainda)
local blocker = screenGui:FindFirstChild("ScreenBlocker")
if not blocker then
	blocker = Instance.new("Frame")
	blocker.Name = "ScreenBlocker"
	blocker.Size = UDim2.fromScale(1, 1)
	blocker.Position = UDim2.fromScale(0, 0)
	blocker.BackgroundTransparency = 1
	blocker.Active = true -- captura cliques
	blocker.Visible = false
	blocker.ZIndex = inventoryFrame.ZIndex - 1
	blocker.Parent = screenGui
end

-- Coloca o inventário dentro do blocker
inventoryFrame.Parent = blocker

-- Configuração inicial
inventoryFrame.Visible = false
inventoryFrame.Position = UDim2.new(0.5, 0, -0.5, 0) -- começa fora da tela (acima)
inventoryFrame.AnchorPoint = Vector2.new(0.5, 0.5)
inventoryFrame.BackgroundTransparency = 1 -- invisível

-- Função para abrir inventário
local function openInventory()
	blocker.Visible = true
	inventoryFrame.Visible = true

	-- Tween de posição
	local posTween = TweenService:Create(
		inventoryFrame,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, 0, 0.5, 0)}
	)
	posTween:Play()

	-- Tween de transparência (fade-in)
	local fadeTween = TweenService:Create(
		inventoryFrame,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)
	fadeTween:Play()
end

-- Função para fechar inventário
local function closeInventory()
	-- Tween de posição (sobe pra fora da tela)
	local posTween = TweenService:Create(
		inventoryFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, 0, -0.5, 0)}
	)
	posTween:Play()

	-- Tween de transparência (fade-out)
	local fadeTween = TweenService:Create(
		inventoryFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	fadeTween:Play()

	-- Depois que o tween acabar, esconde completamente
	fadeTween.Completed:Connect(function()
		inventoryFrame.Visible = false
		blocker.Visible = false
	end)
end

button.MouseButton1Click:Connect(openInventory)
closeButton.MouseButton1Click:Connect(closeInventory)
