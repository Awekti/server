-- 1. НАСТРОЙКИ СПАВНА
local farmSpawnPoints = { {179.7, -6.7, 1.6}, {172.7, -6.8, 1.6}, {179.7, -6.7, 1.6} }
local detailsSpawnPoints = { {1337.919, 325.758, 19.997}, {1352.718, 355.694, 20.182} }

-- 2. ПИКАПЫ
local jobFarmPickup = createPickup(166.888, -33.835, 1.578, 3, 1275)
local jobDetailsPickup = createPickup(1348.015, 342.812, 20.306, 3, 1275)

-- 3. МАРКЕРЫ
local loadFarm1 = createMarker(165.0, -54.0, 1.0, "cylinder", 3, 255, 255, 0, 150)
local loadFarm2 = createMarker(165.0, -44.0, 1.0, "cylinder", 3, 255, 255, 0, 150)
local loadFarm3 = createMarker(165.0, -15.0, 1.0, "cylinder", 3, 255, 255, 0, 150)
local returnParts = createMarker(1355.404, 364.668, 19.1, "cylinder", 3, 255, 255, 255, 150)
--setElementVisibleTo(returnParts, root, false)

local finishCafe = createMarker(1362.675, 260.587, 18.5, "cylinder", 3, 0, 255, 0, 150)
local finishService = createMarker(1409.604, 459.781, 19.0, "cylinder", 3, 0, 100, 255, 150)

setElementVisibleTo(loadFarm1, root, false)
setElementVisibleTo(loadFarm2, root, false)
setElementVisibleTo(loadFarm3, root, false)
setElementVisibleTo(finishCafe, root, false)
setElementVisibleTo(finishService, root, false)
setElementVisibleTo(returnParts, root, false)

-- ФУНКЦИЯ: НАЧАЛО РАБОТЫ
function startDeliveryJob(player)
    if isPedInVehicle(player) then return end
    
    local isFarm = (source == jobFarmPickup)
    local posTable = isFarm and farmSpawnPoints or detailsSpawnPoints
    
    -- Детали называются detailsStock (проверь, чтобы в business.lua было так же)
    if not isFarm and (detailsStock or 0) < 10 then
        outputChatBox("[ЦЕХ] Нет запчастей! Нужно минимум 10 ед.", player, 255, 50, 50)
        return
    end

    local spawn = posTable[math.random(#posTable)]
    local veh = createVehicle(440, spawn[1], spawn[2], spawn[3], 0, 0, 340)
    warpPedIntoVehicle(player, veh)
    
    -- Устанавливаем единый флаг работы
    setElementData(player, "isDelivery", true)

    if isFarm then
        setElementData(player, "jobType", "farm")
        setElementVisibleTo(loadFarm1, player, true)
        setElementVisibleTo(loadFarm2, player, true)
        setElementVisibleTo(loadFarm3, player, true)
        outputChatBox("[ДОСТАВКА] Вези продукты в желтые маркеры!", player, 255, 255, 0)
    else
        setElementData(player, "jobType", "parts")
        detailsStock = detailsStock - 10
        setElementData(resourceRoot, "detailsStock", detailsStock)
        setElementVisibleTo(finishService, player, true)
        outputChatBox("[ДОСТАВКА] Запчасти загружены! Вези в сервис.", player, 0, 150, 255)
    end
end
addEventHandler("onPickupHit", jobFarmPickup, startDeliveryJob)
addEventHandler("onPickupHit", jobDetailsPickup, startDeliveryJob)

-- ФУНКЦИЯ: ЗАГРУЗКА НА ФЕРМЕ
local function onFarmLoad(player)
    if getElementData(player, "jobType") == "farm" and isElementVisibleTo(source, player) then
        if (factoryStock or 0) >= 10 then
            factoryStock = factoryStock - 10
            setElementData(resourceRoot, "factoryStock", factoryStock)
            setElementVisibleTo(loadFarm1, player, false)
            setElementVisibleTo(loadFarm2, player, false)
            setElementVisibleTo(loadFarm3, player, false)
            setElementVisibleTo(finishCafe, player, true)
            outputChatBox("[ДОСТАВКА] Продукты загружены! Вези в Кафе.", player, 0, 255, 0)
        else
            outputChatBox("[ФЕРМА] Мало ресурсов!", player, 255, 50, 50)
        end
    end
end
addEventHandler("onMarkerHit", loadFarm1, onFarmLoad)
addEventHandler("onMarkerHit", loadFarm2, onFarmLoad)
addEventHandler("onMarkerHit", loadFarm3, onFarmLoad)

-- ФУНКЦИЯ: РАЗГРУЗКА (КАФЕ И СЕРВИС)
function onFinishDelivery(player)
    if getElementType(player) ~= "player" or not isElementVisibleTo(source, player) then return end
    
    local job = getElementData(player, "jobType")
    local pHP = getElementHealth(player)

    if (bankBalance or 0) >= 50 then
        if pHP > 20 then
            bankBalance = bankBalance - 50
            givePlayerMoney(player, 50)
            setElementHealth(player, pHP - 20)
            setElementData(resourceRoot, "serverBank", bankBalance)

            if job == "farm" then
                cafeStock = (cafeStock or 0) + 5
                setElementData(resourceRoot, "cafeStock", cafeStock)
                setElementVisibleTo(finishCafe, player, false)
                setElementVisibleTo(loadFarm1, player, true)
                setElementVisibleTo(loadFarm2, player, true)
                setElementVisibleTo(loadFarm3, player, true)
                outputChatBox("[ДОСТАВКА] Продукты в Кафе! +$50. Езжай за новой партией.", thePlayer, 0, 255, 0)
            elseif job == "parts" then
                serviceStock = (serviceStock or 0) + 10
                setElementData(resourceRoot, "serviceStock", serviceStock)
                setElementVisibleTo(finishService, player, false)
                setElementVisibleTo(returnParts, player, true)
                outputChatBox("[ДОСТАВКА] Запчасти в Сервис! +$50. Вернись в Цех за новой партией (белый маркер).", thePlayer, 0, 255, 0)
            end
        else
            outputChatBox("[ДОСТАВКА] Ты слишком слаб!", player, 255, 0, 0)
        end
    else
        outputChatBox("[ДОСТАВКА] В банке нет денег!", player, 255, 0, 0)
    end
end
--ПОВТОРНАЯ ЗАГРУЗКА ЗАПЧАСТЕЙ
addEventHandler("onMarkerHit", returnParts, function(player)
    if getElementType(player) == "player" and isElementVisibleTo(source, player) then
        -- Проверяем склад цеха снова
        if (detailsStock or 0) >= 10 then
            detailsStock = detailsStock - 10
            setElementData(resourceRoot, "detailsStock", detailsStock)
            
            setElementVisibleTo(returnParts, player, false) -- Прячем возврат
            setElementVisibleTo(finishService, player, true) -- Показываем Сервис
            
            outputChatBox("[ДОСТАВКА] Новая партия запчастей загружена! Вези в Сервис.", player, 0, 150, 255)
        else
            outputChatBox("[ЦЕХ] Склад пуст! Подожди, пока рабочие сделают еще деталей.", player, 255, 50, 50)
        end
    end
end)
addEventHandler("onMarkerHit", finishCafe, onFinishDelivery)
addEventHandler("onMarkerHit", finishService, onFinishDelivery)

-- ФУНКЦИЯ: ВЫХОД ИЗ ТРАНСПОРТА / ОЧИСТКА
function cleanUpJob(player)
    if not isElement(player) then return end
    setElementData(player, "isDelivery", false)
    setElementData(player, "jobType", false)
    setElementVisibleTo(loadFarm1, player, false)
    setElementVisibleTo(loadFarm2, player, false)
    setElementVisibleTo(loadFarm3, player, false)
    setElementVisibleTo(finishCafe, player, false)
    setElementVisibleTo(finishService, player, false)
    setElementVisibleTo(returnParts, player, false)
end

addEventHandler("onVehicleExit", root, function(player)
     if getElementData(source, "isPersonal") then return end
     if getElementData(player, "isDelivery") and getElementModel(source) == 440 then
        local veh = source
        cleanUpJob(player)
        outputChatBox("[ДОСТАВКА] Машина будет удалена через 10 секунд!", player, 255, 100, 0)
        setTimer(function() if isElement(veh) then destroyElement(veh) end end, 10000, 1)
    end
end)

addEventHandler("onVehicleExplode", root, function()
    local driver = getVehicleController(source)
    --if getElementData(source, "isPersonal") then return end -- ПРОВЕРКА: Если взорвалась личная машина, НЕ удаляем её этим скриптом
    if driver and getElementData(driver, "isDelivery") then
        cleanUpJob(driver)
        outputChatBox("[ДОСТАВКА] Машина взорвана!", driver, 255, 0, 0)
    end
    setTimer(destroyElement, 5000, 1, source)
end)

