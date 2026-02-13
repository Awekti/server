-- Настройки "Голодной смерти"
local hungerInterval = 60000 -- Раз в 60 секунд (оптимально для хардкора)
local hungerDamage = 1       -- Сколько HP отнимать за один "тик"

-- Основной цикл голода
setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        -- Проверяем, что игрок жив и заспавнен
        if not isPedDead(player) then
            local currentHP = getElementHealth(player)
            
            -- Отнимаем здоровье (минимум до 0)
            local newHP = math.max(0, currentHP - hungerDamage)
            setElementHealth(player, newHP)
            
            -- Уведомление в чат, чтобы игрок не забыл, почему он умирает
            if newHP <= 20 then
                outputChatBox("[ГОЛОД] Вы при смерти!", player, 255, 0, 0)
            end
            
        end
    end
end, hungerInterval, 0)
