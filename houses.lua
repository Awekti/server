-- Список домов: {x, y, z, название}
local housesData = {
    {1414.810, 323.294, 18.3, "Дом на холме"},
    {1435.895, 334.045, 18.3, "Коттедж у дороги"},
    {1402.100, 333.344, 18.3, "Гостевой домик"}
}

local buyPrice = 100 -- Цена покупки
local taxRate = 10   -- Налог каждые 2 мин
local healAmount = 5 -- Реген каждые 2 мин

for i, pos in ipairs(housesData) do
    -- Создаем пикап дома (модель 1273 - зеленый домик)
    local house = createPickup(pos[1], pos[2], pos[3], 3, 1273)
    setElementData(house, "owner", false) -- Изначально владельца нет
    setElementData(house, "houseName", pos[4])

    -- Обработка покупки при наезде
    addEventHandler("onPickupHit", house, function(player)
        if getElementType(player) ~= "player" then return end
        
        local owner = getElementData(source, "owner")
        local hName = getElementData(source, "houseName")

        if not owner then
            -- Если дом ничей, предлагаем купить
            if getPlayerMoney(player) >= buyPrice then
                takePlayerMoney(player, buyPrice)
                bankBalance = bankBalance + buyPrice 
                setElementData(source, "owner", player) -- Записываем игрока как владельца
                setElementData(resourceRoot, "serverBank", bankBalance)
                outputChatBox("Поздравляем! Вы купили '" .. hName .. "' за $" .. buyPrice, player, 0, 255, 0)
                outputChatBox("Деньги за покупку ушли в бюджет штата. Баланс банка: $" .. bankBalance, player, 255, 200, 0)
                -- Меняем модель на синий домик (купленный), если хочешь:
                --setElementModel(source, 1272) 
            else
                outputChatBox("Этот дом стоит $" .. buyPrice .. ". У вас не хватает денег!", player, 255, 0, 0)
            end
        else
            -- Если у дома есть владелец
            if owner == player then
                outputChatBox("Это ваш дом: " .. hName, player, 0, 255, 255)
            else
                outputChatBox("Этот дом принадлежит: " .. getPlayerName(owner), player, 255, 150, 0)
            end
        end
    end)
end

--------------------------- ТАЙМЕР: Раз в 2 минуты (120 000 мс)--------------------------------
setTimer(function()
    -- Проходим по всем пикапам в игре
    for _, house in ipairs(getElementsByType("pickup")) do
        local owner = getElementData(house, "owner")
        
        -- Если у дома есть владелец и он на сервере
        if owner and isElement(owner) then
            -- 1. Снимаем налог
            if getPlayerMoney(owner) >= taxRate then
                takePlayerMoney(owner, taxRate)
                setElementData(resourceRoot, "serverBank", bankBalance)
                outputChatBox("[Дом] Списан налог: $" .. taxRate, owner, 255, 200, 0)
            else
                -- Если денег на налог нет, можно отобрать дом:
                setElementData(house, "owner", false)
                outputChatBox("[Дом] Вы выселены за неуплату налогов!", owner, 255, 0, 0)
            end
            bankBalance = bankBalance + taxRate
            
            -- 2. Восстанавливаем HP
            local hp = getElementHealth(owner)
            if hp < 100 then
                setElementHealth(owner, math.min(100, hp + healAmount))
                outputChatBox("[Дом] Здоровье восстановлено: +" .. healAmount .. " HP", owner, 0, 255, 0)
            end
        end
    end
end, 120000, 0) -- 0 означает бесконечный повтор
