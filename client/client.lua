ESX = exports['es_extended']:getSharedObject()

local hasBackpack = false
local currentBackpack = nil

local function GetWeightInKg(weightBonus)
    local bonus = tonumber(weightBonus) or 0
    if Config.WeightUnit == 'g' then
        return bonus / 1000
    end
    return bonus
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end
    
    Wait(2000)
    
    ESX.TriggerServerCallback('ncc_backpack:getBackpackStatus', function(backpack)
        if backpack then
            hasBackpack = true
            currentBackpack = backpack
            if Config.Debug then
                local weightInKg = GetWeightInKg(backpack.weight_bonus)
                print(string.format('[NCC-BACKPACK] Rucksack Status geladen: %s (+%skg)', 
                    backpack.label, weightInKg))
            end
        else
            if Config.Debug then
                print('[NCC-BACKPACK] Kein gespeicherter Rucksack gefunden')
            end
        end
    end)
end)

RegisterNetEvent('ncc_backpack:updateStatus', function(equipped, backpack)
    hasBackpack = equipped
    currentBackpack = backpack
    
    if Config.Debug then
        if equipped then
            local weightInKg = GetWeightInKg(backpack.weight_bonus)
            print(string.format('[NCC-BACKPACK] Status aktualisiert: %s (+%skg)', 
                backpack.label, weightInKg))
        else
            print('[NCC-BACKPACK] Rucksack entfernt')
        end
    end
end)

RegisterCommand('removebackpack', function()
    if not hasBackpack then
        ESX.ShowNotification(Config.Messages['no_backpack'])
        return
    end
    
    TriggerServerEvent('ncc_backpack:removeBackpack')
end, false)

RegisterCommand('backpackstatus', function()
    if hasBackpack and currentBackpack then
            local weightInKg = GetWeightInKg(currentBackpack.weight_bonus)
        ESX.ShowNotification(string.format(Config.Messages['backpack_status'], 
            currentBackpack.label, weightInKg))
    else
        ESX.ShowNotification(Config.Messages['no_backpack'])
    end
end, false)

RegisterCommand('rucksackstatus', function()
    if hasBackpack and currentBackpack then
            local weightInKg = GetWeightInKg(currentBackpack.weight_bonus)
        ESX.ShowNotification(string.format(Config.Messages['backpack_status'], 
            currentBackpack.label, weightInKg))
    else
        ESX.ShowNotification(Config.Messages['no_backpack'])
    end
end, false)

function GetCurrentBackpack()
    return currentBackpack
end

function HasBackpack()
    return hasBackpack
end

function GetBackpackWeightBonus()
    if hasBackpack and currentBackpack then
        return currentBackpack.weight_bonus
    end
    return 0
end

exports('GetCurrentBackpack', GetCurrentBackpack)
exports('HasBackpack', HasBackpack)
exports('GetBackpackWeightBonus', GetBackpackWeightBonus)

print("^0[^3NCC-Service^0] ^2Backpack Client successfully started!^0")
print("^0[^3NCC-Service^0] ^3discord.gg/XCRAPKm9uP^0")
