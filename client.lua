-- client.lua
local screenW, screenH = guiGetScreenSize()
local menuWindow = guiCreateWindow((screenW - 300) / 2, (screenH - 200) / 2, 300, 200, "Меню Кафе", false)
guiSetVisible(menuWindow, false) -- Скрываем при старте

-- Кнопки еды
local buyBurger = guiCreateButton(20, 40, 260, 40, "Купить Бургер ($50)", false, menuWindow)
local closeMenu = guiCreateButton(20, 140, 260, 40, "Закрыть", false, menuWindow)

-- Функция открытия
function toggleCafeMenu(state)
    guiSetVisible(menuWindow, state)
    showCursor(state) -- Показываем/скрываем мышку
end

-- Обработка нажатия кнопок
addEventHandler("onClientGUIClick", root, function()
    if source == closeMenu then
        toggleCafeMenu(false)
    elseif source == buyBurger then
        -- Отправляем запрос на сервер, чтобы списать деньги (клиент сам не может менять деньги!)
        triggerServerEvent("onPlayerBuyFood", localPlayer, "burger", 50)
    end
end)

-- Слушаем сигнал от сервера, чтобы открыть меню
addEvent("openCafeMenu", true)
addEventHandler("openCafeMenu", root, function()
    toggleCafeMenu(true)
end)

-- Координаты красного маркера (подними Z повыше, чтобы текст был над головой)
local tx, ty, tz = 1344.622, 282.463, 20.8 

addEventHandler("onClientRender", root, function()
    local px, py, pz = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)

    -- Рисуем текст только если игрок ближе 20 метров
    if distance < 20 then
        -- Получаем текущий баланс из данных сервера
        local currentBank = getElementData(resourceRoot, "serverBank") or 0
        
        -- Конвертируем 3D координаты в 2D на экране
        local sx, sy = getScreenFromWorldPosition(tx, ty, tz)
        
        if sx and sy then
            local text = "БАНК ШТАТА: $" .. currentBank .. "\nПожертвуй здоровьем за $10"
            -- Рисуем тень (черный текст)
            dxDrawText(text, sx + 2, sy + 2, sx, sy, tocolor(0, 0, 0, 255), 1.5, "default-bold", "center")
            -- Рисуем основной текст (красно-белый)
            dxDrawText(text, sx, sy, sx, sy, tocolor(255, 50, 50, 255), 1.5, "default-bold", "center")
        end
    end
end)

-- Текст над складом завода
local fx, fy, fz = -1.442, 74.723, 4.0 

addEventHandler("onClientRender", root, function()
    local px, py, pz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(fx, fy, fz, px, py, pz) < 15 then
        local stock = getElementData(resourceRoot, "factoryStock") or 0
        local sx, sy = getScreenFromWorldPosition(fx, fy, fz)
        if sx and sy then
            dxDrawText("СКЛАД ЗАВОДА\nРесурсов: " .. stock, sx, sy, sx, sy, tocolor(100, 200, 255, 255), 1.2, "default-bold", "center")
        end
    end
end)

-- ТЕКСТ НАД КАФЕШКОЙ
local cx, cy, cz = 1366.39, 248.8, 21.5 -- Подняли Z для видимости

addEventHandler("onClientRender", root, function()
    local px, py, pz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz) < 20 then
        -- Берем данные из resourceRoot
        local stock = getElementData(resourceRoot, "cafeStock") or 0
        local sx, sy = getScreenFromWorldPosition(cx, cy, cz)
        
        if sx and sy then
            dxDrawText("ПРОДУКТОВ: " .. stock, sx, sy, sx, sy, tocolor(255, 255, 0, 255), 1.5, "default-bold", "center")
        end
    end
end)

