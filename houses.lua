-- Список домов: {x, y, z, название}
local housesData = {
    {1414.810, 323.294, 18.3, "Дом на холме", 100},
    {1435.895, 334.045, 18.3, "Коттедж у дороги", 100},
    {1402.100, 333.344, 18.3, "Гостевой домик", 100},
    {1294.479, 174.883, 20.911, "Элитная вилла", 100},
    {1303.167, 187.008, 20.461, "Купил и живу", 100},
    {1284.181, 158.743, 20.793, "Устранение", 100},
    {1301.273, 192.244, 20.461, "Трусцовый лагерь", 100},
    {253.261, -22.447, 1.624, "Железная капуста", 100},
    {248.131, -33.181, 1.578, "Мрачный подоконник", 100},
    {271.686, -48.758, 2.777, "Гордый линолеум", 100},
    {295.074, -54.582, 2.777, "Интригующая форточка", 100},
    {252.804, -92.401, 3.535, "Случайный фундамент", 100},
    {252.526, -121.340, 3.535, "Задумчивый балкон", 100},
    {313.299, -92.414, 3.535, "Пожилой домофон", 100},
    {312.953, -121.274, 3.535, "Важный чердак", 100},
    {285.961, 41.313, 2.548, "Стеснительная многоэтажка", 100},
    {309.187, 44.229, 3.088, "Обиженный кирпич", 100},
    {267.446, -54.817, 2.777, "Тревожный подъезд", 100} -- Пример добавления нового
}

local taxRate = 10   -- Налог каждые 2 мин
local healAmount = 5 -- Реген каждые 2 мин

for i, pos in ipairs(housesData) do
    -- Создаем пикап дома (модель 1273 - зеленый домик)
    local house = createPickup(pos[1], pos[2], pos[3], 3, 1273)
    setElementData(house, "owner", false) -- Изначально владельца нет
    setElementData(house, "houseName", pos[4])
    setElementData(house, "buyPrice", pos[5])

    -- Обработка покупки при наезде
    addEventHandler("onPickupHit", house, function(player)
        if getElementType(player) ~= "player" then return end
        
        local owner = getElementData(source, "owner")
        local hName = getElementData(source, "houseName")
        local buyPrice = getElementData(source, "buyPrice")

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
    for _, house in ipairs(getElementsByType("pickup")) do
        local owner = getElementData(house, "owner")
        
        if owner and isElement(owner) then
            -- 1. Снимаем налог
            if getPlayerMoney(owner) >= taxRate then
                takePlayerMoney(owner, taxRate)
                
                -- ПЕРЕНЕСЛИ СЮДА: Деньги в банк попадают только если они списаны у игрока
                bankBalance = (bankBalance or 0) + taxRate
                setElementData(resourceRoot, "serverBank", bankBalance)
                
                outputChatBox("[Дом] Списан налог: $" .. taxRate, owner, 255, 200, 0)
                
                -- 2. Восстанавливаем HP (только если налог ОПЛАЧЕН)
                local hp = getElementHealth(owner)
                if hp < 100 then
                    setElementHealth(owner, math.min(100, hp + healAmount))
                    outputChatBox("[Дом] Здоровье восстановлено: +" .. healAmount .. " HP", owner, 0, 255, 0)
                end
            else
                -- Если денег на налог нет
                setElementData(house, "owner", false)
                outputChatBox("[Дом] Вы выселены за неуплату налогов!", owner, 255, 0, 0)
                -- Здесь bankBalance НЕ увеличивается
            end
        end
    end
end, 120000, 0)
 -- 0 означает бесконечный повтор
