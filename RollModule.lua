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
local TIERS = {10, 100, 1000, 10000}
local tier = 1

-- TABELA DE RARIDADES
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
	Rara = { "CartaRara" },
	Epica = { "CartaK", "CartaL", "CartaM", "CartaN", "CartaO" },
	Lendaria = { "CartaLendaria" },
	Secreta = { "Sukuna" }
}

-- TABELA DE PITTY POR VALOR DO CONTADOR
local PITTY = {
	[10] = "Rara",
	[100] = "Epica",
	[1000] = "Lendaria",
	[10000] = "Secreta"
}

-- Função para pegar o tier atual
function M.GetTier()
	return tier
end

-- Verifica se ganhou recompensa
local function verificarRecompensa(valor)
	if PITTY[valor] then
		print("[RollModule] Pity ativado! Garantido:", PITTY[valor])
	end
end

-- Função principal de roll
function M.DarRoll()
	print("[RollModule] DarRoll chamado!")

	local step = isDouble.Value and 2 or 1
	contador.Value += 1
	print("[RollModule] Contador atualizado:", contador.Value)

	verificarRecompensa(contador.Value)

	-- Avança o tier se necessário
	while contador.Value >= TIERS[tier] and tier < #TIERS do
		contador.Value = contador.Value - TIERS[tier]
		tier += 1
		print("[RollModule] Avançou para Tier:", tier)
	end

	-- Verifica se algum pity deve ser ativado
	if PITTY[contador.Value] then
		local rarity = PITTY[contador.Value]
		local cardsInRarity = RARITY_CARDS[rarity]
		if cardsInRarity and #cardsInRarity > 0 then
			local index = math.random(1, #cardsInRarity)
			local pityCard = cardsInRarity[index]
			print("[RollModule] Carta de PITY sorteada:", pityCard, "Raridade:", rarity)
			return pityCard
		end
	end

	-- Sorteio normal de raridade
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

	local cardsInRarity = RARITY_CARDS[chosenRarity]
	if not cardsInRarity or #cardsInRarity == 0 then
		warn("[RollModule] ERRO: Nenhuma carta definida para raridade:", chosenRarity)
		return "CartaInexistente"
	end

	local randomIndex = math.random(1, #cardsInRarity)
	local cardName = cardsInRarity[randomIndex]

	print("[RollModule] Raridade sorteada:", chosenRarity)
	print("[RollModule] Carta sorteada:", cardName)

	return cardName
end

-- Retorna estado atual (opcional)
function M.GetState()
	return contador.Value, TIERS[tier], tier
end

print("[RollModule] Finalizou carregamento")
return M
