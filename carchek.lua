-- Координаты большого маркера (Z чуть ниже для земли)
local ax, ay, az = 1383.985, 461.518, 18.5 

-- Создаем большой маркер (размер 4.0, цвет синий)
local carMarker = createMarker(ax, ay, az, "cylinder", 4.0, 0, 100, 255, 150)

function onCarMarkerHit(element)
    -- Проверяем, что в маркер заехал именно транспорт
    if getElementType(element) == "vehicle" then
        -- Получаем водителя
        local driver = getVehicleController(element)
        
        if driver then
            local repairCost = 50
            
            -- Проверяем деньги у водителя
            if getPlayerMoney(driver) >= repairCost then
                takePlayerMoney(driver, repairCost)
                
                -- ПОПОЛНЯЕМ БАНК ШТАТА (живая экономика!)
                bankBalance = bankBalance + repairCost
                setElementData(resourceRoot, "serverBank", bankBalance)
                
                -- Чиним машину
                fixVehicle(element)
                
                outputChatBox("[АВТОСЕРВИС] Машина починена! $50 ушли в банк штата.", driver, 0, 255, 0)
                outputChatBox("Баланс банка: $" .. bankBalance, driver, 255, 200, 0)
            else
                outputChatBox("[АВТОСЕРВИС] Нужно $50 для починки!", driver, 255, 0, 0)
            end
        end
    elseif getElementType(element) == "player" then
        outputChatBox("Сюда нужно заезжать на машине!", element, 255, 255, 0)
    end
end

addEventHandler("onMarkerHit", carMarker, onCarMarkerHit)
