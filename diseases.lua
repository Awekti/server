-- diseases.lua (Server-side)

local fluChance = 5    -- Простуда (5%)
local anemiaChance = 1 -- Анемия (90% для теста)

-- 1. Таймер НАЗНАЧЕНИЯ болезни (раз в минуту)
setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        -- Условие: не мертв И статус болезни пустой (false или nil)
        if not isPedDead(player) and not getElementData(player, "disease") then
            local rand = math.random(1, 100)
            if rand <= fluChance then
                setElementData(player, "disease", "Flu")
                outputChatBox("⚠️ [ЗДОРОВЬЕ] Вы подхватили Простуду!", player, 255, 100, 100)
            elseif rand <= (fluChance + anemiaChance) then
                setElementData(player, "disease", "Anemia")
                outputChatBox("⚠️ [ЗДОРОВЬЕ] У вас Анемия! Сил стало меньше.", player, 255, 100, 100)
            end
        end
    end
end, 60000, 0)

-- 2. Таймер СИМПТОМОВ (урон и эффекты раз в 30 сек)
setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        local d = getElementData(player, "disease")
        
        -- Если игрок болен и жив
        if d and not isPedDead(player) then
            local hp = getElementHealth(player)
            
            if d == "Flu" then
                setElementHealth(player, math.max(1, hp - 2))
                outputChatBox("🤢 Вы кашляете... (-2 HP)", player, 255, 150, 150)
                setPedAnimation(player, "FOOD", "EAT_Burger", 3000, false, true, false, false)
            --setPedAnimation(player, "Блок", "Анимация", время_мс, цикл, перемещение, прерываемость, заморозка)

            elseif d == "Poison" then
                setElementHealth(player, math.max(1, hp - 5))
                outputChatBox("🤢 Вас тошнит после еды... (-5 HP)", player, 255, 0, 0)
                setPedAnimation(player, "FOOD", "EAT_Burger", 3000, false, true, false, false)

            elseif d == "Anemia" then
                if hp > 50 then 
                    setElementHealth(player, 50) 
                    outputChatBox("🩸 Анемия ограничивает ваше здоровье! (Макс. 50 HP)", player, 255, 50, 50)
                end
            end
        end
    end
end, 30000, 0)

-- Лог для консоли (F8)
addEventHandler("onElementDataChange", root, function(dataName, oldValue, newValue)
    if dataName == "disease" then
        local name = getPlayerName(source) or "Unknown"
        iprint("БОЛЕЗНЬ: " .. name .. " [" .. tostring(oldValue) .. " -> " .. tostring(newValue) .. "]")
    end

    -- diseases.lua (Server-side)

setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        -- Если болеет анемией
        if getElementData(player, "disease") == "Anemia" then
            local currentHP = getElementHealth(player)
            
            -- Если ХП стало выше 50 (поел, полечился или реген)
            if currentHP > 50 then
                setElementHealth(player, 50) -- Мгновенно срезаем до 50
                
                -- Анти-спам: пишем в чат не чаще чем раз в 10 секунд
                local lastMsg = getElementData(player, "lastAnemiaMsg") or 0
                local now = getTickCount()
                
                if now - lastMsg > 10000 then 
                    outputChatBox("🩸 [АНИМИЯ] Ваше тело слишком слабо! Здоровье не может подняться выше 50.", player, 255, 50, 50)
                    setElementData(player, "lastAnemiaMsg", now, false) -- false, чтобы не синхронизировать с клиентом
                end
            end
        end
    end
end, 500, 0)
end)


