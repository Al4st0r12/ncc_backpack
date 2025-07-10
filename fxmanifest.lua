fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NCC-Service'
description 'ESX Backpack System - Increases carrying capacity'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'es_extended'
}