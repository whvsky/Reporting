-- Created by Scully | https://discord.gg/scully
fx_version 'cerulean'

game 'gta5'

author 'https://discord.gg/scully'
description 'Wee Woo'
version '1.0'

dependencies {
	'/server:5102',
	'/onesync',
}

lua54 'yes'

client_scripts {
	'client_config.lua',
	'client/*.lua'
}

server_scripts {
	'server_config.lua',
	'server/*.lua'
}

escrow_ignore {
	'client_config.lua',
	'server_config.lua',
	'shared/*.lua',
	'client/*.lua',
	'server/*.lua'
}
dependency '/assetpacks'