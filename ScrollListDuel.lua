-- This file contains the scrollable window portion of duels, which lives inside the
-- PvpMeterDuelmenu.lua
UnitListDuel = ZO_SortFilterList:Subclass()
UnitListDuel.defaults = {}
SLEDUEL = {}
SLEDUEL.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
SLEDUEL.RED_TEXT = ZO_ColorDef:New(0.7, 0, 0, 1)
SLEDUEL.GREEN_TEXT = ZO_ColorDef:New(0.2, 0.7, 0, 1)
SLEDUEL.UnitListDuel = nil
SLEDUEL.units = {}

UnitListDuel.SORT_KEYS = {
    ["nam"] = {},
    ["type"] = {tiebreaker="name"},
    ["race"] = {tiebreaker="name"},
    ["class"] = {tiebreaker="name"},
    ["zone"] = {tiebreaker="name"},
    ["kill"] = {tiebreaker="name"},
    ["death"] = {tiebreaker="name"},
    ["assist"] = {tiebreaker="name"},
    ["damd"] = {tiebreaker="name"},
    ["heal"] = {tiebreaker="name"},
    ["damt"] = {tiebreaker="name"}
}


function UnitListDuel:New()
  local units = ZO_SortFilterList.New(self, ScrollListDuel)
  return units
end


function UnitListDuel:Initialize(control)
  ZO_SortFilterList.Initialize(self, control)

  self.sortHeaderGroup:SelectHeaderByKey("name")
  ZO_SortHeader_OnMouseExit(ScrollListDuelHeadersName)
  self.cpt = 0
  self.masterList = {}
  ZO_ScrollList_AddDataType(self.list, 1, "ScrollListDuelUnitRow", 30, function(control, data) self:SetupUnitRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, UnitListDuel.SORT_KEYS, self.currentSortOrder) end
  self:RefreshData()
end


function UnitListDuel:BuildMasterList()
  self.masterList = {}
  local units = SLEDUEL.units
  for k, v in pairs(units) do
    local data = v
    data["name"] = k
    table.insert(self.masterList, data)
  end
end


function UnitListDuel:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)

  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end
end


function UnitListDuel:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end


function UnitListDuel:SetupUnitRow(control, data)
  control.data = data
  control.nam = GetControl(control, "Nam")
  control.type = GetControl(control, "Type")
  control.race = GetControl(control, "Race")
  control.class = GetControl(control, "Class")
  control.zone = GetControl(control, "Zone")
  control.kill = GetControl(control, "Kill")
  control.death = GetControl(control, "Death")
  control.assist = GetControl(control, "Assist")
  control.damd = GetControl(control, "Damd")
  control.heal = GetControl(control, "Heal")
  control.damt = GetControl(control, "Damt")

  control.texture = GetControl(control, "iconTeamControl")
  control.icon = GetControl(control.texture,"iconTeamBG")

  if(data.race ~= 0)then
    control.icon:SetHidden(false)
    control.icon:SetTexture(GetBattlegroundTeamIcon(data.race))
  else
    control.icon:SetHidden(true)
  end


  control.nam:SetText(data.nam)
  control.type:SetText(data.type)
  --control.race:SetText(data.race)
  control.class:SetText(data.class)
  control.zone:SetText(data.zone)
  control.kill:SetText(data.kill)
  control.death:SetText(data.death)
  control.assist:SetText(data.assist)
  control.damd:SetText(data.damd)
  control.heal:SetText(data.heal)
  control.damt:SetText(data.damt)


  --[[
  if(endd > 0.49) then
    LabelP:SetColor(0.2,0.7,0)
    Perc:SetColor(0.2,0.7,0)
  end
  if(endd <= 0.49) then
    LabelP:SetColor(0.7,0,0)
    Perc:SetColor(0.7,0,0)
  end

  ]]

  control.nam.normalColor = SLEDUEL.DEFAULT_TEXT
  control.type.normalColor = SLEDUEL.DEFAULT_TEXT
  control.race.normalColor = SLEDUEL.DEFAULT_TEXT


  if(SCENE_MANAGER:IsShowing("PvpmeterduelScene") == true)then
    if(data.class >= 500)then
      control.class.normalColor = SLEDUEL.GREEN_TEXT
    else
      control.class.normalColor = SLEDUEL.RED_TEXT
    end
  else
    control.class.normalColor = SLEDUEL.DEFAULT_TEXT
  end

  control.zone.normalColor = SLEDUEL.DEFAULT_TEXT
  control.kill.normalColor = SLEDUEL.DEFAULT_TEXT
  control.death.normalColor = SLEDUEL.DEFAULT_TEXT
  control.assist.normalColor = SLEDUEL.DEFAULT_TEXT
  control.damd.normalColor = SLEDUEL.DEFAULT_TEXT
  control.heal.normalColor = SLEDUEL.DEFAULT_TEXT
  control.damt.normalColor = SLEDUEL.DEFAULT_TEXT

  ZO_SortFilterList.SetupRow(self, control, data)
end


function UnitListDuel:Refresh()
  self:RefreshData()
end


function SLEDUEL.MouseEnter(control)
  SLEDUEL.UnitListDuel:Row_OnMouseEnter(control)
end


function SLEDUEL.MouseExit(control)
  SLEDUEL.UnitListDuel:Row_OnMouseExit(control)
end


function SLEDUEL.MouseUp(control, button, upInside)
  --local cd = control.data
  --d(table.concat( { cd.name, cd.race, cd.class, cd.zone, cd.kill }, " "))
end


function SLEDUEL.TrackUnit(targetRace,targetType ,targetClass,targetZone,targetKill,targetDeath,targetAssist,targetDamd, targetHeal,targetDamt)
  SLEDUEL.UnitListDuel.cpt = SLEDUEL.UnitListDuel.cpt + 1
  local targetName = SLEDUEL.UnitListDuel.cpt
  if targetName == "" then return end
  --local targetRace = "Win"
  --local targetClass = "500"
  --local targetZone = "4241"
  --local targetKill = "5"
  --local targetDeath = "6"
  --local targetAssist = "7"
  --local targetDamd = "800k"
  --local targetHeal = 100 .. "k"
  --local targetDamt = "300k"
  SLEDUEL.units[targetName] = {race=targetRace, type=targetType, class=targetClass, zone=targetZone,kill=targetKill,death=targetDeath,assist=targetAssist,damd=targetDamd,heal=targetHeal,damt=targetDamt}
  SLEDUEL.UnitListDuel:Refresh()
end


-- do all this when the addon is loaded
function SLEDUEL.Init(eventCode, addOnName)
  --if addOnName ~= "ScrollListExample" then return end

  -- Event Registration
  --EVENT_MANAGER:RegisterForEvent("SLEDUEL_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, SLEDUEL.TrackUnit)

  SLEDUEL.UnitListDuel = UnitListDuel:New()
  --local playerName = 1
  --local playerRace = "Win"
  --local playerClass = "300"
  --local playerZone = "3200"
  --local playerKill = "11"

  --local targetDeath = "6"
  --local targetAssist = "7"
  --local targetDamd = "8"
  --local targetHeal = "9"
  --local targetDamt = "10"
  --SLEDUEL.units[playerName] = {race=playerRace, class=playerClass, zone=playerZone,kill=playerKill,death=targetDeath,assist=targetAssist,damd=targetDamd,heal=targetHeal,damt=targetDamt}
  --SLEDUEL.UnitListDuel:Refresh()

  ScrollListDuel:SetHidden(true)
end

--EVENT_MANAGER:RegisterForEvent("SLEDUEL_Init", EVENT_ADD_ON_LOADED , SLEDUEL.Init)
