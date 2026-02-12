-- Таблица спавна (Rumpo ID 440)
local spawnPoints = {
    {1220.5, 133.5, 20.7, 338},
    {1210.6, 138.5, 20.7, 338},
    {1215.4, 135.8, 20.7, 338}
}

-- 1. Пикап начала работы
local jobStartPickup = createPickup(1228.328, 181.759, 20.362, 3, 1275)

-- 2. Маркеры загрузки (ставим альфу 150, но выключаем видимость для всех через false)
local loadMarker1 = createMarker(1237.799, 178.082, 19.3, "cylinder", 3, 255, 255, 0, 150)
local loadMarker2 = createMarker(1219.054, 186.866, 19.2, "cylinder", 3, 255, 255, 0, 150)
setElementVisibleTo(loadMarker1, root, false)
setElementVisibleTo(loadMarker2, root, false)

-- 3. Маркер разгрузки
local finishMarker = createMarker(1362.675, 260.587, 18.5, "cylinder", 3, 0, 255, 0, 150)
setElementVisibleTo(finishMarker, root, false)

-- Функция начала работы
addEventHandler("onPickupHit", jobStartPickup, function(player)
    if getElementType(player) == "player" and not isPedInVehicle(player) then
        local pos = spawnPoints[math.random(#spawnPoints)]
        local vehicle = createVehicle(440, pos[1], pos[2], pos[3], 0, 0, pos[4])
        
        warpPedIntoVehicle(player, vehicle)
        setElementData(player, "isDelivery", true)
        
        -- Включаем видимость маркеров ТОЛЬКО для этого игрока
        setElementVisibleTo(loadMarker1, player, true)
        setElementVisibleTo(loadMarker2, player, true)
        
        outputChatBox("[ДОСТАВКА] Машина подана! Езжай на погрузку (желтые маркеры).", player, 255, 255, 0)
    end
end)

-- Функция загрузки
function onLoadHit(player)
    if getElementType(player) == "player" and getElementData(player, "isDelivery") then
        -- Проверяем, видит ли игрок этот маркер (значит он на этом этапе)
        if isElementVisibleTo(source, player) then
            setElementVisibleTo(loadMarker1, player, false)
            setElementVisibleTo(loadMarker2, player, false)
            setElementVisibleTo(finishMarker, player, true)
            outputChatBox("[ДОСТАВКА] Товар загружен! Вези на точку выгрузки.", player, 0, 255, 0)
        end
    end
end
addEventHandler("onMarkerHit", loadMarker1, onLoadHit)
addEventHandler("onMarkerHit", loadMarker2, onLoadHit)

-- Функция разгрузки
addEventHandler("onMarkerHit", finishMarker, function(player)
    if getElementType(player) == "player" and isElementVisibleTo(source, player) then
        local pHP = getElementHealth(player)
        
        if bankBalance >= 50 then
            if pHP > 20 then
                bankBalance = bankBalance - 50
                givePlayerMoney(player, 50)
                setElementHealth(player, pHP - 20)
                
                -- Снова на круг: выключаем финиш, включаем старт
                setElementVisibleTo(finishMarker, player, false)
                setElementVisibleTo(loadMarker1, player, true)
                setElementVisibleTo(loadMarker2, player, true)
                
                outputChatBox("[ДОСТАВКА] Доставлено! +$50. Возвращайся за новой партией.", player, 0, 255, 0)
            else
                outputChatBox("[ДОСТАВКА] Ты слишком слаб (нужно >20 HP)!", player, 255, 0, 0)
            end
        else
            outputChatBox("[ДОСТАВКА] В банке нет денег!", player, 255, 0, 0)
        end
    end
end)
