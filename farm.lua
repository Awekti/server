-- farm.lua (Server-side)

-- 1. Координаты (Проверь Z, поднял до 2.5 для надежности)
local f1_Start = {-4.467, 67.347, 3.117}
local f1_Cargos = { {13.132, 74.044, 2.5}, {13.541, 63.487, 2.5} }
local f1_Drop = {-1.442, 74.723, 2.5}

local f2_Start = {-81.663, 83.453, 3.117}
local f2_Cargo = {-108.241, 95.281, 2.5}
local f2_Drop = {-79.188, 90.474, 2.5}

-- 2. Создание объектов
local pick1 = createPickup(f1_Start[1], f1_Start[2], f1_Start[3], 3, 1275)
local pick2 = createPickup(f2_Start[1], f2_Start[2], f2_Start[3], 3, 1275)

local m_f1_c1 = createMarker(f1_Cargos[1][1], f1_Cargos[1][2], f1_Cargos[1][3], "cylinder", 1.5, 255, 255, 0, 150)
local m_f1_c2 = createMarker(f1_Cargos[2][1], f1_Cargos[2][2], f1_Cargos[2][3], "cylinder", 1.5, 255, 255, 0, 150)
local m_f1_drop = createMarker(f1_Drop[1], f1_Drop[2], f1_Drop[3], "cylinder", 1.5, 0, 255, 0, 150)

local m_f2_c = createMarker(f2_Cargo[1], f2_Cargo[2], f2_Cargo[3], "cylinder", 1.5, 255, 255, 0, 150)
local m_f2_drop = createMarker(f2_Drop[1], f2_Drop[2], f2_Drop[3], "cylinder", 1.5, 0, 255, 0, 150)

-- Скрываем для всех (root)
setElementVisibleTo(m_f1_c1, root, false)
setElementVisibleTo(m_f1_c2, root, false)
setElementVisibleTo(m_f1_drop, root, false)
setElementVisibleTo(m_f2_c, root, false)
setElementVisibleTo(m_f2_drop, root, false)

-- 3. Функция переключения смены
function onFarmPickup(player)
    if getElementType(player) ~= "player" or isPedInVehicle(player) then return end
    
    -- Проверяем наличие функции setJob (из factions.lua)
    if type(setJob) ~= "function" then
        outputChatBox("ОШИБКА: Функция setJob не найдена! Проверь meta.xml", player, 255, 0, 0)
        return
    end

    -- Если еще не фермер — нанимаем
    if getElementData(player, "faction") ~= "Farmer" then
        setJob(player, "Farmer")
    end

    -- Переключаем статус работы
    local isWorking = not getElementData(player, "isWorking")
    setElementData(player, "isWorking", isWorking)

    local rank = getElementData(player, "rank") or 1
    local isFirstField = (source == pick1)

    -- Чистка (скрываем всё перед включением)
    setElementVisibleTo(m_f1_c1, player, false)
    setElementVisibleTo(m_f1_c2, player, false)
    setElementVisibleTo(m_f1_drop, player, false)
    setElementVisibleTo(m_f2_c, player, false)
    setElementVisibleTo(m_f2_drop, player, false)

    if isWorking then
        if isFirstField then
            local r = math.random(1, 2)
            local targetMarker = (r == 1 and m_f1_c1 or m_f1_c2)
            setElementVisibleTo(targetMarker, player, true)
            outputChatBox("[ФЕРМА №1] Смена начата! Иди к желтому маркеру.", player, 255, 255, 0)
        else
            if rank >= 2 then
                setElementVisibleTo(m_f2_c, player, true)
                outputChatBox("[ФЕРМА №2] Смена начата!", player, 255, 255, 0)
            else
                outputChatBox("Доступ ко второму полю только со 2-го ранга!", player, 255, 0, 0)
                setElementData(player, "isWorking", false)
                return
            end
        end
    else
        outputChatBox("[ФЕРМА] Смена закончена.", player, 255, 100, 0)
    end
end
addEventHandler("onPickupHit", pick1, onFarmPickup)
addEventHandler("onPickupHit", pick2, onFarmPickup)

-- ЛОГИКА МАРКЕРОВ (ОСТАЕТСЯ ПРЕЖНЕЙ, НО С ПРОВЕРКОЙ VISIBLE)
addEventHandler("onMarkerHit", root, function(player)
    if getElementType(player) ~= "player" then return end
    if not isElementVisibleTo(source, player) then return end

    if source == m_f1_c1 or source == m_f1_c2 then
        setElementVisibleTo(source, player, false)
        setElementVisibleTo(m_f1_drop, player, true)
        outputChatBox("Ресурс взят! Неси на склад.", player, 0, 255, 0)
    elseif source == m_f2_c then
        setElementVisibleTo(m_f2_c, player, false)
        setElementVisibleTo(m_f2_drop, player, true)
        outputChatBox("Ресурс взят! Неси на склад.", player, 0, 255, 0)
    elseif source == m_f1_drop or source == m_f2_drop then
        -- ТУТ ТВОЙ КОД СДАЧИ (из предыдущего сообщения)
        -- ... (награда, опыт, новый круг) ...
    end
end)

-- УНИВЕРСАЛЬНАЯ ФУНКЦИЯ СДАЧИ (Работает для обоих полей)
function onFarmDrop(player)
    if getElementType(player) ~= "player" then return end
    
    -- ПРОВЕРКА: Видит ли игрок этот маркер (защита от сдачи в чужой маркер)
    if not isElementVisibleTo(source, player) then return end

    local isField2 = (source == m_f2_drop)
    local reward = isField2 and 8 or 5 -- На 2-м поле платят 8, на 1-м - 5
    local hp = getElementHealth(player)

    -- Проверка банка
    if (bankBalance or 0) >= reward then
        -- Экономика
        bankBalance = bankBalance - reward
        factoryStock = factoryStock + 1
        setElementData(resourceRoot, "factoryStock", factoryStock)
        setElementData(resourceRoot, "serverBank", bankBalance)
        givePlayerMoney(player, reward)
        
        -- Опыт и Ранги (общие для всех полей)
        local xp = (getElementData(player, "farm_xp") or 0) + 1
        local rank = getElementData(player, "rank") or 1
        setElementData(player, "farm_xp", xp)
        
        -- Повышение до 2 ранга (если накопил 50 опыта)
        if rank == 1 and xp >= 5 then
            setElementData(player, "rank", 2)
            -- Вызываем функцию из factions.lua для смены скина
            if type(checkGovPromotion) == "function" then checkGovPromotion(player) end 
            outputChatBox("ПОВЫШЕНИЕ! Теперь ты Опытный фермер (Ранг 2).", player, 0, 255, 0)
        end
        
        -- Дебафф здоровья и Бонус 2 ранга
        setElementHealth(player, hp - 1)
        if rank >= 2 and math.random(1, 5) == 1 then
            setElementHealth(player, math.min(100, getElementHealth(player) + 5))
            outputChatBox("Перекус на свежем воздухе придал сил! (+5 HP)", player, 0, 255, 0)
        end

        outputChatBox("Груз сдан! +$" .. reward .. " (Опыт: " .. xp .. ")", player, 0, 255, 0)

        -- НОВЫЙ КРУГ (Прячем текущий склад, показываем точку сбора)
        setElementVisibleTo(source, player, false) -- Прячем склад, в который только что зашли
        
        if isField2 then
            setElementVisibleTo(m_f2_c, player, true) -- Снова на сбор 2-й фермы
        else
            -- Снова на сбор 1-й фермы (случайный из двух)
            local r = math.random(1, 2)
            setElementVisibleTo(r == 1 and m_f1_c1 or m_f1_c2, player, true)
        end
    else
        outputChatBox("[ФЕРМА] В банке штата нет денег на оплату!", player, 255, 0, 0)
    end
end

-- Привязываем функцию к обоим маркерам сдачи
addEventHandler("onMarkerHit", m_f1_drop, onFarmDrop)
addEventHandler("onMarkerHit", m_f2_drop, onFarmDrop)
