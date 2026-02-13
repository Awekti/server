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


