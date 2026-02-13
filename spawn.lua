-- Список ID скинов
local randomSkins = {0, 1, 2, 7, 9, 12, 14, 15, 19, 20, 21, 22, 23, 26, 28, 29}
local startX, startY, startZ = 1354.8, 229.0, 19.6

function playerSpawn(thePlayer)
    local target = thePlayer or source
    if isElement(target) then
        local randomID = randomSkins[math.random(#randomSkins)]
        spawnPlayer(target, startX, startY, startZ, 0, randomID)
        setCameraTarget(target, target)
        fadeCamera(target, true)
        outputChatBox("Тебе достался скин ID: " .. randomID, target, 255, 200, 0)
    end
end

addEventHandler("onPlayerJoin", root, playerSpawn)
addCommandHandler("respawn", playerSpawn)

------------------------- СМЕРТЬ/АНУЛИРОВАНИЕ --------------------------------------

function handlePlayerDeath()
    local player = source
    local moneyAtDeath = getPlayerMoney(player)
    
    -- 1. Возвращаем деньги в банк штата
    if moneyAtDeath > 0 then
        bankBalance = bankBalance + moneyAtDeath
        setElementData(resourceRoot, "serverBank", bankBalance)
        outputChatBox("[ЭКОНОМИКА] $" .. moneyAtDeath .. " умершего игрока возвращены в банк штата!", root, 255, 200, 0)
    end
    
    -- 2. Обнуление данных через 100мс (чтобы перебить стандартные скрипты)
    setTimer(function()
        if isElement(player) then
            setElementData(player, "isFactoryWorker", false)
            setElementData(player, "isDelivery", false)

            if cargoMarker1 then setElementVisibleTo(cargoMarker1, player, false) end
            if cargoMarker2 then setElementVisibleTo(cargoMarker2, player, false) end
            if dropMarker then setElementVisibleTo(dropMarker, player, false) end

            -- ПРЯЧЕМ МАРКЕРЫ ДОСТАВЩИКА (если они есть)
            if loadMarker1 then setElementVisibleTo(loadMarker1, player, false) end
            if loadMarker2 then setElementVisibleTo(loadMarker2, player, false) end
            if finishMarker then setElementVisibleTo(finishMarker, player, false) end
            
            setPlayerMoney(player, 0) -- ПРИНУДИТЕЛЬНО В 0
            takeAllWeapons(player)
            
            -- Лишаем прав на все дома
            for _, house in ipairs(getElementsByType("pickup")) do
                local owner = getElementData(house, "owner")
                if owner == player then
                    setElementData(house, "owner", false)
                    outputChatBox("[СИСТЕМА] Вы погибли и потеряли право на свою недвижимость!", player, 255, 0, 0)
                end
            end
            
            outputChatBox("Ваш персонаж погиб. Всё имущество аннулировано.", player, 255, 0, 0)
        end
    end, 100, 1) -- Закрыли таймер обнуления
    
    -- 3. Автоматический респавн через 3 секунды
    setTimer(function()
        if isElement(player) then
            playerSpawn(player) 
        end
    end, 3000, 1) -- Закрыли таймер респавна
end

addEventHandler("onPlayerWasted", root, handlePlayerDeath)
