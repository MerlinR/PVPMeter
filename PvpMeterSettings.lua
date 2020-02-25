local panelDuel = {
  type = "panel",
  name = "PvP Meter Resurrection",
  displayName = "PvP Meter",
  author = "marig63, HoboNavity & Thalothean",
  version = "2.39",
  registerForDefaults = true,
      --version = ADDON_VERSION,
  slashCommand = "/pvpmeter",
  }

local optionsDuel = {

  [1] = {
    type = "header",
    name = "Cyrodiil & Battlegrounds",
  },
  [2] = {
    type = "checkbox",
    name = "Show Meter in BG/Cyrodiil",
    tooltip = "Show Meter in BG/Cyrodiil",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.showBeautifulMeter end,
    setFunc = function(val) PvpMeter.savedVariables.showBeautifulMeter = val

      -- REVIEW Whats it doing
      if(val)then
        --HUDTelvarMeter_show()
      else
        --HUDTelvarMeter_hide()
      end
    end,
  },

  [3] = {
    type = "checkbox",
    name = "Auto accept queue",
    tooltip = "Auto accept queue for BG & Cyrodiil",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.autoqueue end,
    setFunc = function(val) PvpMeter.savedVariables.autoqueue = val end,
  },

  [4] = {
    type = "checkbox",
    name = "Show button for cyrodiil queue in the chat ",
    tooltip = "nutton of guest campaign and home campaign",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.quickButton end,
    setFunc = function(val) PvpMeter.savedVariables.quickButton = val
      PvpMeter.updateButtonQuick()
    end,
  },
  [5] = {
    type = "dropdown",
    name = "Meter Rotation", -- or string id or function returning a string
    choices = {"Bot-Right", "Bot-Left", "Top-Left","Top-Right"},
    choicesValues = {1, 2, 3, 4 },
    getFunc = function() return PvpMeter.savedVariables.rotation end,
    setFunc = function(var) PvpMeter.savedVariables.rotation = var
      PvpMeter.rotateMeter(var)
    end,
  },
  [6] = {
    type = "checkbox",
    name = "Kill alert border",
    tooltip = "little animation on border of the screen when you kill an ennemy",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.alertBorder end,
    setFunc = function(val) PvpMeter.savedVariables.alertBorder = val end,
  },
  [7] = {
    type = "checkbox",
    name = "Kill sound",
    tooltip = "play a little sound when you kill an ennemy",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.playSound end,
    setFunc = function(val) PvpMeter.savedVariables.playSound = val end,
  },
  [8] = {
    type = "dropdown",
    name = "Choice kill sound", -- or string id or function returning a string
    choices = {"LOCKPICKING_SUCCESS_CELEBRATION", "EMPEROR_CORONATED_EBONHEART"},
    choicesValues = {0, 1, },
    getFunc = function() return PvpMeter.savedVariables.nbrSound end,
    setFunc = function(var) PvpMeter.savedVariables.nbrSound = var  end,
  },
  [9] = {
     type = "button",
    name = "Test sound",
    tooltip = "",
    width = "full",
    func = function()
        if(PvpMeter.savedVariables.nbrSound == 0)then
        PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
      end
      if(PvpMeter.savedVariables.nbrSound == 1)then
        PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
      end
    end,
   },
  [10] = {
    type = "checkbox",
    name = "Show assist in BG",
    tooltip = "Show assist in BG",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.BGAssist end,
    setFunc = function(val) PvpMeter.savedVariables.BGAssist = val
      if(val and PvpMeter.inBG)then
        LabelAssist:SetHidden(false)
      else
        LabelAssist:SetHidden(true)
      end
    end,
  },
  [11] = {
    type = "checkbox",
    name = "AP of the current session",
    tooltip = "show just AP of the current session",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.currAP end,
    setFunc = function(val) PvpMeter.savedVariables.currAP = val
      PvpMeter.updateAP()
    end,
  },
  [12] = {
    type = "dropdown",
    name = "Cyrodiil meter bar", -- or string id or function returning a string
    choices = {"Percentage of keeps capture","Xp progress to next pvp level"},
    choicesValues = {0, 2},
    getFunc = function() return PvpMeter.savedVariables.nbrCyro end,
    setFunc = function(var) PvpMeter.savedVariables.nbrCyro = var
                PvpMeter.updateMeter()
    end,
  },
  [13] = {
    type = "header",
    name = "Duel",
  },
  [14] = {
    type = "checkbox",
    name = "Duel Meter",
    tooltip = "show Duel Meter",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.duelMeter end,
    setFunc = function(val) PvpMeter.savedVariables.duelMeter= val
                PvpMeter.updateMeterDuel()
    end,
  },
  [15] = {
    type = "header",
    name = "Menu",
  },
  [16] = {
    type = "checkbox",
    name = "Show Menu",
    tooltip = "add a new menu (like inventory, guilds, ...) you can also bind a shortcut",
    default = true,
    getFunc = function() return PvpMeter.savedVariables.hideMenu end,
    setFunc = function(val) PvpMeter.savedVariables.hideMenu = val
                ReloadUI()
    end,
  },
  [17] = {
    type = "header",
    name = "Data Settings",
  },
  [18] = {
     type = "button",
    name = "Reset BG data",
    tooltip = "This will reset all the data saved for BG",
    width = "half",
    func = function()
        PvpMeter.resetDataBG()
    end,
   },
   [19] = {
     type = "button",
    name = "Reset Duel data",
    tooltip = "This will reset all the data saved for duel",
    width = "half",
    func = function()
        PvpMeter.resetDataDuel()
    end,
   }
}


function PvpMeter.initSettings()
  local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
  LAM:RegisterAddonPanel("IHateYou", panelDuel)
  LAM:RegisterOptionControls("IHateYou", optionsDuel)
end

