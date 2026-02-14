-- Список ID скинов
local randomSkins = {0, 1, 2, 7, 9, 12, 14, 15, 19, 20, 21, 22, 23, 26, 28, 29}
local startX, startY, startZ = 1354.8, 229.0, 19.6

function playerSpawn(thePlayer)
    local target = thePlayer or source
    if isElement(target) then
        local faction = getElementData(target, "faction")
        local rank = getElementData(target, "rank") or 1
        
        -- Сначала просто спавним (скин поставим в следующей строке)
        spawnPlayer(target, startX, startY, startZ, 0, 0)
        
        local finalSkin = 0
        if faction == "Gov" then
            finalSkin = govSkins[rank] or 171
        elseif faction == "Medic" then
            finalSkin = 274
        elseif faction == "Police" then
            finalSkin = 280
        else
            finalSkin = randomSkins[math.random(#randomSkins)]
        end
        
        -- Устанавливаем финальный скин
        setElementModel(target, finalSkin)
        
        setCameraTarget(target, target)
        fadeCamera(target, true)
        outputChatBox("Ты заспавнен! Твой скин ID: " .. finalSkin, target, 255, 200, 0)
    end
end

addEventHandler("onPlayerJoin", root, playerSpawn)
addCommandHandler("respawn", playerSpawn)

-- ФУНКЦИЯ СОЗДАНИЯ УЛИКИ
function createEvidence(victim, weapon, killer)
    if not isElement(victim) then return end
    
    local x, y, z = getElementPosition(victim)
    -- ПРОВЕРКА: Если это игрок - берем ник, если пед - пишем "NPC"
    local vName = getElementType(victim) == "player" and getPlayerName(victim) or "Неизвестный (NPC)"
    local deathReason = weapon or 0 

    local evidence = createObject(1210, x, y, z - 0.7)
    local col = createColSphere(x, y, z, 2.5)

    addEventHandler("onColShapeHit", col, function(hitElement)
        if getElementType(hitElement) == "player" then
            if getElementData(hitElement, "faction") == "Police" then
                outputChatBox("--- [ПОЛИЦИЯ] УЛИКА СОБРАНА ---", hitElement, 0, 100, 255)
                outputChatBox("Жертва: " .. vName, hitElement, 255, 255, 255)
                outputChatBox("Оружие/Причина (ID): " .. deathReason, hitElement, 255, 255, 255)
                
                if isElement(evidence) then destroyElement(evidence) end
                if isElement(source) then destroyElement(source) end 
            end
        end
    end)

    setTimer(function()
        if isElement(evidence) then destroyElement(evidence) end
        if isElement(col) then destroyElement(col) end
    end, 300000, 1)
end

------------------------- СМЕРТЬ/АННУЛИРОВАНИЕ --------------------------------------

function handlePlayerDeath(ammo, killer, weapon, bodypart)
    local player = source
    local moneyAtDeath = getPlayerMoney(player)
    
    -- СОЗДАЕМ УЛИКУ
    createEvidence(player, weapon, killer) 
    
    -- 1. Возвращаем деньги в банк штата
    if moneyAtDeath > 0 then
        bankBalance = (bankBalance or 0) + moneyAtDeath
        setElementData(resourceRoot, "serverBank", bankBalance)
        outputChatBox("[ЭКОНОМИКА] $" .. moneyAtDeath .. " умершего возвращены в банк!", root, 255, 200, 0)
    end
    
    -- 2. Обнуление данных через 100мс
    setTimer(function()
        if isElement(player) then
            setElementData(player, "isFactoryWorker", false)
            setElementData(player, "isDelivery", false)

            if loadFarm1 then setElementVisibleTo(loadFarm1, player, false) end
            if loadFarm2 then setElementVisibleTo(loadFarm2, player, false) end
            if loadFarm3 then setElementVisibleTo(loadFarm3, player, false) end
            if finishCafe then setElementVisibleTo(finishCafe, player, false) end
            if finishService then setElementVisibleTo(finishService, player, false) end
            if returnParts then setElementVisibleTo(returnParts, player, false) end

            setPlayerMoney(player, 0)
            takeAllWeapons(player)
            
            for _, house in ipairs(getElementsByType("pickup")) do
                if getElementData(house, "owner") == player then
                    setElementData(house, "owner", false)
                end
            end
            outputChatBox("Вы погибли. Имущество аннулировано.", player, 255, 0, 0)
        end
    end, 100, 1)
    
    -- 3. Респавн через 3 секунды
    setTimer(function()
        if isElement(player) then playerSpawn(player) end
    end, 3000, 1)
end
addEventHandler("onPlayerWasted", root, handlePlayerDeath)

addEventHandler("onPedWasted", root, function(ammo, killer, weapon)
    -- Если умер наш тестовый пед — создаем улику
    createEvidence(source, weapon, killer) 
    outputChatBox("NPC погиб! Улика создана для полиции.", root, 255, 100, 0)
end)

--==============NPC======================================
function createTestPed(player)
    local x, y, z = getElementPosition(player)
    local _, _, r = getElementRotation(player)
    
    -- Спавним педа чуть впереди игрока (скин 0 - СиДжей)
    local testPed = createPed(0, x + 2, y, z)
    setElementRotation(testPed, 0, 0, r + 180) -- Повернем лицом к нам
    
    -- Дадим ему имя, чтобы /heal работал (если ты перепишешь /heal под педов)
    setElementData(testPed, "isTestPed", true)
    
    outputChatBox("Тестовый NPC создан! Его можно бить или пробовать лечить.", player, 0, 255, 0)
end
addCommandHandler("testped", createTestPed)
addCommandHandler("clearped", function(player)
    for _, ped in ipairs(getElementsByType("ped")) do
        if getElementData(ped, "isTestPed") then
            destroyElement(ped)
        end
    end
    outputChatBox("Все тестовые NPC удалены.", player, 255, 0, 0)
end)

