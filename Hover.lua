local button = script.Parent
local scale = button:WaitForChild("UIScale")
local TweenService = game:GetService("TweenService")

-- posição inicial do botão
local originalPos = button.Position

button.MouseEnter:Connect(function()
	-- aumenta o tamanho e sobe um pouco
	TweenService:Create(
		button,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = originalPos - UDim2.new(0, 0, 0, 3)} -- sobe 3 pixels
	):Play()
end)

button.MouseLeave:Connect(function()
	-- volta ao normal
	TweenService:Create(
		scale,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Scale = 1}
	):Play()

	TweenService:Create(
		button,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = originalPos}
	):Play()
end)
