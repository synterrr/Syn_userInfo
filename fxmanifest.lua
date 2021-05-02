-- Resource Metadata
fx_version 'cerulean'
game 'gta5'

author 'SynTer#3819'
description 'Resource to get all user info, like Inventory, cars in the garage, inventory items etc...'
version '1.0'
lua54 'yes'
disable_lazy_natives 'yes'

server_scripts {
    '@vrp/lib/utils.lua',
    'config.lua',
    'svside.lua'
}

server_only 'yes'
