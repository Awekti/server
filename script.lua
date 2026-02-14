-- Оставляем только полезные утилиты
function showMyPos(thePlayer)
    local x, y, z = getElementPosition(thePlayer)
    local _, _, r = getElementRotation(thePlayer)
    outputChatBox(string.format("Твои координаты: %.3f, %.3f, %.3f (Rot: %.1f)", x, y, z, r), thePlayer, 255, 255, 0)
    outputConsole(string.format("%.3f, %.3f, %.3f", x, y, z), thePlayer)
end
addCommandHandler("mypos", showMyPos)

