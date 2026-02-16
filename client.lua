-- =============================================================================
-- ИНТЕРФЕЙС КАФЕ (GUI)
-- =============================================================================
local screenW, screenH = guiGetScreenSize()
local menuWindow = guiCreateWindow((screenW - 300) / 2, (screenH - 200) / 2, 300, 200, "Меню Кафе", false)
local buyBurger = guiCreateButton(20, 40, 260, 40, "Купить Бургер ($50)", false, menuWindow)
local closeMenu = guiCreateButton(20, 140, 260, 40, "Закрыть", false, menuWindow)

guiSetVisible(menuWindow, false)

local function toggleCafeMenu(state)
    guiSetVisible(menuWindow, state)
    showCursor(state)
end

addEventHandler("onClientGUIClick", menuWindow, function()
    if source == closeMenu then
        toggleCafeMenu(false)
    elseif source == buyBurger then
        triggerServerEvent("onPlayerBuyFood", localPlayer, "burger", 50)
    end
end)

addEvent("openCafeMenu", true)
addEventHandler("openCafeMenu", root, function() toggleCafeMenu(true) end)

-- =============================================================================
-- ИНТЕРФЕЙС АВТОСАЛОНА (GUI)
-- =============================================================================
local shopPickupPos = {1228.406, 182.950, 20.219}
local shopPickupBlip = createBlip(1228.406, 182.950, 20.219, 55, 2, 255, 255, 255, 255, 0, 300)
local carShopWindow = guiCreateWindow((screenW - 300) / 2, (screenH - 250) / 2, 300, 250, "Автосалон Tampa", false)
guiSetVisible(carShopWindow, false)
local btnBuyTampa = guiCreateButton(20, 40, 260, 40, "Купить Tampa ($300 + 50 деталей)", false, carShopWindow)
local btnCloseShop = guiCreateButton(20, 180, 260, 40, "Закрыть", false, carShopWindow)

addEvent("openCarShop", true)
addEventHandler("openCarShop", root, function()
    guiSetVisible(carShopWindow, true)
    showCursor(true)
end)

addEventHandler("onClientGUIClick", root, function()
    if source == btnCloseShop then
        guiSetVisible(carShopWindow, false)
        showCursor(false)
    elseif source == btnBuyTampa then
        -- Отправляем запрос на покупку (модель 440, цена 500, запчастей 50)
        triggerServerEvent("onPlayerBuyCar", localPlayer, 549, 300, 50)
        guiSetVisible(carShopWindow, false)
        showCursor(false)
    end
end)

-- =============================================================================
-- БОЛЬНИЦА
-- =============================================================================
local hx, hy, hz = 1242.254, 328.090, 20.5
local hospitalBlip = createBlip(hx, hy, hz, 22, 2, 255, 255, 255, 255, 0, 300)

addEventHandler("onClientRender", root, function()
    local px, py, pz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(hx, hy, hz, px, py, pz) < 20 then
        local sx, sy = getScreenFromWorldPosition(hx, hy, hz)
        if sx and sy then
            dxDrawText("АПТЕЧНЫЙ ПУНКТ\nЛекарства от $50 до $300", sx, sy, sx, sy, tocolor(0, 255, 100, 255), 1.5, "default-bold", "center")

        end
    end
end)
-- =============================================================================

-- client.lua (Client-side)

addEventHandler("onClientRender", root, function()
    -- Проверяем, не скрыт ли интерфейс (например, кнопкой F11 или входом в интерьер)
    if isPlayerHudComponentVisible("health") then
        local hp = getElementHealth(localPlayer)
        -- Округляем до целого числа
        local hpText = tostring(math.floor(hp))
        
        -- Стандартные координаты полоски ХП в GTA SA (примерные для разных разрешений)
        -- В идеале это нужно вычислять через guiGetScreenSize, но для теста:
        local screenW, screenH = guiGetScreenSize()
        
        -- Позиция текста (подбираем под полоску справа вверху)
        local x = screenW * 0.815 -- Смещение по горизонтали
        local y = screenH * 0.065 -- Смещение по вертикали (чуть выше брони)

        -- Рисуем тень для читаемости
        dxDrawText(hpText, x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, 255), 1.5, "default-bold", "left", "top")
        -- Рисуем само число (белым или красным)
        local color = tocolor(255, 255, 255, 255)
        if hp <= 20 then color = tocolor(255, 0, 0, 255) end -- Краснеет при низком ХП

        dxDrawText(hpText, x, y, x, y, color, 1.5, "default-bold", "left", "top")
    end
end)



-- =============================================================================
-- 3D ТЕКСТЫ (Оптимизированный рендер)
-- =============================================================================

-- Конфиг точек: {x, y, z, текст, данные_из_БД, цвет, дистанция}
local LABEL_POINTS = {
    {1344.622, 282.463, 20.8, "БАНК ШТАТА\nЖертва за $10", "serverBank", tocolor(255, 50, 50, 255), 20},
    {-1.442, 74.723, 4.0, "СКЛАД ЗАВОДА", "factoryStock", tocolor(100, 200, 255, 255), 15},
    {1366.39, 248.8, 21.5, "ПРОДУКТОВ В КАФЕ", "cafeStock", tocolor(255, 255, 0, 255), 20},
    {1348.015, 342.812, 21.5, "СКЛАД ДЕТАЛЕЙ", "detailsStock", tocolor(100, 200, 255, 255), 20}
}

addEventHandler("onClientRender", root, function()
    local px, py, pz = getElementPosition(localPlayer)
    
    for _, pt in ipairs(LABEL_POINTS) do
        local dist = getDistanceBetweenPoints3D(pt[1], pt[2], pt[3], px, py, pz)
        
        if dist < pt[7] then
            local sx, sy = getScreenFromWorldPosition(pt[1], pt[2], pt[3])
            if sx and sy then
                -- Динамически подтягиваем данные (число) из ElementData
                local val = getElementData(resourceRoot, pt[5]) or 0
                local finalText = pt[4] .. ": " .. val
                
                -- Тень
                dxDrawText(finalText, sx + 1, sy + 1, sx, sy, tocolor(0, 0, 0, 200), 1.2, "default-bold", "center")
                -- Основной текст
                dxDrawText(finalText, sx, sy, sx, sy, pt[6], 1.2, "default-bold", "center")
            end
        end
    end
end)

--================ФЕРМА РАНГИ====================================
addEventHandler("onClientRender", root, function()
    local faction = getElementData(localPlayer, "faction")
    
    -- Для ФЕРМЕРА
    if faction == "Farmer" and getElementData(localPlayer, "isWorking") then
        local xp = getElementData(localPlayer, "farm_xp") or 0
        local rank = getElementData(localPlayer, "rank") or 1
        local goal = (rank == 1) and 5 or 150
        drawJobHud("ФЕРМА", rank, xp, goal)
        
    -- Для ПОЛИЦИИ
    elseif faction == "Police" then
        local xp = getElementData(localPlayer, "police_xp") or 0
        local rank = getElementData(localPlayer, "rank") or 1
        local goal = (rank == 1) and 10 or (rank == 2) and 25 or 50
        drawJobHud("ПОЛИЦИЯ", rank, xp, goal)
    end
end)

-- Вспомогательная функция отрисовки (чтобы не дублировать код)
function drawJobHud(name, rank, xp, goal)
    local screenW, screenH = guiGetScreenSize()
    local x, y = screenW * 0.7, screenH * 0.2
    local progress = math.min(100, (xp / goal) * 100)
    
    dxDrawRectangle(x, y, 200, 65, tocolor(0, 0, 0, 150))
    dxDrawText(name .. " (Ранг " .. rank .. ")", x + 10, y + 5, 0, 0, tocolor(255, 255, 255, 255), 1.1, "default-bold")
    dxDrawText("Прогресс: " .. xp .. " / " .. goal, x + 10, y + 25, 0, 0, tocolor(255, 255, 0, 255), 1.0, "default")
    dxDrawRectangle(x + 10, y + 45, 180, 8, tocolor(50, 50, 50, 255))
    dxDrawRectangle(x + 10, y + 45, 1.8 * progress, 8, tocolor(0, 255, 0, 255))
end






