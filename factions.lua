-- Таблица скинов для Мэрии (Gov) по рангам
govSkins = {
    [1] = 171, -- Секретарь (Охранник/Офисный)
    [2] = 172, -- Инспектор
    [3] = 240, -- Аудитор (Деловой стиль)
    [4] = 227, -- Министр (Дорогой костюм)
    [5] = 147  -- Мэр (Статный старик в костюме)
}

farmSkins = { [1] = 158,
              [2] = 159, 
              [3] = 160, 
              [4] = 161,
              [5] = 133
}

-- Скины для других фракций
local factionDefaultSkins = {
    ["Medic"] = 274,
    ["Police"] = 280
}

function setJob(player, jobName)
    -- 1. Сначала полностью очищаем старые данные
    setElementData(player, "faction", false)
    setElementData(player, "rank", 0)
    setElementData(player, "repairedCars", 0)
    
    setElementData(player, "faction", jobName)
    setElementData(player, "rank", 1)
    setElementData(player, "farm_xp", 0) -- Для фермеров

     if jobName == "Farmer" then
        setElementModel(player, farmSkins[1])
    elseif jobName == "Gov" then
        setElementModel(player, govSkins[1] or 171)
        checkGovPromotion(player) -- Проверяем, может он сразу 4 ранг
    elseif jobName == "Medic" then
        setElementModel(player, 274)
    elseif jobName == "Police" then
        setElementModel(player, 280)
    end

    outputChatBox("Вы теперь: " .. jobName .. " (Ранг 1)", player, 0, 255, 0)
    
    -- Подсказки по командам
    if jobName == "Gov" then
        outputChatBox("Команда: /govstats", player, 255, 200, 0)
        setElementData(player, "rank", 1)
    checkGovPromotion(player)
    elseif jobName == "Medic" then
        outputChatBox("Команда:\n/heal [Ник]\n/cure1 - простуда\n/cure2 - отравление\n/cure3 - анемия", player, 255, 200, 0)
    elseif jobName == "Police" then
        outputChatBox("Твоя задача: искать улики на местах смертей.", player, 255, 200, 0)
    end
end

addCommandHandler("myrank", function(p)
    local f = getElementData(p, "faction") or "Нет"
    local r = getElementData(p, "rank") or 0
    outputChatBox("Ваша фракция: " .. f .. " | Ваш ранг: " .. r, p, 255, 255, 0)
end)

-- Команды для теста (потом сделаем через пикапы)
addCommandHandler("police", function(p) setJob(p, "Police") end)
addCommandHandler("medic", function(p) setJob(p, "Medic") end)
addCommandHandler("gov", function(player)
    setElementData(player, "faction", "Gov")
    setElementData(player, "rank", 1)         -- Ранг по умолчанию
    setElementData(player, "repairedCars", 0) -- Счетчик починок для 2 ранга
    outputChatBox("Вы вступили в Правительство (Ранг 1: Секретарь)", player, 255, 200, 0)
end)

--===========MEDIC============================
-- factions.lua (Server-side)

-- 1. ОБЩАЯ ФУНКЦИЯ ПРОВЕРКИ (вынесена отдельно, чтобы все её видели)
function checkMedicAction(medic, targetName)
    if getElementData(medic, "faction") ~= "Medic" then return false end
    if not targetName then 
        outputChatBox("Используйте: /команда [Ник]", medic, 255, 255, 0)
        return false 
    end
    
    local target = getPlayerFromName(targetName)
    if not target then 
        outputChatBox("Игрок не найден!", medic, 255, 0, 0)
        return false 
    end
    
    local mx, my, mz = getElementPosition(medic)
    local tx, ty, tz = getElementPosition(target)
    local dist = getDistanceBetweenPoints3D(mx, my, mz, tx, ty, tz)
    
    if dist > 3 then 
        outputChatBox("Игрок слишком далеко!", medic, 255, 0, 0)
        return false 
    end
    
    return target
end

-- 2. ОБЫЧНОЕ ЛЕЧЕНИЕ (ХП)
addCommandHandler("heal", function(player, cmd, targetName)
    local target = checkMedicAction(player, targetName)
    if target then
        setElementHealth(target, 100)
        outputChatBox("Вы вылечили игрока " .. getPlayerName(target), player, 0, 255, 0)
        outputChatBox("Медик " .. getPlayerName(player) .. " вылечил вас!", target, 0, 255, 0)
    end
end)

-- 3. Лечение ПРОСТУДЫ
addCommandHandler("cure1", function(player, cmd, targetName)
    local target = checkMedicAction(player, targetName)
    if target and getElementData(target, "disease") == "Flu" then
    setElementData(target, "disease", false)
    
    -- Анимация осмотра для медика
    setPedAnimation(player, "MEDIC", "CPR", 3000, false, false, false, false)
    -- Анимация облегчения для пациента через 3 секунды
    setTimer(function()
        if isElement(target) then 
            setPedAnimation(target, "PLAYER_PLAYBACK", "STREETWALK_IDLE", 3000, false, false, false, false)
        end
    end, 3000, 1)

    outputChatBox("Вы дали сироп от кашля. Простуда прошла!", player, 0, 255, 0)
            outputChatBox("Медик вылечил вашу простуду!", target, 0, 255, 0)
        else
            outputChatBox("У игрока нет простуды!", player, 255, 0, 0)
        end
    end)

-- 4. Лечение ОТРАВЛЕНИЯ
addCommandHandler("cure2", function(player, cmd, targetName)
    local target = checkMedicAction(player, targetName)
    if target and getElementData(target, "disease") == "Poison" then
    setElementData(target, "disease", false)
    
    -- Анимация осмотра для медика
    setPedAnimation(player, "MEDIC", "CPR", 5000, false, false, false, false)
    -- Анимация облегчения для пациента через 3 секунды
    setTimer(function()
        if isElement(target) then 
            setPedAnimation(target, "PLAYER_PLAYBACK", "STREETWALK_IDLE", 3000, false, false, false, false)
        end
    end, 3000, 1)

    outputChatBox("Вы сделали промывание желудка. Отравление снято!", player, 0, 255, 0)
            outputChatBox("Медик спас вас от отравления!", target, 0, 255, 0)
        else
            outputChatBox("У игрока нет отравления!", player, 255, 0, 0)
        end
    end)

-- 5. Лечение АНЕМИИ
addCommandHandler("cure3", function(player, cmd, targetName)
    local target = checkMedicAction(player, targetName)
    if target and getElementData(target, "disease") == "Anemia" then
    setElementData(target, "disease", false)
    
    -- Анимация осмотра для медика
    setPedAnimation(player, "MEDIC", "CPR", 3000, false, false, false, false)
    -- Анимация облегчения для пациента через 3 секунды
    setTimer(function()
        if isElement(target) then 
            setPedAnimation(target, "PLAYER_PLAYBACK", "STREETWALK_IDLE", 3000, false, false, false, false)
        end
    end, 3000, 1)

    outputChatBox("Вы вкололи витамины. Анемия побеждена!", player, 0, 255, 0)
            setElementHealth(target, 100) -- Возвращаем ХП, так как оно было залочено на 50
            outputChatBox("Медик вернул вам силы (Анемия прошла)!", target, 0, 255, 0)
        else
            outputChatBox("У игрока нет анемии!", player, 255, 0, 0)
        end
    end)

--=============================================
--===========GOV===============================

addCommandHandler("govstats", function(player)
    if getElementData(player, "faction") == "Gov" then
        outputChatBox("--- СОСТОЯНИЕ ШТАТА ---", player, 255, 200, 0)
        outputChatBox("Бюджет Банка: $" .. (bankBalance or 0), player, 255, 255, 255)
        outputChatBox("Склад Фермы: " .. (factoryStock or 0), player, 255, 255, 255)
        outputChatBox("Склад Кафе: " .. (cafeStock or 0), player, 255, 255, 255)
        outputChatBox("Запчасти (Цех): " .. (detailsStock or 0), player, 255, 255, 255)
        outputChatBox("Запчасти (Сервис): " .. (serviceStock or 0), player, 255, 255, 255)
    else
        outputChatBox("Доступ запрещен. Вы не из Правительства.", player, 255, 0, 0)
    end
end)
-- Функция автоматического повышения для Мэрии
function checkGovPromotion(player)
    if getElementData(player, "faction") ~= "Gov" then return end
    
    local currentRank = getElementData(player, "rank") or 1
    if currentRank >= 4 then return end 
    local repaired = getElementData(player, "repairedCars") or 0
    local newRank = 1 -- Базовый ранг

    -- 1. Проверяем условие для 2 ранга (Починки)
    if repaired >= 5 then
        newRank = 2
    end

    -- 2. Проверяем условие для 3 ранга (Дом)
    -- Если уже есть 2 ранг, проверяем наличие дома
    if newRank == 2 then
        local hasHouse = false
        for _, house in ipairs(getElementsByType("pickup")) do
            if getElementData(house, "owner") == player then 
                hasHouse = true 
                break 
            end
        end
        if hasHouse then newRank = 3 end
        local currentSkin = getElementModel(player)
    local targetSkin = govSkins[newRank]

    -- Если ранг повысился ИЛИ если скин не совпадает с рангом (например, после спавна)
    if newRank > currentRank or (currentSkin ~= targetSkin and getElementData(player, "faction") == "Gov") then
        setElementData(player, "rank", newRank)
        setElementModel(player, targetSkin)
        
        -- Выводим сообщение только если это реально ПОВЫШЕНИЕ
        if newRank > currentRank then
            local rankNames = {"Секретарь", "Инспектор", "Аудитор", "Министр", "Мэр"}
            outputChatBox("[МЭРИЯ] Повышение! Ваш новый ранг: " .. newRank .. " (" .. rankNames[newRank] .. ")", player, 0, 255, 0)
        end
    end
    end

    -- 3. Проверяем условие для 4 ранга (Машина)
    -- Если уже есть 3 ранг, проверяем наличие личного авто
    if newRank == 3 then
        local hasCar = false
        for _, veh in ipairs(getElementsByType("vehicle")) do
            if getElementData(veh, "isPersonal") and getElementData(veh, "owner") == player then 
                hasCar = true 
                break 
            end
        end
        if hasCar then newRank = 4 end
    end

    -- Сравниваем: если новый высчитанный ранг выше текущего — ПОВЫШАЕМ
    if newRank > currentRank then
        setElementData(player, "rank", newRank)
        if govSkins[newRank] then
            setElementModel(player, govSkins[newRank])
        end
        local rankNames = {"Секретарь", "Инспектор", "Аудитор", "Министр", "Мэр"}
        outputChatBox("[МЭРИЯ] Повышение! Ваш новый ранг: " .. newRank .. " (" .. rankNames[newRank] .. ")", player, 0, 255, 0)
    end
end

setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "faction") == "Gov" then
            checkGovPromotion(player) -- Вся логика внутри этой функции (как мы писали)
        end
    end
end, 30000, 0)

--=============================ПОЛИЦИЯ======================================

-- factions.lua (Server-side)

-- Таблица рангов полиции
local policeRanks = {
    [1] = { name = "Кадет", goal = 0, skin = 280 },
    [2] = { name = "Офицер", goal = 10, skin = 281 },
    [3] = { name = "Детектив", goal = 25, skin = 282 }
}

-- Функция обновления опыта полиции (вызывай её при сборе улики)
function updatePoliceXP(player)
    if getElementData(player, "faction") ~= "Police" then return end
    
    local xp = (getElementData(player, "police_xp") or 0) + 1
    local rank = getElementData(player, "rank") or 1
    setElementData(player, "police_xp", xp)
    
    -- Проверка повышения до 2 ранга (10 улик)
    if rank == 1 and xp >= 10 then
        setElementData(player, "rank", 2)
        setElementModel(player, policeRanks[2].skin)
    end
    
    -- Проверка повышения до 3 ранга (25 улик)
    if rank == 2 and xp >= 25 then
        setElementData(player, "rank", 3)
        setElementModel(player, policeRanks[3].skin)
    end
end

