-- Координаты (Z поднял до 19.0, чтобы маркер не проваливался под текстуры)
local ax, ay, az = 1383.985, 461.518, 19.0 

-- Создаем маркер
local carMarker = createMarker(ax, ay, az, "cylinder", 4.0, 0, 100, 255, 150)

function onCarMarkerHit(element)
    -- УДАЛИЛ addEventHandler отсюда! Он должен быть только один раз в конце файла.

    -- Проверяем, что заехал транспорт
    if getElementType(element) == "vehicle" then
        -- Получаем водителя
        local driver = getVehicleController(element)
        
        if driver then
            -- Проверка наличия запчастей (защита от nil через or 0)
            if (serviceStock or 0) >= 1 then
                local repairCost = 50
                
                -- Проверяем деньги у водителя
                if getPlayerMoney(driver) >= repairCost then
                    -- Списываем запчасть
                    serviceStock = serviceStock - 1
                    setElementData(resourceRoot, "serviceStock", serviceStock)

                    -- Деньги
                    takePlayerMoney(driver, repairCost)
                    bankBalance = (bankBalance or 0) + repairCost
                    setElementData(resourceRoot, "serverBank", bankBalance)
                    
                    -- ЧИНКА
                    fixVehicle(element)
                    
                    outputChatBox("[АВТОСЕРВИС] Машина починена! Осталось запчастей: " .. serviceStock, driver, 0, 255, 0)
                else
                    outputChatBox("[АВТОСЕРВИС] Нужно $50 для починки!", driver, 255, 0, 0)
                end
            else
                outputChatBox("[СЕРВИС] Нет запчастей! Нужно привезти их из Цеха.", driver, 255, 50, 50)
            end
        end
    end
end

-- Этот обработчик должен стоять ВНЕ функции и только ОДИН раз
addEventHandler("onMarkerHit", carMarker, onCarMarkerHit)

