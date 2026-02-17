bankBalance = 1000
factoryStock = 50
cafeStock = 50
detailsStock = 50
serviceStock = 50

-- Обновление всех 3D текстов одной функцией
function syncEconomyData()
    setElementData(resourceRoot, "serverBank", bankBalance)
    setElementData(resourceRoot, "factoryStock", factoryStock)
    setElementData(resourceRoot, "cafeStock", cafeStock)
    setElementData(resourceRoot, "detailsStock", detailsStock)
    setElementData(resourceRoot, "serviceStock", serviceStock)
end
syncEconomyData()