-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Player
local player = Players.LocalPlayer
local humanoid
local humanoidRootPart

-- Velocidade
local walkSpeed = 16
local runSpeed = 30

-- Dash
local dashDistance = 30
local dashDuration = 0.2
local dashCooldown = 1.5
local canDash = true

-- Double Jump
local canDoubleJump = false
local doubleJumped = false
local doubleJumpPower = 50 -- força do pulo extra
local lastJump = tick()

-- Animações
local walkRunAnimId = "rbxassetid://16817762547" -- animação de walk + run
local walkRunAnim = Instance.new("Animation")
walkRunAnim.AnimationId = walkRunAnimId
local walkRunTrack

-- Função de dash
local function dash()
	if not canDash or not humanoidRootPart then return end
	canDash = false

	-- BodyVelocity para dash
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 0, 1e5)
	bv.Velocity = humanoidRootPart.CFrame.LookVector * dashDistance / dashDuration
	bv.Parent = humanoidRootPart

	task.delay(dashDuration, function()
		bv:Destroy()
	end)

	-- Cooldown
	task.delay(dashCooldown, function()
		canDash = true
	end)
end

-- Double Jump Handler
local function onJumpRequest()
	if not humanoid or not humanoidRootPart then return end

	-- Se já estiver no ar e ainda não usou o double jump
	if not humanoid:GetState().Name == "Freefall" then return end

	if canDoubleJump and not doubleJumped then
		doubleJumped = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		humanoidRootPart.Velocity = Vector3.new(
			humanoidRootPart.Velocity.X,
			doubleJumpPower,
			humanoidRootPart.Velocity.Z
		)
	end
end

-- Reset quando tocar no chão
local function onStateChanged(_, newState)
	if newState == Enum.HumanoidStateType.Freefall then
		canDoubleJump = true
	elseif newState == Enum.HumanoidStateType.Landed then
		canDoubleJump = false
		doubleJumped = false
	end
end

-- Quando o personagem spawnar
local function onCharacterAdded(char)
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed = walkSpeed

	-- Conectar estados
	humanoid.StateChanged:Connect(onStateChanged)

	-- Carrega animação de walk/run
	walkRunTrack = humanoid:LoadAnimation(walkRunAnim)
	walkRunTrack.Priority = Enum.AnimationPriority.Core -- garante prioridade
	walkRunTrack:Play()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

-- Detecta teclas
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not humanoid then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		humanoid.WalkSpeed = runSpeed
	elseif input.KeyCode == Enum.KeyCode.Q then
		dash()
	elseif input.KeyCode == Enum.KeyCode.Space then
		onJumpRequest()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not humanoid then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		humanoid.WalkSpeed = walkSpeed
	end
end)
