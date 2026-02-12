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
