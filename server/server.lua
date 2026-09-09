ESX = exports['es_extended']:getSharedObject()

local PlayerBackpacks = {}

local function GetPlayerItemCount(xPlayer, itemName)
    if not xPlayer or not itemName then return 0 end
    
    if xPlayer.getInventoryItem then
        local item = xPlayer.getInventoryItem(itemName)
        if item then
            if type(item) == 'table' and item.count then
                return tonumber(item.count) or 0
            elseif type(item) == 'number' then
                return item
            end
        end
    end

    if xPlayer.hasItem then
        local has = xPlayer.hasItem(itemName)
        if type(has) == 'table' and has.count then
            return tonumber(has.count) or 0
        elseif type(has) == 'number' then
            return has
        elseif type(has) == 'boolean' then
            return has and 1 or 0
        end
    end
    
    return 0
end

-- Hilfsfunktion: Wandelt Config-Wert in die Gewichtseinheit des Inventars um
-- WeightUnit = 'kg': Wert wird 1:1 uebernommen (150 = +150 Platz)
-- WeightUnit = 'g':  Wert wird in Gramm umgerechnet (150 kg = 150000)
local function GetNormalizedWeightBonus(weightBonus)
    local bonus = tonumber(weightBonus) or 0
    if Config.WeightUnit == 'g' then
        return bonus * 1000
    end
    return bonus
end

CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `user_backpacks` (
            `identifier` VARCHAR(60) NOT NULL,
            `backpack_item` VARCHAR(50) NOT NULL,
            `weight_bonus` INT(11) NOT NULL,
            `label` VARCHAR(100) NOT NULL,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function(result)
        if Config.Debug then
            print('[NCC-Backpack] Datenbank Tabelle erstellt/überprüft')
        end
    end)
end)

CreateThread(function()
    while true do
        Wait(Config.SecurityCheckInterval or 60000)
        
        for playerId, backpack in pairs(PlayerBackpacks) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                local itemCount = GetPlayerItemCount(xPlayer, backpack.item)
                
                if itemCount < 1 then
                    if Config.Debug then
                        print(string.format('[NCC-Backpack] WARNUNG: Item %s von Spieler %s verschwunden!', 
                            backpack.item, GetPlayerName(playerId)))
                    end
                    
                    removeBackpackInternal(playerId, true)
                    
                    local msg = Config.Messages['item_missing'] or '⚠️ Rucksack abgenommen, da das Item nicht mehr im Inventar ist!'
                    TriggerClientEvent('esx:showNotification', playerId, msg)
                end
            end
        end
    end
end)

CreateThread(function()
    Wait(2000)
    
    for itemName, backpack in pairs(Config.Backpacks) do
        ESX.RegisterUsableItem(itemName, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return end
            
            if Config.Debug then
                print(string.format('[NCC-Backpack] Spieler %s verwendet %s', GetPlayerName(source), itemName))
            end
            
            local itemCount = GetPlayerItemCount(xPlayer, itemName)
            if itemCount < 1 then
                if Config.Debug then
                    print(string.format('[NCC-Backpack] FEHLER: Spieler %s hat %s nicht im Inventar!', 
                        GetPlayerName(source), itemName))
                end
                TriggerClientEvent('esx:showNotification', source, Config.Messages['no_item'])
                return
            end
            
            if PlayerBackpacks[source] then
                if PlayerBackpacks[source].item == itemName then
                    removeBackpackInternal(source, false)
                    return
                end
                
                local oldBackpack = PlayerBackpacks[source]
                local oldBonus = GetNormalizedWeightBonus(oldBackpack.weight_bonus)
                local newBonus = GetNormalizedWeightBonus(backpack.weight_bonus)
                
                local weightDifference = newBonus - oldBonus
                local newMaxWeight = xPlayer.getMaxWeight() + weightDifference
                
                if weightDifference < 0 and xPlayer.getWeight() > newMaxWeight then
                    TriggerClientEvent('esx:showNotification', source, '⚠️ Du trägst zu viel um auf einen kleineren Rucksack zu wechseln!')
                    return
                end
                
                if Config.Debug then
                    print(string.format('[NCC-Backpack] Spieler %s wechselt von %s zu %s', 
                        GetPlayerName(source), oldBackpack.label, backpack.label))
                end
                
                TriggerClientEvent('esx:showNotification', source, 
                    string.format('✅ Rucksack gewechselt: %s → %s', oldBackpack.label, backpack.label))
            end
            
            equipBackpack(source, itemName, backpack)
        end)
        
        if Config.Debug then
            print(string.format('[NCC-Backpack] Item %s als benutzbar registriert', itemName))
        end
    end
end)

function equipBackpack(src, itemName, backpack)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local itemCount = GetPlayerItemCount(xPlayer, itemName)
    if itemCount < 1 then
        if Config.Debug then
            print(string.format('[NCC-Backpack] FEHLER: equipBackpack - Spieler %s hat %s nicht!', 
                GetPlayerName(src), itemName))
        end
        TriggerClientEvent('esx:showNotification', src, Config.Messages['no_item'])
        return
    end
    
    local newWeightBonus = GetNormalizedWeightBonus(backpack.weight_bonus)
    local oldWeightBonus = 0
    if PlayerBackpacks[src] then
        oldWeightBonus = GetNormalizedWeightBonus(PlayerBackpacks[src].weight_bonus)
    end
    
    PlayerBackpacks[src] = {
        item = itemName,
        weight_bonus = newWeightBonus,
        label = backpack.label
    }
    
    MySQL.Async.execute('INSERT INTO user_backpacks (identifier, backpack_item, weight_bonus, label) VALUES (@identifier, @item, @weight, @label) ON DUPLICATE KEY UPDATE backpack_item = @item, weight_bonus = @weight, label = @label', {
        ['@identifier'] = xPlayer.identifier,
        ['@item'] = itemName,
        ['@weight'] = newWeightBonus,
        ['@label'] = backpack.label
    }, function(affectedRows)
        if Config.Debug then
            print(string.format('[NCC-Backpack] Datenbank aktualisiert für %s (Rows: %s)', 
                GetPlayerName(src), affectedRows))
        end
    end)
    
    local currentMaxWeight = xPlayer.getMaxWeight()
    local newMaxWeight = math.max(0, currentMaxWeight - oldWeightBonus + newWeightBonus)
    xPlayer.setMaxWeight(newMaxWeight)
    
    TriggerClientEvent('esx:showNotification', src, backpack.notify_equipped)
    TriggerClientEvent('ncc_backpack:updateStatus', src, true, PlayerBackpacks[src])
    
    if Config.Debug then
        local weightInKg = Config.WeightUnit == 'g' and (newWeightBonus / 1000) or newWeightBonus
        print(string.format('[NCC-Backpack] Spieler %s hat %s ausgerüstet (+%skg) | MaxWeight: %s -> %s', 
            GetPlayerName(src), backpack.label, weightInKg, currentMaxWeight, newMaxWeight))
    end
end

function removeBackpackInternal(src, isAutomatic)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    
    if not PlayerBackpacks[src] then
        return false
    end
    
    local backpack = PlayerBackpacks[src]
    local backpackConfig = Config.Backpacks[backpack.item]
    local weightBonus = GetNormalizedWeightBonus(backpack.weight_bonus)
    
    if not isAutomatic then
        local targetMaxWeight = xPlayer.getMaxWeight() - weightBonus
        if xPlayer.getWeight() > targetMaxWeight then
            TriggerClientEvent('esx:showNotification', src, Config.Messages['inventory_too_heavy'])
            return false
        end
    end
    
    local currentMaxWeight = xPlayer.getMaxWeight()
    local newMaxWeight = math.max(0, currentMaxWeight - weightBonus)
    xPlayer.setMaxWeight(newMaxWeight)
    
    MySQL.Async.execute('DELETE FROM user_backpacks WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    
    PlayerBackpacks[src] = nil
    
    if isAutomatic then
        if Config.Debug then
            print(string.format('[NCC-Backpack] Automatische Entfernung für %s', GetPlayerName(src)))
        end
    else
        if backpackConfig and backpackConfig.notify_removed then
            TriggerClientEvent('esx:showNotification', src, backpackConfig.notify_removed)
        else
            TriggerClientEvent('esx:showNotification', src, '✅ Rucksack abgenommen')
        end
    end
    
    TriggerClientEvent('ncc_backpack:updateStatus', src, false, nil)
    
    if Config.Debug then
        print(string.format('[NCC-Backpack] Spieler %s Rucksack entfernt | MaxWeight: %s', 
            GetPlayerName(src), newMaxWeight))
    end
    
    return true
end

RegisterNetEvent('ncc_backpack:removeBackpack', function()
    local src = source
    
    if not PlayerBackpacks[src] then
        TriggerClientEvent('esx:showNotification', src, Config.Messages['no_backpack'])
        return
    end
    
    removeBackpackInternal(src, false)
end)

ESX.RegisterServerCallback('ncc_backpack:getBackpackStatus', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb(nil)
        return 
    end
    
    if PlayerBackpacks[source] then
        cb(PlayerBackpacks[source])
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM user_backpacks WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result and result[1] then
            local backpackData = result[1]
            local itemName = backpackData.backpack_item
            local configEntry = Config.Backpacks[itemName]
            
            local weightBonus = configEntry and configEntry.weight_bonus or backpackData.weight_bonus
            local label = configEntry and configEntry.label or backpackData.label
            weightBonus = GetNormalizedWeightBonus(weightBonus)
            
            CreateThread(function()
                local itemCount = 0
                for attempt = 1, 3 do
                    itemCount = GetPlayerItemCount(xPlayer, itemName)
                    if itemCount >= 1 then
                        break
                    end
                    if attempt < 3 then
                        Wait(1000)
                    end
                end
                
                if itemCount >= 1 then
                    if not PlayerBackpacks[source] then
                        PlayerBackpacks[source] = {
                            item = itemName,
                            weight_bonus = weightBonus,
                            label = label
                        }
                        
                        local oldMaxWeight = xPlayer.getMaxWeight()
                        local newMaxWeight = oldMaxWeight + weightBonus
                        xPlayer.setMaxWeight(newMaxWeight)
                        
                        if Config.Debug then
                            local weightInKg = Config.WeightUnit == 'g' and (weightBonus / 1000) or weightBonus
                            print(string.format('[NCC-Backpack] Rucksack für %s wiederhergestellt: %s (+%skg) | MaxWeight: %s -> %s', 
                                GetPlayerName(source), label, weightInKg, oldMaxWeight, newMaxWeight))
                        end
                        
                        TriggerClientEvent('esx:showNotification', source, 
                            string.format(Config.Messages['backpack_restored'], label))
                    end
                    
                    cb(PlayerBackpacks[source])
                else
                    MySQL.Async.execute('DELETE FROM user_backpacks WHERE identifier = @identifier', {
                        ['@identifier'] = xPlayer.identifier
                    })
                    
                    if Config.Debug then
                        print(string.format('[NCC-Backpack] WARNUNG: Rucksack-Item nicht gefunden für %s nach Retries - Datenbank bereinigt', 
                            GetPlayerName(source)))
                    end
                    
                    cb(nil)
                end
            end)
        else
            cb(nil)
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if PlayerBackpacks[src] then
        if Config.Debug then
            print(string.format('[NCC-Backpack] Spieler %s disconnect - RAM-Status entfernt', GetPlayerName(src)))
        end
        PlayerBackpacks[src] = nil
    end
end)

RegisterCommand('removebackpackadmin', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'owner' then
        TriggerClientEvent('esx:showNotification', source, '⚠️ Keine Berechtigung!')
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('esx:showNotification', source, '⚠️ Verwendung: /removebackpackadmin [ID]')
        return
    end
    
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        TriggerClientEvent('esx:showNotification', source, '⚠️ Spieler nicht online!')
        return
    end
    
    if not PlayerBackpacks[targetId] then
        TriggerClientEvent('esx:showNotification', source, '⚠️ Dieser Spieler trägt keinen Rucksack!')
        return
    end
    
    removeBackpackInternal(targetId, true)
    
    TriggerClientEvent('esx:showNotification', source, '✅ Rucksack von ' .. GetPlayerName(targetId) .. ' entfernt')
    TriggerClientEvent('esx:showNotification', targetId, '⚠️ Dein Rucksack wurde von einem Admin entfernt!')
end, false)
