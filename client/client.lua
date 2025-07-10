ESX = exports['es_extended']:getSharedObject()

local hasBackpack = false
local currentBackpack = nil


CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end
    
    ESX.TriggerServerCallback('ncc_backpack:getBackpackStatus', function(backpack)
        if backpack then
            hasBackpack = true
            currentBackpack = backpack
            if Config.Debug then
                print('[NCC-BACKPACK] Rucksack Status geladen:', backpack.label)
            end
        end
    end)
end)


RegisterNetEvent('ncc_backpack:useBackpack', function(itemName, backpack)
    if hasBackpack then
        
        TriggerServerEvent('ncc_backpack:removeBackpack')
        hasBackpack = false
        currentBackpack = nil
    else
        
        TriggerServerEvent('ncc_backpack:equipBackpack', itemName, backpack)
        hasBackpack = true
        currentBackpack = {
            item = itemName,
            weight_bonus = backpack.weight_bonus,
            label = backpack.label
        }
    end
end)


RegisterCommand('removebackpack', function()
    if not hasBackpack then
        ESX.ShowNotification(Config.Messages['no_backpack'])
        return
    end
    
    TriggerServerEvent('ncc_backpack:removeBackpack')
    hasBackpack = false
    currentBackpack = nil
end, false)


RegisterCommand('backpackstatus', function()
    if hasBackpack and currentBackpack then
        local weightInKg = currentBackpack.weight_bonus / 1000
        ESX.ShowNotification(string.format('Aktueller Rucksack: %s (+%skg)', currentBackpack.label, weightInKg))
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

exports('GetCurrentBackpack', GetCurrentBackpack)
exports('HasBackpack', HasBackpack)
