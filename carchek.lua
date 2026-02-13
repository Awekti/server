-- Координаты большого маркера (Z чуть ниже для земли)
local ax, ay, az = 1383.985, 461.518, 18.5 

-- Создаем большой маркер (размер 4.0, цвет синий)
local carMarker = createMarker(ax, ay, az, "cylinder", 4.0, 0, 100, 255, 150)

function onCarMarkerHit(element)
    addEventHandler("onMarkerHit", carMarker, onCarMarkerHit)
    -- Проверяем, что в маркер заехал именно транспорт
    if getElementType(element) == "vehicle" then
        -- Получаем водителя
        local driver = getVehicleController(element)
        
        if driver then
            if serviceStock >= 1 then
            local repairCost = 50
            
            -- Проверяем деньги у водителя
            if getPlayerMoney(driver) >= repairCost then
                serviceStock = serviceStock - 1
                setElementData(resourceRoot, "serviceStock", serviceStock)

                takePlayerMoney(driver, repairCost)
                bankBalance = bankBalance + repairCost
                setElementData(resourceRoot, "serverBank", bankBalance)
                
                -- Чиним машину
                fixVehicle(element)
                
                outputChatBox("[АВТОСЕРВИС] Машина починена! Осталось запчастей: " .. serviceStock, driver, 0, 255, 0)
            else
                outputChatBox("[АВТОСЕРВИС] Нужно $50 для починки!", driver, 255, 0, 0)
           end
            else
                outputChatBox("[СЕРВИС] Нет запчастей! Дождитесь доставку из цеха.", driver, 255, 50, 50)
            end
        end
    end
end

addEventHandler("onMarkerHit", carMarker, onCarMarkerHit)
