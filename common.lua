-- Live information while running, lost on reloadUI
liveDefaults = {
  kills = 0,
  assists = 0,
  deaths = 0,
  bgScore = 0,
  zone = 0
}

-- Default Saved settings
settingsDefault ={
  bgOverlayEnabled = true,
  bgOverlayLeft = 0,
  bgOverlayRight = 0,

  CryoOverlayEnabled = true,
  CryoOverlayLeft = 0,
  CryoOverlayRight = 0,

  KillSound = 0, -- ID to soundOptions
  killingblowMsgEnabled = true,
  killingblowMsg = "Killed ${target}",
}

-- The option names for sound
soundOptions = {
  [1] = "No sound",
  [2] = "Triumphant Drums",
  [3] = "Metallic slam",
  [4] = "Small gong",
  [5] = "Short drums",
  [6] = "Coins",
  [7] = "Glide",
  [8] = "Quest",
  [9] = "slammin'",
  [10] = "Crappy firework",
  [11] = "Ding Dong Mofo",
  [12] = "Crossing swords",
  [13] = "Shitty bass",
}

-- The sounds from options
killSounds = {
  [1] = "Click",
  [2] = "Emperor_Coronated_Daggerfall",
  [3] = "AvA_Gate_Opened",
  [4] = "Raid_Trial_Failed",
  [5] = "Stats_Purchase",
  [6] = "Money_Transact",
  [7] = "LevelUp",
  [8] = "Quest_Complete",
  [9] = "AvA_Gate_Closed",
  [10] = "Achievement_Awarded",
  [11] = "CrownCrates_Gain_Gems",
  [12] = "Duel_Won",
  [13] = "Justice_PickpocketBonus",
}