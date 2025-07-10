-- server/main.lua
ESX = exports['es_extended']:getSharedObject()


local PlayerBackpacks = {}


AddEventHandler('esx:playerLoaded', function()
    CreateThread(function()
        Wait(1000)
        
        for itemName, backpack in pairs(Config.Backpacks) do
            ESX.RegisterUsableItem(itemName, function(source)
                local xPlayer = ESX.GetPlayerFromId(source)
                if not xPlayer then return end
                
                if Config.Debug then
                    print(string.format('[NCC-Backpack] Spieler %s verwendet %s', GetPlayerName(source), itemName))
                end
                
                TriggerClientEvent('ncc_backpack:useBackpack', source, itemName, backpack)
            end)
            
            if Config.Debug then
                print(string.format('[NCC-Backpack] Item %s als benutzbar registriert', itemName))
            end
        end
    end)
end)


CreateThread(function()
    Wait(5000) 
    
    for itemName, backpack in pairs(Config.Backpacks) do
        ESX.RegisterUsableItem(itemName, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return end
            
            if Config.Debug then
                print(string.format('[NCC-Backpack] Spieler %s verwendet %s', GetPlayerName(source), itemName))
            end
            
            TriggerClientEvent('ncc_backpack:useBackpack', source, itemName, backpack)
        end)
    end
    
    if Config.Debug then
        print('[NCC-Backpack] Alle Rucksack-Items als benutzbar registriert (Fallback)')
    end
end)


RegisterNetEvent('ncc_backpack:equipBackpack', function(itemName, backpack)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    
    if PlayerBackpacks[src] then
        
        return
    end
    
    
    local hasItem = xPlayer.hasItem(itemName)
    if not hasItem or hasItem.count < 1 then
        return
    end
    
    
    
    
    PlayerBackpacks[src] = {
        item = itemName,
        weight_bonus = backpack.weight_bonus,
        label = backpack.label
    }
    
    
    xPlayer.setMaxWeight(xPlayer.getMaxWeight() + backpack.weight_bonus)
    
    
    local weightInKg = backpack.weight_bonus / 1000
    TriggerClientEvent('esx:showNotification', src, string.format(Config.Messages['backpack_equipped'], backpack.label, weightInKg))
    
    if Config.Debug then
        print(string.format('[NCC-Backpack] Spieler %s hat %s ausgerüstet (+%skg)', GetPlayerName(src), backpack.label, weightInKg))
    end
end)

-- Rucksack abnehmen
RegisterNetEvent('ncc_backpack:removeBackpack', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    
    if not PlayerBackpacks[src] then
        TriggerClientEvent('esx:showNotification', src, Config.Messages['no_backpack'])
        return
    end
    
    local backpack = PlayerBackpacks[src]
    
    
    local newMaxWeight = xPlayer.getMaxWeight() - backpack.weight_bonus
    if xPlayer.getWeight() > newMaxWeight then
        TriggerClientEvent('esx:showNotification', src, Config.Messages['inventory_too_heavy'])
        return
    end
    
    
    
    
    xPlayer.setMaxWeight(newMaxWeight)
    
    
    PlayerBackpacks[src] = nil
    
    
    TriggerClientEvent('esx:showNotification', src, Config.Messages['backpack_removed'])
    
    if Config.Debug then
        print(string.format('[NCC-Backpack] Spieler %s hat Rucksack abgenommen', GetPlayerName(src)))
    end
end)


ESX.RegisterServerCallback('ncc_backpack:getBackpackStatus', function(source, cb)
    cb(PlayerBackpacks[source])
end)


AddEventHandler('playerDropped', function()
    local src = source
    if PlayerBackpacks[src] then
        PlayerBackpacks[src] = nil
        if Config.Debug then
            print(string.format('[NCC-Backpack] Spieler %s disconnect - Rucksack Status entfernt', GetPlayerName(src)))
        end
    end
end)