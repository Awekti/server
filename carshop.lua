local shopPickup = createPickup(1228.406, 182.950, 20.219, 3, 1274) -- Иконка машины
local spawnPoints = {
    {1237.200, 179.346, 20.2, 270},
    {1219.043, 187.584, 20.2, 270}
}

-- Открываем меню игроку
addEventHandler("onPickupHit", shopPickup, function(player)
    if getElementType(player) == "player" and not isPedInVehicle(player) then
        triggerClientEvent(player, "openCarShop", player)
    end
end)

addEvent("onPlayerBuyCar", true)
addEventHandler("onPlayerBuyCar", root, function(model, price, partsNeeded)
    -- ПРОВЕРКА: Деньги у игрока И Запчасти на складе (в business.lua)
    if getPlayerMoney(client) >= price then
        if (detailsStock or 0) >= partsNeeded then
            
            -- ЭКОНОМИКА:
            takePlayerMoney(client, price)
            bankBalance = (bankBalance or 0) + price -- Деньги в банк
            detailsStock = detailsStock - partsNeeded -- Тратим детали со склада

            -- Обновляем данные для 3D текстов
            setElementData(resourceRoot, "serverBank", bankBalance)
            setElementData(resourceRoot, "detailsStock", detailsStock)
            
            -- СПАВН:
            local spawn = spawnPoints[math.random(#spawnPoints)]
            local veh = createVehicle(model, spawn[1], spawn[2], spawn[3], 0, 0, spawn[4] or 0)
warpPedIntoVehicle(client, veh)

            
            -- Помечаем авто как личное (чтобы не удалялось скриптом доставки)
            setElementData(veh, "isPersonal", true)
            setElementData(veh, "owner", client)
            
            outputChatBox("[АВТОСАЛОН] Поздравляем с покупкой! Машина собрана из запчастей склада.", client, 0, 255, 0)
        else
            outputChatBox("[АВТОСАЛОН] На складе недостаточно деталей для сборки авто!", client, 255, 50, 50)
        end
    else
        outputChatBox("[АВТОСАЛОН] У вас недостаточно денег!", client, 255, 0, 0)
    end
end)
