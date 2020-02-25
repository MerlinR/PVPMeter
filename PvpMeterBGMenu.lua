BGPvpMeter = {}

function BGPvpMeter:Initialize()
  ZO_CreateStringId("SI_PVPMETER_INRANGE_MENU_TITLE", "BattleGrounds")

  self.iconData = {
    categoryName = SI_PVPMETER_INRANGE_MENU_TITLE,
    descriptor = "PvpmeterBGScene",
    normal = "EsoUI/Art/Battlegrounds/battlegrounds_tabIcon_battlegrounds_up.dds",
    pressed = "EsoUI/Art/Battlegrounds/battlegrounds_tabIcon_battlegrounds_down.dds",
    highlight = "EsoUI/Art/Battlegrounds/battlegrounds_tabIcon_battlegrounds_over.dds",
    callback = function()
    end,
  }
  MenuPvpMeter:Register(self.iconData)

  self:CreateControls()
  self:InitializeScene()
end


function BGPvpMeter:InitializeScene()
  self.scene = ZO_Scene:New("PvpmeterBGScene", SCENE_MANAGER)

  -- Mouse standard position and background
  self.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
  self.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

  --  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
  self.scene:AddFragment(RIGHT_BG_FRAGMENT)

  -- The title fragment
  self.scene:AddFragment(TITLE_FRAGMENT)

  -- Set Title
  local TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_PVPMETER_MAIN_MENU_TITLE)
  self.scene:AddFragment(TITLE_FRAGMENT)

  -- Add the XML to our scene
  local MAIN_WINDOW = ZO_FadeSceneFragment:New(PvpMeterMenu)
  self.scene:AddFragment(MAIN_WINDOW)

  self.scene:AddFragment(MAIN_MENU_KEYBOARD.categoryBarFragment)
  self.scene:AddFragment(TOP_BAR_FRAGMENT)
end


function BGPvpMeter:CreateControls()
  PvpMeterMenu.panel = PvpMeterMenu
  PvpMeterMenu.panel.data = {registerForRefresh = true}
  PvpMeterMenu.panel.controlsToRefresh = {}
end


function BGPvpMeter.init()

  -- Stat
  if(PvpMeter.statLoaded==false)then
    for i=1,PvpMeter.BGPlayed do

      local winn = false
      if( tonumber(PvpMeter.BGlist[zo_strformat("<<1>>", i)].score) >= 500) then
        winn = true
      else
        winn = false
      end

      local targetType = PvpMeter.BGlist[zo_strformat("<<1>>", i)].typeOfBG

      if(targetType == 1)then targetType="CTR"
        PvpMeter.nbrCTR = PvpMeter.nbrCTR + 1
        if(winn)then
          PvpMeter.nbrCTRWin =PvpMeter.nbrCTRWin + 1
        end

      end
      if(targetType == 2)then targetType="DM"
        PvpMeter.nbrDM = PvpMeter.nbrDM + 1
        if(winn)then
          PvpMeter.nbrDMWin = PvpMeter.nbrDMWin + 1
        end
      end
      if(targetType == 3)then targetType="KOH" end
      if(targetType == 4)then targetType="DOM"
        PvpMeter.nbrDOM = PvpMeter.nbrDOM + 1
        if(winn)then
          PvpMeter.nbrDOMWin = PvpMeter.nbrDOMWin + 1
        end
      end
      if(targetType == 5)then targetType="CRZ"
        PvpMeter.nbrCRZ = PvpMeter.nbrCRZ + 1
        if(winn)then
          PvpMeter.nbrCRZWin = PvpMeter.nbrCRZWin + 1
        end
      end
      if(targetType == 6)then targetType="BAL"
        PvpMeter.nbrMUR = PvpMeter.nbrMUR + 1
        if(winn)then
          PvpMeter.nbrMURWin = PvpMeter.nbrMURWin + 1
        end
      end


      PvpMeter.nbrKill = PvpMeter.nbrKill + PvpMeter.BGlist[zo_strformat("<<1>>", i)].kill
      PvpMeter.nbrDeath = PvpMeter.nbrDeath + PvpMeter.BGlist[zo_strformat("<<1>>", i)].death
      PvpMeter.nbrAssist = PvpMeter.nbrAssist + PvpMeter.BGlist[zo_strformat("<<1>>", i)].assist
      PvpMeter.nbrDone = PvpMeter.nbrDone + math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].damageDone/1000)
      PvpMeter.nbrHeal = PvpMeter.nbrHeal + math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].healDone/1000)
      PvpMeter.nbrTaken = PvpMeter.nbrTaken + math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].damageTaken/1000)

    end
  end

end


function BGPvpMeter.updateStat()
    for i=PvpMeter.BGPlayed,PvpMeter.BGPlayed do

      local winn = false
      if( tonumber(PvpMeter.BGlist[zo_strformat("<<1>>", i)].score) >= 500) then
        winn = true
      else
        winn = false
      end

      local targetType = PvpMeter.BGlist[zo_strformat("<<1>>", i)].typeOfBG

      if(targetType == 1)then targetType="CTR"
        PvpMeter.nbrCTR = PvpMeter.nbrCTR + 1
        if(winn)then
          PvpMeter.nbrCTRWin =PvpMeter.nbrCTRWin + 1
        end
      end

      if(targetType == 2)then targetType="DM"
        PvpMeter.nbrDM = PvpMeter.nbrDM + 1
        if(winn)then
          PvpMeter.nbrDMWin = PvpMeter.nbrDMWin + 1
        end
      end

      if(targetType == 5)then targetType="CRZ"
        PvpMeter.nbrCRZ = PvpMeter.nbrCRZ + 1
        if(winn)then
          PvpMeter.nbrCRZWin = PvpMeter.nbrCRZWin + 1
        end
      end

      if(targetType == 4)then targetType="DOM"
        PvpMeter.nbrDOM = PvpMeter.nbrDOM + 1
        if(winn)then
          PvpMeter.nbrDOMWin = PvpMeter.nbrDOMWin + 1
        end
      end

      if(targetType == 3)then targetType="KOH" end
      if(targetType == 6)then targetType="BAL"
        PvpMeter.nbrMUR = PvpMeter.nbrMUR + 1
        if(winn)then
          PvpMeter.nbrMURWin = PvpMeter.nbrMURWin + 1
        end
      end


      PvpMeter.nbrKill = PvpMeter.nbrKill + PvpMeter.BGlist[zo_strformat("<<1>>", i)].kill
      PvpMeter.nbrDeath = PvpMeter.nbrDeath + PvpMeter.BGlist[zo_strformat("<<1>>", i)].death
      PvpMeter.nbrAssist = PvpMeter.nbrAssist + PvpMeter.BGlist[zo_strformat("<<1>>", i)].assist
      PvpMeter.nbrDone = PvpMeter.nbrDone + math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].damageDone/1000)
      PvpMeter.nbrHeal = PvpMeter.nbrHeal + math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].healDone/1000)
      PvpMeter.nbrTaken = PvpMeter.nbrTaken + math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].damageTaken/1000)

    end
end


function BGPvpMeter.showStatBG()
  HUDMenuMeter_show()
  HUDMenuMeter_restore(15,-140)

  local endd = 0

  if(PvpMeter.savedVariables.BGPlayed == 0)then
    endd = 1
  else
    endd = PvpMeter.savedVariables.BGWin / PvpMeter.savedVariables.BGPlayed
  end


  HUDMenuMeter_Update(0 ,endd)

  LabelPlayedValue:SetText(PvpMeter.savedVariables.BGPlayed)
  LabelWinValue:SetText(PvpMeter.savedVariables.BGWin)
  LabelLooseValue:SetText(PvpMeter.savedVariables.BGPlayed-PvpMeter.savedVariables.BGWin)

  ScrollListBG:SetHidden(false)

  if(PvpMeter.BGPlayed == 0)then
    LabelTotalKillValue:SetText(      0      )
    LabelTotalDeathValue:SetText(        0    )
    LabelRatioValue:SetText(0  )
    LabelDamValue:SetText(      0 .. "k"  )
    LabelHealingValue:SetText(    0  .. "k"  )
    LabelDamTakenValue:SetText(       0 .. "k"  )
  else
    LabelTotalKillValue:SetText(       math.floor((PvpMeter.nbrKill/PvpMeter.BGPlayed)*10)/10        )
    LabelTotalDeathValue:SetText(        math.floor((PvpMeter.nbrDeath/PvpMeter.BGPlayed)*10)/10       )
    LabelRatioValue:SetText(math.floor((PvpMeter.nbrAssist/PvpMeter.BGPlayed)*10)/10  )
    LabelDamValue:SetText(      math.floor(PvpMeter.nbrDone/PvpMeter.BGPlayed) .. "k"  )
    LabelHealingValue:SetText(     math.floor(PvpMeter.nbrHeal/PvpMeter.BGPlayed)  .. "k"  )
    LabelDamTakenValue:SetText(       math.floor(PvpMeter.nbrTaken/PvpMeter.BGPlayed) .. "k"  )
  end


  LabelDMValue:SetText(PvpMeter.nbrDM )
  LabelCTRValue:SetText(PvpMeter.nbrCTR)
  LabelDOMValue:SetText(PvpMeter.nbrDOM)
  LabelMURValue:SetText(PvpMeter.nbrMUR)
  LabelCRZValue:SetText(PvpMeter.nbrCRZ)

  if(PvpMeter.BGPlayed > 0)then
    BGPvpMeter.DoStatKill((PvpMeter.nbrKill/PvpMeter.BGPlayed),(PvpMeter.nbrAssist/PvpMeter.BGPlayed),(PvpMeter.nbrDone/PvpMeter.BGPlayed))
    BGPvpMeter.DoStatHeal(PvpMeter.nbrHeal/PvpMeter.BGPlayed)
    BGPvpMeter.DoStatTank((PvpMeter.nbrDeath/PvpMeter.BGPlayed),(PvpMeter.nbrTaken/PvpMeter.BGPlayed))
  end

end


function BGPvpMeter.show2()

  HUDMenuMeter_show()
  HUDMenuMeter_restore(15,-140)

  local endd = 0

  if(PvpMeter.savedVariables.BGPlayed == 0)then
    endd = 1
  else
    endd = PvpMeter.savedVariables.BGWin / PvpMeter.savedVariables.BGPlayed
  end


  HUDMenuMeter_Update(0 ,endd)

  LabelPlayedValue:SetText(PvpMeter.savedVariables.BGPlayed)
  LabelWinValue:SetText(PvpMeter.savedVariables.BGWin)
  LabelLooseValue:SetText(PvpMeter.savedVariables.BGPlayed-PvpMeter.savedVariables.BGWin)


  ScrollListBG:SetHidden(false)


  local nbrDM = 0
  local nbrCTR = 0
  local nbrDOM = 0
  local nbrMUR = 0

  local nbrDMWin = 0
  local nbrCTRWin = 0
  local nbrDOMWin = 0
  local nbrMURWin = 0


  SLE.reset()
  PvpMeter.displayBGList = 1

    local deb = 0
    local fin = 0

    if(PvpMeter.BGPlayed%50==0)then
      deb = ( (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50))-((PvpMeter.page)*50)) + 1
      fin = ( (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50))-((PvpMeter.page)*50))+50
    else
      if( (PvpMeter.page>1 ))then
        deb = ( (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50))-((PvpMeter.page-1)*50)) + 1
        fin = ( (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50))-((PvpMeter.page-1)*50))+50
      else
        deb = (PvpMeter.BGPlayed-(PvpMeter.BGPlayed%50)) +1
        fin = PvpMeter.BGPlayed
      end
    end

    if(PvpMeter.BGPlayed==0)then
      return
    end

    for i=deb,fin do

      --if(PvpMeter.BGlist[zo_strformat("<<1>>", i)] == nil )then return end

      PvpMeter.displayBGList = PvpMeter.displayBGList + 1

      local targetRace = 0

      if( PvpMeter.BGlist[zo_strformat("<<1>>", i)].alliance ~= nil)then
        targetRace = PvpMeter.BGlist[zo_strformat("<<1>>", i)].alliance
      else
        targetRace = math.random(3)
        PvpMeter.savedVariables.BGlist[zo_strformat("<<1>>", i)].alliance = targetRace
        PvpMeter.savedVariables.BGlist[zo_strformat("<<1>>", i)].alliance = targetRace

      end

      local winn = false
      if( tonumber(PvpMeter.BGlist[zo_strformat("<<1>>", i)].score) >= 500) then
        winn = true
      else
        winn = false
      end

      local targetType = PvpMeter.BGlist[zo_strformat("<<1>>", i)].typeOfBG

      if(targetType == 1)then targetType="CTR"
        nbrCTR = nbrCTR + 1
        if(winn)then
          nbrCTRWin = nbrCTRWin + 1
        end

      end
      if(targetType == 2)then targetType="DM"
        nbrDM = nbrDM + 1
        if(winn)then
          nbrDMWin = nbrDMWin + 1
        end
      end
      if(targetType == 3)then targetType="KNG" end
      if(targetType == 4)then targetType="DOM"
        nbrDOM = nbrDOM + 1
        if(winn)then
          nbrDOMWin = nbrDOMWin + 1
        end
      end
      if(targetType == 5)then targetType="CRZ" end
      if(targetType == 6)then targetType="BAL"
        nbrMUR = nbrMUR + 1
        if(winn)then
          nbrMURWin = nbrMURWin + 1
        end
      end

      local targetClass = PvpMeter.BGlist[zo_strformat("<<1>>", i)].score
      local targetZone = PvpMeter.BGlist[zo_strformat("<<1>>", i)].medal
      local targetKill = PvpMeter.BGlist[zo_strformat("<<1>>", i)].kill
      local targetDeath = PvpMeter.BGlist[zo_strformat("<<1>>", i)].death
      local targetAssist = PvpMeter.BGlist[zo_strformat("<<1>>", i)].assist
      local targetDamd = math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].damageDone/1000) .. "k"
      local targetHeal = math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].healDone/1000) .. "k"
      local targetDamt = math.floor(PvpMeter.BGlist[zo_strformat("<<1>>", i)].damageTaken/1000) .. "k"

      SLE.TrackUnit(targetRace,targetType,targetClass,targetZone,targetKill,targetDeath,targetAssist,targetDamd, targetHeal,targetDamt)

    end

  BGPvpMeter.showStatBG()
  SLE.alignementBG()
end


function BGPvpMeter.DoStatKill(statKill,statAssist,statDone)
  local res = 0

  if(statKill>8)then res = res +1 end
  if(statKill>5)then res = res +1 end
  if(statAssist>8)then res = res +1 end
  if(statAssist>5)then res = res +1 end
  if(statDone>400)then res = res +1 end

  --d(res .. "Dps")

  if(res == 5)then
    iconDpsB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconDpsB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconDpsB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
  elseif(res > 2)then
    iconDpsB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconDpsB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconDpsB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
  else
    iconDpsB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconDpsB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconDpsB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
  end

end


function BGPvpMeter.DoStatHeal(statHeal)

  local res = statHeal/100
  --d(res .. "heal")

  if(res>2)then
    iconHealB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconHealB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconHealB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
  elseif(res>1)then
    iconHealB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconHealB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconHealB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
  else
    iconHealB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconHealB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconHealB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
  end
end


function BGPvpMeter.DoStatTank(statDeath,statTaken)
  local res = statDeath / (statTaken/100)
  --d(res .. "tank")

  if(res<0.5)then
    iconTankB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconTankB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconTankB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
  elseif(res<1.0)then
    iconTankB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconTankB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconTankB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
  else
    iconTankB1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconTankB2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconTankB3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
  end
end


function BGPvpMeter.hide()
  if(SCENE_MANAGER:IsShowing("PvpmeterduelScene") == false)then
    HUDMenuMeter_hide()
    ScrollListBG:SetHidden(true)
  end
end