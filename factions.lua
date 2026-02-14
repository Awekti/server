-- Таблица скинов для Мэрии (Gov) по рангам
govSkins = {
    [1] = 171, -- Секретарь (Охранник/Офисный)
    [2] = 172, -- Инспектор
    [3] = 240, -- Аудитор (Деловой стиль)
    [4] = 227, -- Министр (Дорогой костюм)
    [5] = 147  -- Мэр (Статный старик в костюме)
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
    
    if jobName == "Gov" then
        setElementModel(player, 171)
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
        outputChatBox("Команда: /heal [Ник]", player, 255, 200, 0)
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
addCommandHandler("heal", function(player, cmd, targetName)
    if getElementData(player, "faction") == "Medic" then
        if not targetName then
            outputChatBox("Используйте: /heal [Ник игрока]", player, 255, 255, 0)
            return
        end
        local target = getPlayerFromName(targetName)
        if target then
            local px, py, pz = getElementPosition(player)
            local tx, ty, tz = getElementPosition(target)
             if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) < 3 then
                setElementHealth(target, 100)
                outputChatBox("Вы вылечили игрока " .. getPlayerName(target), player, 0, 255, 0)
                outputChatBox("Медик " .. getPlayerName(player) .. " вылечил вас!", target, 0, 255, 0)
            else
                outputChatBox("Игрок слишком далеко от вас!", player, 255, 0, 0)
            end
        else
            outputChatBox("Игрок с таким ником не найден!", player, 255, 0, 0)
        end
    else
        outputChatBox("Вы не медик!", player, 255, 0, 0)
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
