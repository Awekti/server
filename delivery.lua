-- 1. НАСТРОЙКИ СПАВНА
local farmSpawnPoints = { {1220.5, 133.5, 20.7}, {1210.6, 138.5, 20.7}, {1215.4, 135.8, 20.7} }
local partsSpawnPoints = { {1337.919, 325.758, 20.0}, {1352.718, 355.694, 20.0} }

-- 2. ПИКАПЫ НАЧАЛА РАБОТЫ
local jobFarmPickup = createPickup(1228.328, 181.759, 20.362, 3, 1275) -- Ферма
local jobPartsPickup = createPickup(1348.015, 342.812, 20.306, 3, 1275) -- Запчасти

-- 3. МАРКЕРЫ (все создаем невидимыми)
local loadFarm1 = createMarker(1237.799, 178.082, 19.3, "cylinder", 3, 255, 255, 0, 0)
local loadFarm2 = createMarker(1219.054, 186.866, 19.2, "cylinder", 3, 255, 255, 0, 0)
local finishCafe = createMarker(1362.675, 260.587, 18.5, "cylinder", 3, 0, 255, 0, 0)

local finishService = createMarker(1409.604, 459.781, 19.0, "cylinder", 3, 0, 100, 255, 0)

setElementVisibleTo(loadFarm1, root, false)
setElementVisibleTo(loadFarm2, root, false)
setElementVisibleTo(finishCafe, root, false)
setElementVisibleTo(finishService, root, false)

-- ФУНКЦИЯ: НАЧАЛО ЛЮБОЙ РАБОТЫ
function startDeliveryJob(player)
    if isPedInVehicle(player) then return end
    
    local factoryStartPickup = (source == factoryStartPickup)
    local posTable = isFarm and farmSpawnPoints or partsSpawnPoints
    
    -- Для запчастей проверяем склад цеха сразу
    if not isFarm and sparePartsStock < 10 then
        outputChatBox("[ЦЕХ] Нет запчастей! Нужно минимум 10 ед.", player, 255, 50, 50)
        return
    end

    local spawn = posTable[math.random(#posTable)]
    local veh = createVehicle(440, spawn[1], spawn[2], spawn[3], 0, 0, 340)
    warpPedIntoVehicle(player, veh)
    
    if isFarm then
        setElementData(player, "jobType", "farm")
        setElementVisibleTo(loadFarm1, player, true)
        setElementVisibleTo(loadFarm2, player, true)
        outputChatBox("[ДОСТАВКА] Вези продукты в желтые маркеры!", player, 255, 255, 0)
    else
        setElementData(player, "jobType", "parts")
        sparePartsStock = sparePartsStock - 10 -- Списываем запчасти
        setElementData(resourceRoot, "sparePartsStock", sparePartsStock)
        setElementVisibleTo(finishService, player, true)
        outputChatBox("[ДОСТАВКА] Запчасти загружены! Вези в синий маркер сервиса.", player, 0, 150, 255)
    end
end
addEventHandler("onPickupHit", jobFarmPickup, startDeliveryJob)
addEventHandler("onPickupHit", jobPartsPickup, startDeliveryJob)

-- ФУНКЦИЯ: ЗАГРУЗКА НА ФЕРМЕ
addEventHandler("onMarkerHit", loadFarm1, function(player)
    if getElementData(player, "jobType") == "farm" and isElementVisibleTo(source, player) then
        if factoryStock >= 10 then
            factoryStock = factoryStock - 10
            setElementData(resourceRoot, "factoryStock", factoryStock)
            setElementVisibleTo(loadFarm1, player, false)
            setElementVisibleTo(loadFarm2, player, false)
            setElementVisibleTo(finishCafe, player, true)
            outputChatBox("[ДОСТАВКА] Продукты загружены! Вези в Кафе.", player, 0, 255, 0)
        else
            outputChatBox("[ФЕРМА] Мало ресурсов! Нужно 10 ед.", player, 255, 50, 50)
        end
    end
end)
-- (Аналогично для loadFarm2, если нужно — привяжи к этой же функции)

-- ФУНКЦИЯ: РАЗГРУЗКА (КАФЕ ИЛИ СЕРВИС)
function onFinishDelivery(player)
    if not isElementVisibleTo(source, player) then return end
    local job = getElementData(player, "jobType")
    
    if bankBalance >= 50 then
        bankBalance = bankBalance - 50
        givePlayerMoney(player, 50)
        setElementHealth(player, getElementHealth(player) - 20)
        
        if job == "farm" then
            cafeStock = cafeStock + 10
            setElementData(resourceRoot, "cafeStock", cafeStock)
            setElementVisibleTo(finishCafe, player, false)
            setElementVisibleTo(loadFarm1, player, true) -- На новый круг
            setElementVisibleTo(loadFarm2, player, true)
            outputChatBox("[КАФЕ] Продукты доставлены! +$50", player, 0, 255, 0)
        elseif job == "parts" then
            serviceStock = serviceStock + 10
            setElementData(resourceRoot, "serviceStock", serviceStock)
            setElementVisibleTo(finishService, player, false)
            -- Для запчастей работа разовая (машина удалится при выходе)
            outputChatBox("[СЕРВИС] Запчасти доставлены! +$50. Машину можно бросать.", player, 0, 255, 0)
        end
    else
        outputChatBox("[БАНК] В казне нет денег на оплату!", player, 255, 0, 0)
    end
end
addEventHandler("onMarkerHit", finishCafe, onFinishDelivery)
addEventHandler("onMarkerHit", finishService, onFinishDelivery)

-- УНИВЕРСАЛЬНОЕ УДАЛЕНИЕ ПРИ ВЫХОДЕ
addEventHandler("onVehicleExit", root, function(player)
    if getElementData(player, "jobType") and getElementModel(source) == 440 then
        local v = source
        setElementData(player, "jobType", false)
        setElementVisibleTo(loadFarm1, player, false)
        setElementVisibleTo(loadFarm2, player, false)
        setElementVisibleTo(finishCafe, player, false)
        setElementVisibleTo(finishService, player, false)
        setTimer(function() if isElement(v) then destroyElement(v) end end, 2000, 1)
        outputChatBox("[ДОСТАВКА] Работа завершена/аннулирована.", player, 255, 50, 50)
    end
end)
