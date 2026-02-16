cafeStock = 50
bankBalance = 1000
detailsStock = 50
serviceStock = 50

setElementData(resourceRoot, "cafeStock", cafeStock)
setElementData(resourceRoot, "sparePartsStock", sparePartsStock)
setElementData(resourceRoot, "serviceStock", serviceStock)
setElementData(resourceRoot, "detailsStock", detailsStock or 0)

-- Функция: Проверка баланса банка (команда /bank)
addCommandHandler("bank", function(player)
    outputChatBox("Текущий баланс банка штата: $" .. bankBalance, player, 255, 200, 0)
end)

-------------КАФЕШКА------------------------------------------------------
local m1x, m1y, m1z = 1366.39, 248.8, 18.5
local marker1 = createMarker(m1x, m1y, m1z, "cylinder", 1.5, 255, 255, 0, 150)
local foodBlip = createBlip(m1x, m1y, m1z, 29, 2, 255, 255, 255, 255, 0, 300)

addEvent("onPlayerBuyFood", true)
addEventHandler("onPlayerBuyFood", root, function(item, price)
    if cafeStock >= 1 then
        if getPlayerMoney(client) >= price then
            cafeStock = cafeStock - 1
            setElementData(resourceRoot, "cafeStock", cafeStock)
    
            takePlayerMoney(client, price) -- Забираем у игрока
            bankBalance = bankBalance + price -- КЛАДЕМ В БАНК
            setElementData(resourceRoot, "serverBank", bankBalance)
        
            setElementHealth(client, getElementHealth(client) + 30)
            if math.random(1, 100) <= 5 then -- шанс отравиться
    -- ПРОВЕРКА: Если игрок уже болен (любой болезнью), новое отравление не даем
    if not getElementData(client, "disease") then
        setElementData(client, "disease", "Poison")
        outputChatBox("Кажется, бургер был несвежим... Вы отравились!", client, 255, 0, 0)
    end
end
            outputChatBox("Приятного аппетита! В кафе осталось " .. cafeStock .. " порций.", client, 0, 255, 0)
            outputChatBox("Вы поели. $" .. price .. " ушли в бюджет банка.", client, 0, 255, 0)
        else
            outputChatBox("У вас нет денег!", client, 255, 0, 0)
        end
    else
        outputChatBox("[КАФЕ] Еда закончилась! Ждем доставку продуктов.", client, 255, 50, 50)
    end
end)

addEventHandler("onMarkerHit", marker1, function(player)
    if getElementType(player) == "player" then
        triggerClientEvent(player, "openCafeMenu", player)
    end
end)

local cx, cy, cz = 1366.39, 248.8, 20.5 
addEventHandler("onClientRender", root, function()
    -- (твой старый код отрисовки банка и склада завода)
    
    local px, py, pz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz) < 15 then
        local stock = getElementData(resourceRoot, "cafeStock") or 0
        local sx, sy = getScreenFromWorldPosition(cx, cy, cz)
        if sx and sy then
            dxDrawText("ПРОДУКТОВ В КАФЕ: " .. stock, sx, sy, sx, sy, tocolor(255, 255, 0, 255), 1.2, "default-bold", "center")
        end
    end
end)


-------------24/7--------------------------------------------------------
local m2x, m2y, m2z = 1360.396, 207.244, 18.5
local marker2 = createMarker(m2x, m2y, m2z, "cylinder", 1.5, 0, 255, 255, 150) -- Сделал его бирюзовым для отличия

-- Общая функция для проверки работы
function onMarkerHit(player)
    if getElementType(player) == "player" then
        -- Проверяем, на какой именно маркер наступили
        if source == marker1 then
            outputChatBox("Ты на первом маркере (желтом)!", player, 255, 255, 0)
        elseif source == marker2 then
            outputChatBox("Система работает! Ты на втором маркере (бирюзовом).", player, 0, 255, 255)
        end
    end
end

--------------------РАБОТА---------------------------------------------
-- КРАСНЫЙ-------------------------------------------------------------
local m3x, m3y, m3z = 1344.622, 282.463, 18.5
local sacrificeMarker = createMarker(m3x, m3y, m3z, "cylinder", 1.5, 255, 0, 0, 150)

function sacrificeHealthForCash(player)
    if getElementType(player) == "player" then
        local currentHP = getElementHealth(player)
        
        -- Проверка: если HP больше 5, совершаем сделку
        if currentHP > 5 then
            givePlayerMoney(player, 10)
            setElementHealth(player, currentHP - 5)
            outputChatBox("Кровь в обмен на деньги! +$10 (-5 HP)", player, 255, 50, 50)
        else
            outputChatBox("Ты слишком слаб для такой жертвы...", player, 255, 0, 0)
        end
    end
end
addEventHandler("onMarkerHit", sacrificeMarker, function(player)
    if getElementType(player) == "player" then
        local pHP = getElementHealth(player)
        local payout = 10
        
        if bankBalance >= payout then
            if pHP > 5 then
                bankBalance = bankBalance - payout -- ЗАБИРАЕМ ИЗ БАНКА
                detailsStock = detailsStock + 1 -- ПРОИЗВОДИМ ДЕТАЛЬ
                setElementData(resourceRoot, "detailsStock", detailsStock)
                givePlayerMoney(player, payout) -- Даем игроку
                setElementData(resourceRoot, "serverBank", bankBalance)
                setElementHealth(player, pHP - 5)
                outputChatBox("[ЦЕХ] Ты произвел деталь! +$10. Всего на складе: " .. detailsStock, player, 255, 50, 50)
            else
                outputChatBox("[ЦЕХ] Ты слишком слаб для работы!", player, 255, 0, 0)
            end
        else
            outputChatBox("[ЦЕХ] В банке нет денег на оплату!", player, 255, 0, 0)
        end
    end
end)
--=========================================================================
-------------------------БОЛЬНИЦА------------------------------------------
local hx, hy, hz = 1242.254, 328.090, 18.8 
local hospitalMarker = createMarker(hx, hy, hz, "cylinder", 2.0, 200, 255, 200, 150)

local medicalPrices = {
    ["Flu"] = 50,      -- Простуда (дешево)
    ["Poison"] = 150,  -- Отравление (средне)
    ["Anemia"] = 300   -- Анемия (дорого, так как это сложный дебафф)
}

function autoCure(player)
    if getElementType(player) == "player" and not isPedInVehicle(player) then
        local disease = getElementData(player, "disease")
        
        -- Проверяем, болен ли игрок чем-то из нашего списка
        if disease and medicalPrices[disease] then
            local price = medicalPrices[disease]
            local diseaseName = (disease == "Flu" and "Простуда") or (disease == "Poison" and "Отравление") or "Анемия"
            
            -- Проверяем деньги у игрока
            if getPlayerMoney(player) >= price then
                -- ЭКОНОМИКА
                takePlayerMoney(player, price)
                bankBalance = (bankBalance or 0) + price
                setElementData(resourceRoot, "serverBank", bankBalance)
                
                -- ЛЕЧЕНИЕ: Снимаем только статус болезни
                setElementData(player, "disease", false)
                
                outputChatBox("[АПТЕКА] Вы купили лекарство от болезни: " .. diseaseName, player, 0, 255, 0)
                outputChatBox("Стоимость: $" .. price .. ". Деньги ушли в бюджет штата.", player, 200, 255, 200)
                outputChatBox("Не забудьте восстановить ХП в Кафе!", player, 255, 200, 0)
            else
                outputChatBox("[АПТЕКА] Лекарство от " .. diseaseName .. " стоит $" .. price .. ". У вас не хватает денег!", player, 255, 0, 0)
            end
        else
            outputChatBox("[АПТЕКА] Вы здоровы! Лекарства не требуются.", player, 0, 255, 255)
        end
    end
end

addEventHandler("onMarkerHit", hospitalMarker, autoCure)



-- Координаты для текста над красным маркером
local tx, ty, tz = 1344.622, 282.463, 20.5 

function updateBankLabels()
    -- Создаем или обновляем 3D текст (используем ElementData, чтобы клиент его рисовал)
    -- Но так как мы пока без сложного GUI, давай просто выводить инфу в зону стрима
    for _, player in ipairs(getElementsByType("player")) do
        -- Дистанция до маркера
        local px, py, pz = getElementPosition(player)
        if getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz) < 20 then
            -- Если игрок рядом, можно слать ему сообщение или юзать dxDraw (но это клиент)
        end
    end
end

-- Давай лучше сделаем простую команду /state для всех
addCommandHandler("state", function(player)
    outputChatBox("--- ОТЧЕТ КАЗНЫ ШТАТА ---", player, 0, 255, 0)
    outputChatBox("Доступно в банке: $" .. bankBalance, player, 255, 255, 255)
    
    local houseCount = 0
    for _, h in ipairs(getElementsByType("pickup")) do
        if getElementData(h, "owner") then houseCount = houseCount + 1 end
    end
    
    outputChatBox("Куплено домов: " .. houseCount, player, 255, 255, 255)
    outputChatBox("--------------------------", player, 0, 255, 0)
end)



-- Привязываем оба маркера к одной функции
--addEventHandler("onMarkerHit", marker1, onMarkerHit)
addEventHandler("onMarkerHit", marker2, onMarkerHit)
