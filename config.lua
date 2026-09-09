Config = {}

Config.Backpacks = {
    ['kleiner_rucksack'] = {
        label = 'Kleiner Rucksack',
        weight_bonus = 25, -- 25 kg
        description = 'Ein kleiner Rucksack der dein Tragegewicht um 25kg erhöht',
        notify_equipped = 'Du hast den kleinen Rucksack ausgerüstet! (+25kg Tragegewicht)',
        notify_removed = 'Du hast den kleinen Rucksack abgenommen! (-25kg Tragegewicht)'
    },
    ['mittlerer_rucksack'] = {
        label = 'Mittlerer Rucksack',
        weight_bonus = 75, -- 75 kg
        description = 'Ein mittlerer Rucksack der dein Tragegewicht um 75kg erhöht',
        notify_equipped = 'Du hast den mittleren Rucksack ausgerüstet! (+75kg Tragegewicht)',
        notify_removed = 'Du hast den mittleren Rucksack abgenommen! (-75kg Tragegewicht)'
    },
    ['grosser_rucksack'] = {
        label = 'Großer Rucksack',
        weight_bonus = 150, -- 150 kg
        description = 'Ein großer Rucksack der dein Tragegewicht um 150kg erhöht',
        notify_equipped = 'Du hast den großen Rucksack ausgerüstet! (+150kg Tragegewicht)',
        notify_removed = 'Du hast den großen Rucksack abgenommen! (-150kg Tragegewicht)'
    }
}

Config.WeightUnit = 'kg'

Config.Messages = {
    ['backpack_already_equipped'] = '⚠️ Du trägst bereits einen Rucksack!',
    ['inventory_too_heavy'] = '⚠️ Du trägst zu viel um den Rucksack abzunehmen!',
    ['no_backpack'] = '⚠️ Du trägst keinen Rucksack!',
    ['backpack_status'] = '🎒 Aktueller Rucksack: %s (+%skg)',
    ['no_item'] = '⚠️ Du besitzt diesen Rucksack nicht!',
    ['backpack_restored'] = '✅ Rucksack wiederhergestellt: %s',
    ['item_missing'] = '⚠️ Rucksack abgenommen, da das Item nicht mehr im Inventar ist!'
}

Config.Debug = false

-- Datenbank Tabelle für persistente Speicherung
Config.DatabaseTable = 'user_backpacks'
