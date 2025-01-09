fx_version 'cerulean'
game 'gta5'
author 'atiysu'
lua54 'yes'
discord 'https://discord.gg/dvPMYsRFNx'

games {
  "gta5",
  "rdr3"
}

shared_scripts{
  "shared/*.lua",
}

client_scripts {
  "client/utils.lua",
  "client/*.lua",
}

local isEscrowed = false
if isEscrowed then
  escrow_ignore {
    "shared/*.lua",
    "client/open.lua",
  }
else
  escrow_ignore {
    "shared/*.lua",
    "client/**/*",
  }
end