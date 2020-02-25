local LMM = LibStub("LibMainMenu")

MenuPvpMeter = {}

function MenuPvpMeter:Initialize()
  -- Set Title
  ZO_CreateStringId("SI_BINDING_NAME_PVPMETER_SHOW_PANEL","Open PvP Meter")
  ZO_CreateStringId("SI_PVPMETER_MAIN_MENU_TITLE", "Pvp Meter")


  -- button data for the main menu (top bar with inventory, map, journal etc)
  self.BASE_MENU_DATA =
  {
    binding = "PVPMETER_SHOW_PANEL",
    categoryName = SI_PVPMETER_MAIN_MENU_TITLE,
    descriptor = 19,
    normal = "EsoUi/Art/journal/journal_tabicon_achievements_up.dds",
    pressed = "EsoUi/Art/journal/journal_tabicon_achievements_down.dds",
    highlight = "EsoUi/Art/journal/journal_tabicon_achievements_over.dds",
    callback = function()
      local viaButton = true
      self:Show(viaButton) -- the top bar button was pressed (i.e. not the keybind), show the scene
    end,
  }

  self.BASE_MENU = LMM:AddCategory(self.BASE_MENU_DATA)

  self.iconData = {}
  self.scenes = {}
end

-- called after all submenues have registered themselves
-- creates the final menu with all registered entries
function MenuPvpMeter:Finalize()
  -- Register Scenes and the group name
  self.sceneGroup = ZO_SceneGroup:New(unpack(self.scenes))
        SCENE_MANAGER:AddSceneGroup("PvpMeterSceneGroup", self.sceneGroup)
        -- Register the group and add the buttons
        LMM:AddSceneGroup(self.BASE_MENU, "PvpMeterSceneGroup", self.iconData)
  -- add a button to the main menu
  self.mainMenuButton = ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, self.BASE_MENU_DATA)
end


-- registers the given button data to the menu
function MenuPvpMeter:Register(iconEntry)
  table.insert(self.iconData, iconEntry)
  table.insert(self.scenes, iconEntry.descriptor)
end


-- display the menu
function MenuPvpMeter:Show(viaButton)
  if not self.sceneGroup:IsShowing() then

    LMM:ToggleCategory(self.BASE_MENU, viaButton)
  end
end


-- toggles the menu
function MenuPvpMeter:Toggle(viaButton)
  --d("test")

  if(PvpMeter.savedVariables.hideMenu==false) then return end

  LMM:ToggleCategory(self.BASE_MENU)
  if not viaButton then
    -- when opening the menu via the keybind, we have to reset the main menu buttons
    ZO_MenuBar_ClearSelection(MAIN_MENU_KEYBOARD.categoryBar)
  end
end

-- REVIEW Whats it doing
function MenuPvpMeter.SwitchageAffichage()
  if(SCENE_MANAGER:IsShowing("PvpmeterduelScene"))then


    --DuelPvpMeter.show()
    --set button
    --LMM:ToggleCategory(MenuPvpMeter.BASE_MENU, true)
  else
    --DuelPvpMeter.hide()
  end
  if(SCENE_MANAGER:IsShowing("PvpmeterBGScene"))then

    --BGPvpMeter.show2()
    --set button
    --LMM:ToggleCategory(MenuPvpMeter.BASE_MENU, true)
  else
    --BGPvpMeter.hide()
  end
end