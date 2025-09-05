local TweenService = game:GetService("TweenService")
local label = script.Parent

-- Requisitos pra o degradê pegar no texto:
label.BackgroundTransparency = 1           -- fundo transparente
label.TextColor3 = Color3.new(1, 1, 1)     -- texto branco (o gradiente "tinta" por cima do branco)

-- Garante que exista um UIGradient
local gradient = label:FindFirstChildOfClass("UIGradient")
if not gradient then
	gradient = Instance.new("UIGradient")
	gradient.Parent = label
end

-- Cores do degradê (primeira = última pra loop ficar suave)
-- Pode trocar pelas cores do seu tema
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 128, 255)),  -- azul forte
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)), -- branco no meio
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 128, 255)) 
})

-- Posição inicial fora da esquerda
gradient.Offset = Vector2.new(-1, 0)
gradient.Rotation = 0

-- Loop infinito: vai até a direita e teleporta pro começo
local tweenInfo = TweenInfo.new(2.0, Enum.EasingStyle.Linear)

while true do
	local t = TweenService:Create(gradient, tweenInfo, { Offset = Vector2.new(1, 0) })
	t:Play()
	t.Completed:Wait()
	gradient.Offset = Vector2.new(-1, 0) -- volta instantâneo pro início
end
