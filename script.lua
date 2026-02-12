local x, y, z = 1354.8, 229.0, 19.6

-- Добавляем аргумент thePlayer
function spawnMe(thePlayer)
    -- Если функция вызвана событием (onPlayerJoin), то используем source
    -- Если командой (addCommandHandler), то используем thePlayer
    local target = thePlayer or source
    
    if isElement(target) then
        spawnPlayer(target, x, y, z, 0, 0)
        setCameraTarget(target, target)
        fadeCamera(target, true) -- Чтобы экран не был черным
        outputChatBox("Успешный спавн!", target, 0, 255, 0)
    end
end

addEventHandler("onPlayerJoin", root, spawnMe)
addCommandHandler("respawn", spawnMe)
function showMyPos(thePlayer)
    local x, y, z = getElementPosition(thePlayer)
    local _, _, r = getElementRotation(thePlayer)
    -- Вывод в чат с запятыми (удобно копировать в код)
    outputChatBox(string.format("Твои координаты: %.3f, %.3f, %.3f (Rot: %.1f)", x, y, z, r), thePlayer, 255, 255, 0)
    -- Вывод в консоль F8 (оттуда проще копировать мышкой)
    outputConsole(string.format("%.3f, %.3f, %.3f", x, y, z), thePlayer)
end
addCommandHandler("mypos", showMyPos)
