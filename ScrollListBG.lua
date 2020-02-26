-- This file contains the scrollable window portion of BGs, which lives inside the
-- PvpMeterBGmenu.lua
UnitList = ZO_SortFilterList:Subclass()
UnitList.defaults = {}
SLE = {}
SLE.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
SLE.RED_TEXT = ZO_ColorDef:New(0.7, 0, 0, 1)
SLE.GREEN_TEXT = ZO_ColorDef:New(0.2, 0.7, 0, 1)
SLE.UnitList = nil
SLE.units = {}

UnitList.SORT_KEYS = {
    ["name"] = {},
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


function UnitList:New()
  local units = ZO_SortFilterList.New(self, ScrollListBG)
  return units
end


function UnitList:Initialize(control)
  ZO_SortFilterList.Initialize(self, control)

  self.sortHeaderGroup:SelectHeaderByKey("name")
  ZO_SortHeader_OnMouseExit(ScrollListBGHeadersName)
  self.page = 1

  self.cpt =1

  self.ctr = nil
  self.masterList = {}
  ZO_ScrollList_AddDataType(self.list, 1, "ScrollListBGUnitRow", 30, function(control, data) self:SetupUnitRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, UnitList.SORT_KEYS, self.currentSortOrder) end
  self:RefreshData()
end


function UnitList:BuildMasterList()
  self.masterList = {}
  local units = SLE.units
  for k, v in pairs(units) do
    local data = v
    data["name"] = k
    table.insert(self.masterList, data)
  end
end


function UnitList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)

  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end
end


function UnitList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end


function UnitList:SetupUnitRow(control, data)
  UnitList.ctr = control

  control.data = data
  control.name = GetControl(control, "Name")
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

  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene") == true) then

    ScrollListBG:SetDimensions(680,450)
    control.name:SetDimensions(40,32)
    control.type:SetDimensions(60,32)
    control.race:SetDimensions(60,32)
    control.class:SetDimensions(60,32)
    control.zone:SetDimensions(70,32)
    control.kill:SetDimensions(60,32)
    control.death:SetDimensions(70,32)
    control.assist:SetDimensions(60,32)
    control.damd:SetDimensions(60,32)
    control.heal:SetDimensions(60,32)

  end
  if (SCENE_MANAGER:IsShowing("PvpmeterduelScene") == true) then

    ScrollListBG:SetDimensions(920,450)
    control.name:SetDimensions(50,32)
    control.type:SetDimensions(40,32)
    control.race:SetDimensions(140,32)
    control.class:SetDimensions(80,32)
    control.zone:SetDimensions(120,32)
    control.kill:SetDimensions(75,32)
    control.death:SetDimensions(90,32)
    control.assist:SetDimensions(80,32)
    control.damd:SetDimensions(80,32)
    control.heal:SetDimensions(90,32)


  end

  control.texture = GetControl(control, "iconTeamControl")
  control.icon = GetControl(control.texture,"iconTeamBG")
  control.texture1 = GetControl(control, "iconClassControl")
  control.icon1 = GetControl(control.texture1,"iconClassDuel")

  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene") == true) then
    if (data.race ~= 0) then
      control.icon:SetHidden(false)
      control.icon:SetTexture(GetBattlegroundTeamIcon(data.race))
    else
      control.icon:SetHidden(true)
    end

    control.icon1:SetHidden(true)

    if (data.class >= 1000) then
      control.class:SetText(data.class/10)
    else
      control.class:SetText(data.class)
    end

    control.race:SetText("")

  else
    control.icon:SetHidden(true)

    if (data.class ~= 0) then
      control.icon1:SetHidden(false)

      local id = data.class
      if (data.class == 4) then id = 5 end
      if (data.class == 6) then id = 4 end

      defId ,lore ,normalIconKeyboard ,pressedIconKeyboard ,mouseoverIconKeyboard ,isSelectable ,ingameIconKeyboard = GetClassInfo(id)
      control.icon1:SetTexture(ingameIconKeyboard)
    else
      control.icon1:SetHidden(true)
    end

    control.class:SetText("")
  end

  control.name:SetText(data.name)

  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene") == true) then
    control.type:SetText(data.type)
  else
    if (data.type) then
      control.type:SetText("V")
      control.type.normalColor =SLE.GREEN_TEXT
    else
      control.type:SetText("D")
      control.type.normalColor =SLE.RED_TEXT
    end
    control.race:SetText(data.race)
  end

  control.zone:SetText(data.zone)
  control.kill:SetText(data.kill)
  control.death:SetText(data.death)
  control.assist:SetText(data.assist)
  control.damd:SetText(data.damd)
  control.heal:SetText(data.heal)
  control.damt:SetText(data.damt)


  --[[
  if (endd > 0.49) then
    LabelP:SetColor(0.2,0.7,0)
    Perc:SetColor(0.2,0.7,0)
  end
  if (endd <= 0.49) then
    LabelP:SetColor(0.7,0,0)
    Perc:SetColor(0.7,0,0)
  end

  ]]

  control.name.normalColor = SLE.DEFAULT_TEXT
  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene") == true) then
    control.type.normalColor = SLE.DEFAULT_TEXT
  end
  control.race.normalColor = SLE.DEFAULT_TEXT

  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene") == true) then
    if (data.class >= 500) then
      control.class.normalColor = SLE.GREEN_TEXT
    else
      control.class.normalColor = SLE.RED_TEXT
    end
  else
    control.class.normalColor = SLE.DEFAULT_TEXT
  end

  control.zone.normalColor = SLE.DEFAULT_TEXT
  control.kill.normalColor = SLE.DEFAULT_TEXT
  control.death.normalColor = SLE.DEFAULT_TEXT
  control.assist.normalColor = SLE.DEFAULT_TEXT
  control.damd.normalColor = SLE.DEFAULT_TEXT
  control.heal.normalColor = SLE.DEFAULT_TEXT
  control.damt.normalColor = SLE.DEFAULT_TEXT

  ZO_SortFilterList.SetupRow(self, control, data)
end


function SLE.alignementDuel()

  if (SCENE_MANAGER:IsShowing("PvpmeterduelScene") == true) then

    --"EsoUI/Art/LFG/LFG_dps_down_over_64.dds"
    --"EsoUI/Art/LFG/LFG_healer_down_over_64.dds"
    --"EsoUI/Art/LFG/LFG_tank_down_over_64.dds"

    local head = ScrollListBG:GetNamedChild("Headers")
    local nn = head:GetNamedChild("Type")

    local aa = head:GetNamedChild("Name")
    aa:SetDimensions(30,32)

    local nameControl = GetControl(nn, "Name")
    nameControl:SetText("Result")

    aa = head:GetNamedChild("Type")
    aa:SetDimensions(90,32)

    local nn1 = head:GetNamedChild("Race")
    local nameControl1 = GetControl(nn1, "Name")
    nameControl1:SetText("Name")

    nn1:SetDimensions(100,32)

    local nn2 = head:GetNamedChild("Class")
    local nameControl2 = GetControl(nn2, "Name")
    nameControl2:SetText("Class")
    nn2:SetDimensions(90,32)

    local nn3 = head:GetNamedChild("Zone")
    local nameControl3 = GetControl(nn3, "Name")
    nameControl3:SetText("Race")
    nn3:SetDimensions(110,32)

    local nn4= head:GetNamedChild("Kill")
    local nameControl4 = GetControl(nn4, "Name")
    nameControl4:SetText("Done")
    nn4:SetDimensions(80,32)

    local nn5= head:GetNamedChild("Death")
    local nameControl5 = GetControl(nn5, "Name")
    nameControl5:SetText("Taken")
    nn5:SetDimensions(90,32)

    local nn6= head:GetNamedChild("Assist")
    local nameControl6 = GetControl(nn6, "Name")
    nameControl6:SetText("Heal")
    nn6:SetDimensions(55,32)

    local nn7= head:GetNamedChild("Damd")
    local nameControl7 = GetControl(nn7, "Name")
    nameControl7:SetText("Blocked")
    nn7:SetDimensions(85,32)

    local nn8= head:GetNamedChild("Heal")
    local nameControl8 = GetControl(nn8, "Name")
    nameControl8:SetText("Shielded")

    nn8:SetDimensions(75,32)

    local nn9= head:GetNamedChild("Damt")
    local nameControl9 = GetControl(nn9, "Name")
    nameControl9:SetText("Dodge")

  end
end


function SLE.alignementBG()

  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene") == true) then

    local head = ScrollListBG:GetNamedChild("Headers")
    local nn = head:GetNamedChild("Type")

    local aa = head:GetNamedChild("Name")
    aa:SetDimensions(40,32)

    local nameControl = GetControl(nn, "Name")
    nameControl:SetText("Type")

    aa = head:GetNamedChild("Type")
    aa:SetDimensions(50,32)


    local nn1 = head:GetNamedChild("Race")
    local nameControl1 = GetControl(nn1, "Name")
    nameControl1:SetText("Team")

    nn1:SetDimensions(60,32)

    local nn2 = head:GetNamedChild("Class")
    local nameControl2 = GetControl(nn2, "Name")
    nameControl2:SetText("Score")
    nn2:SetDimensions(60,32)

    local nn3 = head:GetNamedChild("Zone")
    local nameControl3 = GetControl(nn3, "Name")
    nameControl3:SetText("Medal")
    nn3:SetDimensions(70,32)

    local nn4= head:GetNamedChild("Kill")
    local nameControl4 = GetControl(nn4, "Name")
    nameControl4:SetText("Kill")
    nn4:SetDimensions(50,32)

    local nn5= head:GetNamedChild("Death")
    local nameControl5 = GetControl(nn5, "Name")
    nameControl5:SetText("Death")
    nn5:SetDimensions(70,32)

    local nn6= head:GetNamedChild("Assist")
    local nameControl6 = GetControl(nn6, "Name")
    nameControl6:SetText("Assist")
    nn6:SetDimensions(65,32)

    local nn7= head:GetNamedChild("Damd")
    local nameControl7 = GetControl(nn7, "Name")
    nameControl7:SetText("Done")
    nn7:SetDimensions(60,32)

    local nn8= head:GetNamedChild("Heal")
    local nameControl8 = GetControl(nn8, "Name")
    nameControl8:SetText("Heal")
    nn8:SetDimensions(40,32)

    local nn9= head:GetNamedChild("Damt")
    local nameControl9 = GetControl(nn9, "Name")
    nameControl9:SetText("Taken")

  end
end


function UnitList:Refresh()
  self:RefreshData()
end


function SLE.MouseEnter(control)
  SLE.UnitList:Row_OnMouseEnter(control)
  local cd = control.data
  -- d(cd.name) -- id of the bg
  -- Verification BG

  local r = PvpMeter.savedVariables.BGlist[zo_strformat("<<1>>",cd.name )].mList
  if (r ~= nil) then
    --d(r)


    --local rr = table.copy(r)
    --d(rr)
    --table.sort(rr,compareMedalForList)

    hideElem(true,true,true,true,true,true,true)
    updateMedalsList(r)
  else
    --hide all
    hideElem(true,true,true,true,true,true,true)
  end


end


function table.copy(t)
  local t2 = {};
  for k,v in pairs(t) do
    if type(v) == "table" then
        t2[k] = table.copy(v);
    else
        t2[k] = v;
    end
  end
  return t2;
end


function compareMedalForList(a,b)
d(a)
  if (a.mult == nil ) then
    a.mult = 3
  end
  if (b.mult == nil ) then
    b.mult = 3
  end
  return (a.mult * a.scoreReward) < (b.mult * b.scoreReward)
end


function hideElem(med1,med2,med3,med4,med5,med6,med7)
  Medals1:SetHidden(med1)
  Medals2:SetHidden(med2)
  Medals3:SetHidden(med3)
  Medals4:SetHidden(med4)
  Medals5:SetHidden(med5)
  Medals6:SetHidden(med6)
  Medals7:SetHidden(med7)
end


function updateMedalsList(list)
  local indice =0
  local listTrier = {}
  local compteurList=0
  local ind =0
  local tmp=0
  local finnd=0
  local indi = 0
  local precc=0
  local prec = nil
  --d(list)
  local items = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}

  for indice=1,16 do

    finnd = 0
    tmp=0

    for indi=1,16 do
      local elem1 = list[zo_strformat("<<1>>",indi )]
      if (elem1 ~=nil and elem1.mult~=nil) then
        local calc = elem1.mult*elem1.scoreReward
        if (indice == 1) then
          if (calc > tmp) then
            tmp=calc
            finnd = indi
          end
        else
          --local calc2 = prec.mult*prec.scoreReward
          --d(calc)
          --d(items[zo_strformat("<<1>>",precc)])
          if (calc > tmp and items[zo_strformat("<<1>>",indi)]~=true ) then
            tmp=calc
            finnd = indi
            --d(indi)
          end
        end
      end
    end


    local elem = list[zo_strformat("<<1>>",finnd)]
    precc = finnd
    prec = list[zo_strformat("<<1>>",finnd)]
    items[zo_strformat("<<1>>",precc)] = true
    --d(items[zo_strformat("<<1>>",precc)])

    if (elem ~= nil) then
      ind = ind+1
      if (elem.mult == nil ) then
        elem.mult = 3
      end
      if (ind == 1) then
            Medals1:SetHidden(false)
            local Icon = Medals1:GetNamedChild("Icon")
            local Value = Medals1:GetNamedChild("Value")
            local Count = Icon:GetNamedChild("Count")
            local Name = Medals1:GetNamedChild("Name")
            Name:SetText(elem.name)
            Icon:SetTexture(elem.iconTexture)
            Value:SetText(elem.mult * elem.scoreReward .. " points")
            Count:SetText(elem.mult)
          end
      if (ind == 2) then
            Medals2:SetHidden(false)
            local Icon = Medals2:GetNamedChild("Icon")
            local Value = Medals2:GetNamedChild("Value")
            local Count = Icon:GetNamedChild("Count")
            local Name = Medals2:GetNamedChild("Name")
            Name:SetText(elem.name)
            Icon:SetTexture(elem.iconTexture)
            Value:SetText(elem.mult * elem.scoreReward .. " points")
            Count:SetText(elem.mult)
          end
      if (ind == 3) then
            Medals3:SetHidden(false)
            local Icon = Medals3:GetNamedChild("Icon")
            local Value = Medals3:GetNamedChild("Value")
            local Count = Icon:GetNamedChild("Count")
            local Name = Medals3:GetNamedChild("Name")
            Name:SetText(elem.name)
            Icon:SetTexture(elem.iconTexture)
            Value:SetText(elem.mult * elem.scoreReward .. " points")
            Count:SetText(elem.mult)
          end
      if (ind == 4) then
            Medals4:SetHidden(false)
            local Icon = Medals4:GetNamedChild("Icon")
            local Value = Medals4:GetNamedChild("Value")
            local Count = Icon:GetNamedChild("Count")
            local Name = Medals4:GetNamedChild("Name")
            Name:SetText(elem.name)
            Icon:SetTexture(elem.iconTexture)
            Value:SetText(elem.mult * elem.scoreReward .. " points")
            Count:SetText(elem.mult)
          end
      if (ind == 5) then
            Medals5:SetHidden(false)
            local Icon = Medals5:GetNamedChild("Icon")
            local Value = Medals5:GetNamedChild("Value")
            local Count = Icon:GetNamedChild("Count")
            local Name = Medals5:GetNamedChild("Name")
            Name:SetText(elem.name)
            Icon:SetTexture(elem.iconTexture)
            Value:SetText(elem.mult * elem.scoreReward .. " points")
            Count:SetText(elem.mult)
          end
      if (ind == 6) then
            Medals6:SetHidden(false)
            local Icon = Medals6:GetNamedChild("Icon")
            local Value = Medals6:GetNamedChild("Value")
            local Count = Icon:GetNamedChild("Count")
            local Name = Medals6:GetNamedChild("Name")
            Name:SetText(elem.name)
            Icon:SetTexture(elem.iconTexture)
            Value:SetText(elem.mult * elem.scoreReward .. " points")
            Count:SetText(elem.mult)
          end
      if (ind == 7) then
          Medals7:SetHidden(false)
          local Icon = Medals7:GetNamedChild("Icon")
          local Value = Medals7:GetNamedChild("Value")
          local Count = Icon:GetNamedChild("Count")
          local Name = Medals7:GetNamedChild("Name")
          Name:SetText(elem.name)
          Icon:SetTexture(elem.iconTexture)
          Value:SetText(elem.mult * elem.scoreReward .. " points")
          Count:SetText(elem.mult)
        end
    else
      break
    end
  end

-- REVIEW What was this
  --[[
  for indice=1,16 do

    local elem = list[zo_strformat("<<1>>",indice )]
    if (elem ~=nil) then

      ind = ind+1
      if (elem.mult == nil ) then
        elem.mult = 3
      end
      if (ind == 1) then
        Medals1:SetHidden(false)
        local Icon = Medals1:GetNamedChild("Icon")
        local Value = Medals1:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals1:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end
      if (ind == 2) then
        Medals2:SetHidden(false)
        local Icon = Medals2:GetNamedChild("Icon")
        local Value = Medals2:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals2:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end
      if (ind == 3) then
        Medals3:SetHidden(false)
        local Icon = Medals3:GetNamedChild("Icon")
        local Value = Medals3:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals3:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end
      if (ind == 4) then
        Medals4:SetHidden(false)
        local Icon = Medals4:GetNamedChild("Icon")
        local Value = Medals4:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals4:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end
      if (ind == 5) then
        Medals5:SetHidden(false)
        local Icon = Medals5:GetNamedChild("Icon")
        local Value = Medals5:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals5:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end
      if (ind == 6) then
        Medals6:SetHidden(false)
        local Icon = Medals6:GetNamedChild("Icon")
        local Value = Medals6:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals6:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end
      if (ind == 7) then
        Medals7:SetHidden(false)
        local Icon = Medals7:GetNamedChild("Icon")
        local Value = Medals7:GetNamedChild("Value")
        local Count = Icon:GetNamedChild("Count")
        local Name = Medals7:GetNamedChild("Name")
        Name:SetText(elem.name)
        Icon:SetTexture(elem.iconTexture)
        Value:SetText(elem.mult * elem.scoreReward .. " points")
        Count:SetText(elem.mult)
      end

    end




  end]]

end


function SLE.MouseExit(control)
  SLE.UnitList:Row_OnMouseExit(control)
  -- hide all
end

-- REVIEW Whats it doing, cause of error?
function SLE.MouseUp(control, button, upInside)
  --local cd = control.data
  --d(table.concat( { cd.name, cd.race, cd.class, cd.zone, cd.kill }, " "))
end


function SLE.reset()
  SLE.units = {}
  if (SCENE_MANAGER:IsShowing("PvpmeterduelScene")) then

    if (PvpMeter.duelPlayed%50==0) then
      SLE.UnitList.cpt = ( (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50))-((PvpMeter.pageD)*50)) + 1
    else
      if ( (PvpMeter.pageD>1 )) then
        SLE.UnitList.cpt = ( (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50))-((PvpMeter.pageD-1)*50)) + 1
      else
        SLE.UnitList.cpt = (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50)) +1
      end
    end
    if (PvpMeter.duelPlayed==0) then
      SLE.UnitList.cpt = 1
    end

  end

  if (SCENE_MANAGER:IsShowing("PvpmeterBGScene")) then
    if (PvpMeter.BGPlayed%50==0) then
      SLE.UnitList.cpt = ( (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50))-((PvpMeter.page)*50)) + 1
    else
      if ( (PvpMeter.page>1 )) then
        SLE.UnitList.cpt = ( (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50))-((PvpMeter.page-1)*50)) + 1
      else
        SLE.UnitList.cpt = (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50)) +1
      end
    end
    if (PvpMeter.BGPlayed==0) then
      SLE.UnitList.cpt = 1
    end
  end

  SLE.UnitList:Refresh()
end


function SLE.TrackUnit(targetRace,targetType ,targetClass,targetZone,targetKill,targetDeath,targetAssist,targetDamd, targetHeal,targetDamt)
  local targetName = SLE.UnitList.cpt
  SLE.UnitList.cpt = SLE.UnitList.cpt + 1

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
  SLE.units[targetName] = {race=targetRace, type=targetType, class=targetClass, zone=targetZone,kill=targetKill,death=targetDeath,assist=targetAssist,damd=targetDamd,heal=targetHeal,damt=targetDamt}
  SLE.UnitList:Refresh()
end


-- do all this when the addon is loaded
function SLE.Init(eventCode, addOnName)
  --if addOnName ~= "ScrollListExample" then return end

  -- Event Registration
  --EVENT_MANAGER:RegisterForEvent("SLE_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, SLE.TrackUnit)

  SLE.UnitList = UnitList:New()
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
  --SLE.units[playerName] = {race=playerRace, class=playerClass, zone=playerZone,kill=playerKill,death=targetDeath,assist=targetAssist,damd=targetDamd,heal=targetHeal,damt=targetDamt}
  --SLE.UnitList:Refresh()

  ScrollListBG:SetHidden(true)
end

--EVENT_MANAGER:RegisterForEvent("SLE_Init", EVENT_ADD_ON_LOADED , SLE.Init)