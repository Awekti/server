-- work_factory.lua (Server-side)

factoryStock = 0 -- Общий склад ресурсов штата

local cargoPoints = {
    {13.132, 74.044, 2.1},
    {13.541, 63.487, 2.1}
}
local dropX, dropY, dropZ = -1.442, 74.723, 2.1

local factoryStartPickup = createPickup(-4.467, 67.347, 3.117, 3, 1275)

cargoMarker1 = createMarker(cargoPoints[1][1], cargoPoints[1][2], cargoPoints[1][3], "cylinder", 1.5, 255, 255, 0, 150)
cargoMarker2 = createMarker(cargoPoints[2][1], cargoPoints[2][2], cargoPoints[2][3], "cylinder", 1.5, 255, 255, 0, 150)
dropMarker = createMarker(dropX, dropY, dropZ, "cylinder", 1.5, 0, 255, 0, 150)

setElementVisibleTo(cargoMarker1, root, false)
setElementVisibleTo(cargoMarker2, root, false)
setElementVisibleTo(dropMarker, root, false)

addEventHandler("onPickupHit", factoryStartPickup, function(player)
    if getElementType(player) == "player" and not isPedInVehicle(player) then
        
        -- Проверяем: если игрок УЖЕ работает, то УВОЛЬНЯЕМ его
        if getElementData(player, "isFactoryWorker") then
            setElementData(player, "isFactoryWorker", false)
            
            -- Скрываем абсолютно все маркеры завода для этого игрока
            setElementVisibleTo(cargoMarker1, player, false)
            setElementVisibleTo(cargoMarker2, player, false)
            setElementVisibleTo(dropMarker, player, false)
            
            outputChatBox("[ЗАВОД] Ты закончил смену. Маркеры убраны.", player, 255, 100, 0)
        
        else
            -- Если НЕ работает — УСТРАИВАЕМ
            setElementData(player, "isFactoryWorker", true)
            
            -- Показываем один из случайных начальных маркеров
            local rand = math.random(1, 2)
            if rand == 1 then
                setElementVisibleTo(cargoMarker1, player, true)
            else
                setElementVisibleTo(cargoMarker2, player, true)
            end
            
            outputChatBox("[ЗАВОД] Смена начата! Иди к желтому маркеру.", player, 255, 255, 0)
        end
    end
end)

function onCargoHit(player)
    if getElementType(player) == "player" and isElementVisibleTo(source, player) then
        setElementVisibleTo(cargoMarker1, player, false)
        setElementVisibleTo(cargoMarker2, player, false)
        setElementVisibleTo(dropMarker, player, true)
        outputChatBox("[ЗАВОД] Деталь получена! Неси на склад.", player, 0, 255, 0)
    end
end
addEventHandler("onMarkerHit", cargoMarker1, onCargoHit)
addEventHandler("onMarkerHit", cargoMarker2, onCargoHit)

addEventHandler("onMarkerHit", dropMarker, function(player)
    if getElementType(player) == "player" and isElementVisibleTo(source, player) then
        local reward = 5
        local pHP = getElementHealth(player)

        if bankBalance >= reward then
            if pHP > 1 then
                -- ЭКОНОМИКА
                bankBalance = bankBalance - reward
                factoryStock = factoryStock + 1 -- ПОПОЛНЯЕМ СКЛАД

                setElementData(resourceRoot, "factoryStock", factoryStock)
                givePlayerMoney(player, reward)
                setElementHealth(player, pHP - 1) -- МИНУС 1 HP
                
                outputChatBox("[ЗАВОД] +1 деталь на склад! Получено: $" .. reward .. " (-1 HP)", player, 0, 255, 0)
                outputChatBox("[СКЛАД] Всего ресурсов: " .. factoryStock, player, 200, 200, 255)

                -- Цикл продолжается
                setElementVisibleTo(dropMarker, player, false)
                local rand = math.random(1, 2)
                setElementVisibleTo(rand == 1 and cargoMarker1 or cargoMarker2, player, true)
            else
                outputChatBox("[ЗАВОД] Ты слишком истощен для работы!", player, 255, 0, 0)
            end
        else
            outputChatBox("[ЗАВОД] В банке нет денег на оплату труда!", player, 255, 0, 0)
        end
    end
end)
