-- Localização: ReplicatedStorage.Cartas.RollModule
local M = {}

local cartasFolder = script.Parent
print("[RollModule] Iniciado, Parent:", cartasFolder)

-- Garantir que os valores existem
local contador = cartasFolder:FindFirstChild("ContadorValue")
if not contador then
	contador = Instance.new("IntValue")
	contador.Name = "ContadorValue"
	contador.Value = 0
	contador.Parent = cartasFolder
	print("[RollModule] ContadorValue criado automaticamente")
end

local isDouble = cartasFolder:FindFirstChild("IsDoubleRollActive")
if not isDouble then
	isDouble = Instance.new("BoolValue")
	isDouble.Name = "IsDoubleRollActive"
	isDouble.Value = false
	isDouble.Parent = cartasFolder
	print("[RollModule] IsDoubleRollActive criado automaticamente")
end

print("[RollModule] Contador e IsDoubleRollActive prontos")

-- Tiers
local TIERS = {100, 1000, 10000, 100000}
local tier = 1

-- TABELA DE RARIDADES (chance soma 100)
local RARITY_CHANCES = {
	{Name = "Comum", Chance = 60},
	{Name = "Rara", Chance = 30},
	{Name = "Epica", Chance = 8.2},
	{Name = "Lendaria", Chance = 1.7},
	{Name = "Secreta", Chance = 0.1},
}

-- TABELA DE CARTAS
local RARITY_CARDS = {
	Comum = { "Gojo", "Gojo" },
	Rara = { "CartaA", "CartaB", "CartaC", "CartaD", "CartaE", "CartaF", "CartaG", "CartaH", "CartaI", "CartaJ" },
	Epica = { "CartaK", "CartaL", "CartaM", "CartaN", "CartaO" },
	Lendaria = { "Sukuna" }, -- removi ""
	Secreta = { "CartaSecreta" } -- coloquei 1 placeholder em vez de ""
}

-- Recompensas
local function verificarRecompensa(valor)
	if valor == 100 then
		print("🏆 Recompensa de 100!")
	elseif valor == 1000 then
		print("🏆 Recompensa de 1000!")
	elseif valor == 10000 then
		print("🏆 Recompensa de 10000!")
	elseif valor == 100000 then
		print("🏆 Recompensa de 100000!")
	end
end

-- FUNÇÃO PRINCIPAL
function M.DarRoll()
	print("[RollModule] DarRoll chamado!")

	local step = isDouble.Value and 2 or 1
	contador.Value += step
	print("[RollModule] Contador atualizado:", contador.Value)

	verificarRecompensa(contador.Value)

	if contador.Value >= TIERS[tier] then
		contador.Value = 0
		if tier < #TIERS then
			tier += 1
		else
			tier = #TIERS
		end
		print("[RollModule] Avançou para Tier:", tier)
	end

	-- Sortear raridade
	local totalChances = 0
	for _, rarityData in ipairs(RARITY_CHANCES) do
		totalChances += rarityData.Chance
	end
	local randomNumber = math.random() * totalChances
	local cumulativeChance = 0
	local chosenRarity = nil

	for _, rarityData in ipairs(RARITY_CHANCES) do
		cumulativeChance += rarityData.Chance
		if randomNumber <= cumulativeChance then
			chosenRarity = rarityData.Name
			break
		end
	end

	if not chosenRarity then
		warn("[RollModule] ERRO: Nenhuma raridade escolhida!")
		return "CartaInexistente"
	end

	-- Sortear carta da raridade
	local cardsInRarity = RARITY_CARDS[chosenRarity]
	if not cardsInRarity or #cardsInRarity == 0 then
		warn("[RollModule] ERRO: Nenhuma carta definida para raridade:", chosenRarity)
		return "CartaInexistente"
	end

	local randomCardIndex = math.random(1, #cardsInRarity)
	local cardName = cardsInRarity[randomCardIndex]

	print("[RollModule] Raridade sorteada:", chosenRarity)
	print("[RollModule] Carta sorteada:", cardName)

	return cardName
end

function M.GetState()
	return contador.Value, TIERS[tier], tier
end

print("[RollModule] Finalizou carregamento")
return M
