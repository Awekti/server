-- Таблица спавна (Rumpo ID 440)
local spawnPoints = {
    {179.7, -6.7, 1.6, 338},
    {172.7, -6.8, 1.6, 338},
    {179.7, -6.7, 1.6, 338}
}

-- 1. Пикап начала работы
local jobStartPickup = createPickup(166.888, -33.835, 1.578, 3, 1275)

-- 2. Маркеры загрузки (ставим альфу 150, но выключаем видимость для всех через false)
local loadMarker1 = createMarker(165.0, -44.0, 1.578, "cylinder", 3, 255, 255, 0, 150)
local loadMarker2 = createMarker(165.0, -54.0, 1.578, "cylinder", 3, 255, 255, 0, 150)
local loadMarker3 = createMarker(165.0, -15.0, 1.578, "cylinder", 3, 255, 255, 0, 150)
setElementVisibleTo(loadMarker1, root, false)
setElementVisibleTo(loadMarker2, root, false)
setElementVisibleTo(loadMarker3, root, false)

-- 3. Маркер разгрузки
local finishMarker = createMarker(1362.675, 260.587, 18.5, "cylinder", 3, 0, 255, 0, 150)
setElementVisibleTo(finishMarker, root, false)

-- Функция начала работы
addEventHandler("onPickupHit", jobStartPickup, function(player)
    if getElementType(player) == "player" and not isPedInVehicle(player) then
        local pos = spawnPoints[math.random(#spawnPoints)]
        local vehicle = createVehicle(440, pos[1], pos[2], pos[3], 0, 0, pos[4])
        
        setElementData(vehicle, "creator", player)
        warpPedIntoVehicle(player, vehicle)
        setElementData(player, "isDelivery", true)
        
        -- Включаем видимость маркеров ТОЛЬКО для этого игрока
        setElementVisibleTo(loadMarker1, player, true)
        setElementVisibleTo(loadMarker2, player, true)
        setElementVisibleTo(loadMarker3, player, true)
        
        outputChatBox("[ДОСТАВКА] Машина подана! Езжай на погрузку (желтые маркеры).", player, 255, 255, 0)
    end
end)

-- Функция загрузки
function onLoadHit(player)
    if getElementType(player) == "player" and getElementData(player, "isDelivery") then
        if isElementVisibleTo(source, player) then
            if factoryStock >= 10 then
                -- Списываем товар со склада
                factoryStock = factoryStock - 10
                setElementData(resourceRoot, "factoryStock", factoryStock)
            setElementVisibleTo(loadMarker1, player, false)
            setElementVisibleTo(loadMarker2, player, false)
            setElementVisibleTo(loadMarker3, player, false)
            setElementVisibleTo(finishMarker, player, true)
            outputChatBox("[ДОСТАВКА] 10 ед. товара загружены со склада! Вези на выгрузку.", player, 0, 255, 0)
                outputChatBox("[СКЛАД] Остаток ресурсов на заводе: " .. factoryStock, player, 200, 200, 255)
            else
                -- Если товара мало
                outputChatBox("[ДОСТАВКА] На складе пусто! Подожди, пока рабочие завода сделают товар.", player, 255, 50, 50)
                outputChatBox("[ИНФО] Нужно минимум 10 ед. (Сейчас на складе: " .. factoryStock .. ")", player, 255, 255, 255)
            end
            
        end
    end
end
addEventHandler("onMarkerHit", loadMarker1, onLoadHit)
addEventHandler("onMarkerHit", loadMarker2, onLoadHit)
addEventHandler("onMarkerHit", loadMarker3, onLoadHit)

-- Функция разгрузки
addEventHandler("onMarkerHit", finishMarker, function(player)
    if getElementType(player) == "player" and isElementVisibleTo(source, player) then
        local pHP = getElementHealth(player)
        
        if bankBalance >= 50 then
            if pHP > 20 then
                bankBalance = bankBalance - 50
                givePlayerMoney(player, 50)
                cafeStock = cafeStock + 10
                setElementData(resourceRoot, "cafeStock", cafeStock)
                setElementData(resourceRoot, "serverBank", bankBalance)
                setElementHealth(player, pHP - 20)
                
                -- Снова на круг: выключаем финиш, включаем старт
                setElementVisibleTo(finishMarker, player, false)
                setElementVisibleTo(loadMarker1, player, true)
                setElementVisibleTo(loadMarker2, player, true)
                setElementVisibleTo(loadMarker3, player, true)

                outputChatBox("[ДОСТАВКА] Ты привез 10 ед. продуктов в Кафе!", player, 0, 255, 0) -- кафе
                outputChatBox("[КАФЕ] На складе продуктов: " .. cafeStock, player, 200, 255, 200) -- кафе
                
                outputChatBox("[ДОСТАВКА] Доставлено! +$50. Возвращайся за новой партией.", player, 0, 255, 0)
            else
                outputChatBox("[ДОСТАВКА] Ты слишком слаб (нужно >20 HP)!", player, 255, 0, 0)
            end
        else
            outputChatBox("[ДОСТАВКА] В банке нет денег!", player, 255, 0, 0)
        end
    end
end)

-- Функция: Игрок вышел из машины
addEventHandler("onVehicleExit", root, function(player, seat)
    -- Проверяем, что у игрока активна работа и это нужная модель (Rumpo 440)
    if getElementData(player, "isDelivery") and getElementModel(source) == 440 then
        local theVehicle = source -- Сохраняем ссылку на машину
        
        -- Сбрасываем данные игрока и прячем маркеры СРАЗУ
        setElementData(player, "isDelivery", false)
        setElementVisibleTo(loadMarker1, player, false)
        setElementVisibleTo(loadMarker2, player, false)
        setElementVisibleTo(loadMarker3, player, false)
        setElementVisibleTo(finishMarker, player, false)
        
        outputChatBox("[ДОСТАВКА] Ты покинул транспорт. Машина будет удалена через 10 секунд!", player, 255, 100, 0)

        -- Удаляем машину через 10 секунд, передавая 'theVehicle' в функцию
        setTimer(function(veh)
            if isElement(veh) then 
                destroyElement(veh) 
            end
        end, 10000, 1, theVehicle)
    end
end)

-- Функция: Машина взорвалась
addEventHandler("onVehicleExplode", root, function()
    if getElementModel(source) == 440 then
        -- Ищем, кто был водителем
        local driver = getVehicleController(source)
        if driver and getElementData(driver, "isDelivery") then
            setElementData(driver, "isDelivery", false)
            setElementVisibleTo(loadMarker1, driver, false)
            setElementVisibleTo(loadMarker2, driver, false)
            setElementVisibleTo(loadMarker3, driver, false)
            setElementVisibleTo(finishMarker, driver, false)
            outputChatBox("[ДОСТАВКА] Машина уничтожена! Работа провалена.", driver, 255, 0, 0)
        end
        -- Удаляем остатки машины через 5 секунд
        setTimer(destroyElement, 5000, 1, source)
    end
end)
