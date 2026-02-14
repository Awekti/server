-- data_manager.lua (Server-side)
bankBalance = 1000
factoryStock = 0
cafeStock = 0
detailsStock = 0
serviceStock = 0

-- Обновление всех 3D текстов одной функцией
function syncEconomyData()
    setElementData(resourceRoot, "serverBank", bankBalance)
    setElementData(resourceRoot, "factoryStock", factoryStock)
    setElementData(resourceRoot, "cafeStock", cafeStock)
    setElementData(resourceRoot, "detailsStock", detailsStock)
    setElementData(resourceRoot, "serviceStock", serviceStock)
end
