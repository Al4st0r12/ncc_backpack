Config = {}


Config.Backpacks = {
    ['kleiner_rucksack'] = {
        label = 'Kleiner Rucksack',
        weight_bonus = 35, -- 35 kg
        description = 'Ein kleiner Rucksack der dein Tragegewicht um 10kg erhöht'
    },
    ['mittlerer_rucksack'] = {
        label = 'Mittlerer Rucksack',
        weight_bonus = 75, -- 75kg
        description = 'Ein mittlerer Rucksack der dein Tragegewicht um 20kg erhöht'
    },
    ['grosser_rucksack'] = {
        label = 'Großer Rucksack',
        weight_bonus = 150, -- 150kg
        description = 'Ein großer Rucksack der dein Tragegewicht um 35kg erhöht'
    }
}

-- Nachrichten
Config.Messages = {
    ['backpack_equipped'] = 'Du hast den %s ausgerüstet. Tragegewicht erhöht um %s kg!',
    ['backpack_removed'] = 'Du hast den Rucksack abgenommen. Tragegewicht zurückgesetzt.',
    ['backpack_already_equipped'] = 'Du trägst bereits einen Rucksack!',
    ['inventory_too_heavy'] = 'Du trägst zu viel um den Rucksack abzunehmen!',
    ['no_backpack'] = 'Du trägst keinen Rucksack!'
}

-- Debug Modus (true = Debug Nachrichten anzeigen)
Config.Debug = true

-- Item Registrierung (muss in der Datenbank 'can_remove' = 1 haben)
Config.RegisterItems = true