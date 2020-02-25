DuelPvpMeter = {}

function DuelPvpMeter:Initialize()
  ZO_CreateStringId("SI_PVPMETER_INRANGE_MENU_TITLE", "Duels")

  self.iconData = {
    categoryName = SI_PVPMETER_INRANGE_MENU_TITLE,
    descriptor = "PvpmeterduelScene",
    normal = "EsoUI/Art/journal/journal_tabicon_leaderboard_up.dds",
    pressed = "EsoUI/Art/journal/journal_tabicon_leaderboard_down.dds",
    highlight = "EsoUI/Art/journal/journal_tabicon_leaderboard_over.dds",
    callback = function()

    end,
  }
  MenuPvpMeter:Register(self.iconData)

  self:CreateControls()
  self:InitializeScene()
end


function DuelPvpMeter:InitializeScene()
  self.scene = ZO_Scene:New("PvpmeterduelScene", SCENE_MANAGER)

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
  local MAIN_WINDOW = ZO_FadeSceneFragment:New(PvpMeterMenuDuel)
  self.scene:AddFragment(MAIN_WINDOW)

  self.scene:AddFragment(MAIN_MENU_KEYBOARD.categoryBarFragment)
  self.scene:AddFragment(TOP_BAR_FRAGMENT)

end


function DuelPvpMeter:CreateControls()
  PvpMeterMenuDuel.panel = PvpMeterMenuDuel
  PvpMeterMenuDuel.panel.data = {registerForRefresh = true}
  PvpMeterMenuDuel.panel.controlsToRefresh = {}
end


function DuelPvpMeter.init()
  if(PvpMeter.statLoaded==false)then
    for i=1,PvpMeter.duelPlayed do

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].done ~=nil)then
        PvpMeter.DnbrDone = PvpMeter.DnbrDone + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].done/1000)
      end

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken ~=nil)then
        PvpMeter.DnbrTaken = PvpMeter.DnbrTaken + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken/1000)
      end

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal ~=nil)then
        PvpMeter.DnbrHeal = PvpMeter.DnbrHeal  + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal/1000)
      end


      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].block ~=nil)then
        PvpMeter.DnbrBlock = PvpMeter.DnbrBlock + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].block/1000)
      end

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield ~=nil)then
        PvpMeter.DnbrShield = PvpMeter.DnbrShield + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield/1000)
      end


      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge ~=nil)then
        PvpMeter.DnbrDodge = PvpMeter.DnbrDodge + PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge
      end

    end
  end
end


function DuelPvpMeter.updateStat()
    for i=PvpMeter.duelPlayed,PvpMeter.duelPlayed do

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].done ~=nil)then
        PvpMeter.DnbrDone = PvpMeter.DnbrDone + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].done/1000)
      end

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken ~=nil)then
        PvpMeter.DnbrTaken = PvpMeter.DnbrTaken + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken/1000)
      end

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal ~=nil)then
        PvpMeter.DnbrHeal = PvpMeter.DnbrHeal  + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal/1000)
      end


      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].block ~=nil)then
        PvpMeter.DnbrBlock = PvpMeter.DnbrBlock + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].block/1000)
      end

      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield ~=nil)then
        PvpMeter.DnbrShield = PvpMeter.DnbrShield + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield/1000)
      end


      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge ~=nil)then
        PvpMeter.DnbrDodge = PvpMeter.DnbrDodge + PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge
      end

    end
end

function DuelPvpMeter.showStatDuel()

  HUDMenuMeter_show()
  HUDMenuMeter_restore(10,-95)

  local endd = 0
  if(PvpMeter.savedVariables.duelWin== nil)then
    PvpMeter.savedVariables.duelWin = 0
  end

  if(PvpMeter.savedVariables.duelPlayed == nil or PvpMeter.savedVariables.duelPlayed == 0)then
    PvpMeter.savedVariables.duelPlayed = 0
    endd = 1
  else
    endd = PvpMeter.savedVariables.duelWin / PvpMeter.savedVariables.duelPlayed
  end

  HUDMenuMeter_Update(0 ,endd)

  LabelPlayedValueDuel:SetText(PvpMeter.savedVariables.duelPlayed)
  LabelWinValueDuel:SetText(PvpMeter.savedVariables.duelWin)
  LabelLooseValueDuel:SetText(PvpMeter.savedVariables.duelPlayed-PvpMeter.savedVariables.duelWin)

  LabelTotalKillValueDuel:SetText(0)
  LabelTotalDeathValueDuel:SetText(0)

  if(PvpMeter.savedVariables.bgDeath==0)then
    LabelRatioValueDuel:SetText(0)
  else
    LabelRatioValueDuel:SetText(0)
  end

  ScrollListBG:SetHidden(false)


  if(PvpMeter.duelPlayed == 0)then
    LabeTotalKillValue:SetText(      0 .. "k"  )
    LabeTotalDeathValue:SetText(          0  .. "k"  )
    LabeRatioValue:SetText(       0 .. "k"  )

    LabeDamValue:SetText(      0 .. "k"  )
    LabeHealingValue:SetText(     0  .. "k"  )
    LabeDamTakenValue:SetText(       0  )

  else
    LabeTotalKillValue:SetText(      math.ceil(PvpMeter.DnbrDone/PvpMeter.duelPlayed) .. "k"  )
    LabeTotalDeathValue:SetText(          math.ceil(PvpMeter.DnbrHeal/PvpMeter.duelPlayed)  .. "k"  )
    LabeRatioValue:SetText(       math.ceil(PvpMeter.DnbrTaken/PvpMeter.duelPlayed) .. "k"  )

    LabeDamValue:SetText(      math.ceil(PvpMeter.DnbrBlock/PvpMeter.duelPlayed) .. "k"  )
    LabeHealingValue:SetText(     math.ceil(PvpMeter.DnbrShield/PvpMeter.duelPlayed)  .. "k"  )
    LabeDamTakenValue:SetText(       math.ceil(PvpMeter.DnbrDodge/PvpMeter.duelPlayed)  )
  end

  if(PvpMeter.duelPlayed>0)then
    DuelPvpMeter.DoStatKill((PvpMeter.DnbrTaken/PvpMeter.duelPlayed),(PvpMeter.DnbrDone/PvpMeter.duelPlayed))
    DuelPvpMeter.DoStatHeal((PvpMeter.DnbrHeal/PvpMeter.duelPlayed),(PvpMeter.DnbrTaken/PvpMeter.duelPlayed))
    DuelPvpMeter.DoStatTank((PvpMeter.DnbrShield/PvpMeter.duelPlayed),(PvpMeter.DnbrTaken/PvpMeter.duelPlayed),(PvpMeter.DnbrBlock/PvpMeter.duelPlayed))
  end

  SLE.alignementDuel()
end


function DuelPvpMeter.show2()

  --HUDMenuMeter_show()
  HUDMenuMeter_show()
  HUDMenuMeter_restore(10,-95)

  local endd = 0
  if(PvpMeter.savedVariables.duelWin== nil)then
    PvpMeter.savedVariables.duelWin = 0
  end

  if(PvpMeter.savedVariables.duelPlayed == nil or PvpMeter.savedVariables.duelPlayed == 0)then
    PvpMeter.savedVariables.duelPlayed = 0
    endd = 1
  else
    endd = PvpMeter.savedVariables.duelWin / PvpMeter.savedVariables.duelPlayed
  end


  HUDMenuMeter_Update(0 ,endd)

  LabelPlayedValueDuel:SetText(PvpMeter.savedVariables.duelPlayed)
  LabelWinValueDuel:SetText(PvpMeter.savedVariables.duelWin)
  LabelLooseValueDuel:SetText(PvpMeter.savedVariables.duelPlayed-PvpMeter.savedVariables.duelWin)

  LabelTotalKillValueDuel:SetText(0)
  LabelTotalDeathValueDuel:SetText(0)

  if(PvpMeter.savedVariables.bgDeath==0)then
    LabelRatioValueDuel:SetText(0)
  else
    LabelRatioValueDuel:SetText(0)
  end

  ScrollListBG:SetHidden(false)

  PvpMeter.displayDuelList = 1
  SLE.reset()

  local deb = 0
    local fin = 0

    if(PvpMeter.duelPlayed%50==0)then
      deb = ( (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50))-((PvpMeter.pageD)*50)) + 1
      fin = ( (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50))-((PvpMeter.pageD)*50))+50
    else
      if( (PvpMeter.pageD>1 ))then
        deb = ( (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50))-((PvpMeter.pageD-1)*50)) + 1
        fin = ( (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50))-((PvpMeter.pageD-1)*50))+50
      else
        deb = (PvpMeter.duelPlayed-(PvpMeter.duelPlayed%50)) +1
        fin = PvpMeter.duelPlayed
      end
    end

    if(PvpMeter.duelPlayed==0)then
      return
    end

  -- scroll list
  --if(PvpMeter.displayDuelList <= PvpMeter.duelPlayed)then
    for i=deb,fin do

      --if(PvpMeter.duelList[zo_strformat("<<1>>", i)] == nil )then return end

      PvpMeter.displayDuelList = PvpMeter.displayDuelList + 1

      local targetRace = 0

      if( PvpMeter.duelList[zo_strformat("<<1>>", i)].win ~= nil)then
        targetRace = PvpMeter.duelList[zo_strformat("<<1>>", i)].win
      else
        targetRace = math.random(3)
      end

      --[[if( tonumber(PvpMeter.duelList[zo_strformat("<<1>>", i)].score) >= 500) then
        targetRace = "Win"
      else
        targetRace = "Loose"
      end]]

      local targetType = zo_strformat("<<!aC:1>>",PvpMeter.duelList[zo_strformat("<<1>>", i)].name)

      local gender = 1
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].gender ~=nil)then
        gender = PvpMeter.duelList[zo_strformat("<<1>>", i)].gender
      end


      local targetClass = PvpMeter.duelList[zo_strformat("<<1>>", i)].class
      local className = zo_strformat("<<!aC:1>>",GetClassName(gender,PvpMeter.duelList[zo_strformat("<<1>>", i)].class))

      local targetZone = zo_strformat("<<!aC:1>>",GetRaceName(gender,PvpMeter.duelList[zo_strformat("<<1>>", i)].race))

      local targetKill = ""
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].done ~=nil)then
        targetKill = math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].done/1000) .. "k"
        --nbrDone = nbrDone + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].done/1000)

      end

      local targetDeath = ""
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken ~=nil)then
        targetDeath = math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken/1000) .. "k"
        --nbrTaken = nbrTaken + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].taken/1000)

      end

      local targetAssist = ""
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal ~=nil)then
        targetAssist = math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal/1000) .. "k"
        --nbrHeal = nbrHeal  + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].heal/1000)

      end

      local targetDamd = ""
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].block ~=nil)then
        targetDamd = math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].block/1000) .. "k"
        --nbrBlock = nbrBlock + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].block/1000)

      end

      local targetHeal = ""
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield ~=nil)then
        targetHeal = math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield/1000) .. "k"
        --nbrShield = nbrShield + math.ceil(PvpMeter.duelList[zo_strformat("<<1>>", i)].shield/1000)

      end

      local targetDamt = ""
      if(PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge ~=nil)then
        targetDamt = PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge
        --nbrDodge = nbrDodge + PvpMeter.duelList[zo_strformat("<<1>>", i)].dodge
      end

      SLE.TrackUnit(targetType,targetRace,targetClass,targetZone,targetKill,targetDeath,targetAssist,targetDamd, targetHeal,targetDamt)
    end
  --end

  DuelPvpMeter.showStatDuel()
  SLE.alignementDuel()
end


function DuelPvpMeter.DoStatKill(statTaken,statDone)
  if(statDone > statTaken)then
    iconDpsBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconDpsBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconDpsBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
  elseif(statDone > (statTaken/2))then
    iconDpsBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconDpsBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconDpsBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
  else
    iconDpsBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconDpsBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconDpsBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
  end
end

function DuelPvpMeter.DoStatHeal(statHeal,statTaken)
  if(statHeal> (statTaken/1.5))then
    iconHealBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconHealBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconHealBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
  elseif(statHeal> (statTaken/2))then
    iconHealBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconHealBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconHealBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
  else
    iconHealBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconHealBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconHealBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
  end
end


function DuelPvpMeter.DoStatTank(statShield,statTaken,statBlock)
  local res = statBlock + statShield

  if(res > (statTaken*0.6))then
    iconTankBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconTankBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
    iconTankBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full_gold.dds")
  elseif(res > (statTaken*0.4))then
    iconTankBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconTankBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
    iconTankBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
  else
    iconTankBG1:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconTankBG2:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
    iconTankBG3:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_empty.dds")
  end
end


function DuelPvpMeter.hide()
  if(SCENE_MANAGER:IsShowing("PvpmeterBGScene") == false)then
    HUDMenuMeter_hide()
    ScrollListBG:SetHidden(true)
  end
end