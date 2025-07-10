# ESX Backpack System

Ein einfaches und benutzerfreundliches Rucksack-System für ESX Legacy Server, das es Spielern ermöglicht, ihr Tragegewicht durch verschiedene Rucksäcke zu erhöhen.

## Features

- **Toggle-System**: Rucksack durch erneutes Benutzen des Items ein- und ausschalten
- **Verschiedene Rucksack-Typen**: Kleiner, mittlerer und großer Rucksack mit unterschiedlichen Gewichtsboni
- **Persistenz**: Rucksack-Status bleibt beim Reconnect erhalten
- **Sicherheit**: Verhindert das Abnehmen des Rucksacks wenn das Inventar zu schwer wäre
- **Debug-Modus**: Detaillierte Logs für Troubleshooting
- **Commands**: Zusätzliche Befehle für Rucksack-Verwaltung

## Installation

### 1. Datenbank Setup

Füge folgende Items zu deiner ESX-Datenbank hinzu:

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('kleiner_rucksack', 'Kleiner Rucksack', 100, 0, 1),
('mittlerer_rucksack', 'Mittlerer Rucksack', 200, 0, 1),
('grosser_rucksack', 'Großer Rucksack', 300, 0, 1);
```

### 2. Script Installation

1. Lade das Script in deinen `resources` Ordner
2. Benenne den Ordner zu `esx_backpack` um
3. Füge `ensure esx_backpack` zu deiner `server.cfg` hinzu
4. Starte den Server neu

### 3. Konfiguration

Bearbeite die `config.lua` um die Rucksäcke anzupassen:

```lua
Config.Backpacks = {
    ['kleiner_rucksack'] = {
        label = 'Kleiner Rucksack',
        weight_bonus = 10000, -- 10kg zusätzlich
        description = 'Ein kleiner Rucksack der dein Tragegewicht um 10kg erhöht'
    },
    -- Weitere Rucksäcke...
}
```

## Verwendung

### Für Spieler

**Rucksack verwenden:**
- Benutze den Rucksack aus deinem Inventar
- Das Tragegewicht wird sofort erhöht
- Benutze das Item erneut um den Rucksack wieder abzunehmen

**Commands:**
- `/removebackpack` - Rucksack abnehmen
- `/backpackstatus` - Aktuellen Rucksack-Status anzeigen

### Für Admins

**Items geben:**
```
/giveitem [player_id] kleiner_rucksack 1
/giveitem [player_id] mittlerer_rucksack 1
/giveitem [player_id] grosser_rucksack 1
```

## Konfiguration

### Rucksack-Typen

| Item Name | Label | Gewichts-Bonus | Beschreibung |
|-----------|-------|----------------|--------------|
| `kleiner_rucksack` | Kleiner Rucksack | +10kg | Basis-Rucksack für Anfänger |
| `mittlerer_rucksack` | Mittlerer Rucksack | +20kg | Erweiterte Kapazität |
| `grosser_rucksack` | Großer Rucksack | +35kg | Maximale Kapazität |

### Nachrichten anpassen

```lua
Config.Messages = {
    ['backpack_equipped'] = 'Du hast den %s ausgerüstet. Tragegewicht erhöht um %s kg!',
    ['backpack_removed'] = 'Du hast den Rucksack abgenommen. Tragegewicht zurückgesetzt.',
    ['backpack_already_equipped'] = 'Du trägst bereits einen Rucksack!',
    ['inventory_too_heavy'] = 'Du trägst zu viel um den Rucksack abzunehmen!',
    ['no_backpack'] = 'Du trägst keinen Rucksack!'
}
```

### Debug-Modus

Setze `Config.Debug = true` für detaillierte Logs:
- Item-Registrierung
- Rucksack-Verwendung
- Spieler-Verbindungen
- Gewichts-Änderungen

## Funktionsweise

1. **Item-Registrierung**: Alle konfigurierten Rucksäcke werden automatisch als benutzbare Items registriert
2. **Toggle-System**: Beim Benutzen des Items wird geprüft ob bereits ein Rucksack ausgerüstet ist
3. **Gewichts-Management**: Das maximale Tragegewicht wird dynamisch angepasst
4. **Persistenz**: Der Rucksack-Status wird serverseitig gespeichert und beim Reconnect wiederhergestellt
5. **Sicherheit**: Verhindert Exploits durch Gewichtsprüfungen

## Exports

Das Script bietet folgende Exports für andere Ressourcen:

```lua
-- Prüfen ob Spieler einen Rucksack trägt
local hasBackpack = exports['esx_backpack']:HasBackpack()

-- Aktuellen Rucksack abrufen
local currentBackpack = exports['esx_backpack']:GetCurrentBackpack()
```

## Troubleshooting

### Häufige Probleme

**Items funktionieren nicht:**
- Überprüfe ob die Items in der Datenbank existieren
- Stelle sicher dass `can_remove = 1` gesetzt ist
- Aktiviere Debug-Modus für detaillierte Logs

**Gewicht wird nicht erhöht:**
- Überprüfe die ESX-Version (Legacy wird benötigt)
- Prüfe ob andere Scripts das Gewicht-System beeinflussen
- Schaue in die Server-Console für Fehlermeldungen

**Rucksack geht beim Reconnect verloren:**
- Das ist normal - derzeit wird der Status nicht in der Datenbank gespeichert
- Spieler müssen den Rucksack nach dem Reconnect neu ausrüsten

### Debug-Informationen

Mit aktiviertem Debug-Modus (`Config.Debug = true`) werden folgende Informationen geloggt:
- `[ESX_BACKPACK] Item X als benutzbar registriert`
- `[ESX_BACKPACK] Spieler X verwendet Y`
- `[ESX_BACKPACK] Spieler X hat Y ausgerüstet (+Zkg)`
- `[ESX_BACKPACK] Spieler X hat Rucksack abgenommen`

## Kompatibilität

- **ESX Legacy**: Vollständig kompatibel
- **ESX 1.1**: Nicht getestet
- **QBCore**: Nicht kompatibel

## Lizenz

Dieses Script ist Open Source und kann frei verwendet und angepasst werden.

## Support

Bei Problemen oder Fragen:
1. Aktiviere den Debug-Modus
2. Überprüfe die Server-Console auf Fehlermeldungen
3. Stelle sicher dass alle Abhängigkeiten installiert sind
4. Prüfe die Datenbank-Konfiguration

## Changelog

### Version 1.0
- Initiale Version
- Toggle-System für Rucksäcke
- Drei verschiedene Rucksack-Typen
- Commands für Rucksack-Management
- Debug-Modus
- Export-Funktionen
