-- This file contains all events, calulcations and storage.
-- this is the primary file and loaded first by ESO 
-- the function PvpMeter:Initialize is ran first

-- Inital defination of Addon
PvpMeter = {}
PvpMeter.name = "PvpMeter"

-- NOTE Loads of If end IF instead of elseif

function PvpMeter:Initialize(PvpMeterLabelKill)

  -- Loads and stores Addon data
  self.savedVariables = ZO_SavedVars:New("PvpMeterSavedVariables", 1, nil,{})

  -- Currently no Account wide settings, could be re-introduced for account wide settings
  -- self.savedVariablesAw = ZO_SavedVars:NewAccountWide("PvpMeterSavedVariables", 1, nil,{})

  self.initSettings()

  -- TODO Change these, functions should handle nil variables rather then
  -- checking them everytime and resettig them
  if(self.savedVariables.hideMenu == nil)then
    self.savedVariables.hideMenu = true
  end

  if(self.savedVariables.rotation == nil)then
    self.savedVariables.rotation = 1
  end

  if(self.savedVariables.quickButton == nil)then
    self.savedVariables.quickButton = true
  end

  if(self.savedVariables.autoqueue == nil)then
    self.savedVariables.autoqueue = false
  end

  if(self.savedVariables.duelMeter == nil)then
    self.savedVariables.duelMeter = false
  end

  if(self.savedVariables.playSound == nil)then
    self.savedVariables.playSound = true
  end

  if(self.savedVariables.alertBorder == nil)then
    self.savedVariables.alertBorder = true
  end

  if(self.savedVariables.nbrSound == nil)then
    self.savedVariables.nbrSound = 0
  end

  if(self.savedVariables.v3 == nil)then
    self.savedVariables.v3 = true
    self.savedVariables.nbrCyro = 2
  end

  if(self.savedVariables.nbrCyro == nil)then
    self.savedVariables.nbrCyro = 2
  end

  if(self.savedVariables.showBeautifulMeter == nil)then
    self.savedVariables.showBeautifulMeter = true
  end

  if(self.savedVariables.BGAssist == nil)then
    self.savedVariables.BGAssist = false
  end

  if(self.savedVariables.top == nil)then
    self.savedVariables.top = 952
  end

  if(self.savedVariables.left == nil)then
    self.savedVariables.left = 1664
  end

  if(self.savedVariables.cyroKill == nil)then
    self.savedVariables.cyroKill = 0
  end

  if(self.savedVariables.cyroDeath == nil)then
    self.savedVariables.cyroDeath = 0
  end

  if(self.savedVariables.bgKill == nil)then
    self.savedVariables.bgKill = 0
  end

  if(self.savedVariables.bgDeath == nil)then
    self.savedVariables.bgDeath = 0
  end

  if(self.savedVariables.verbg == nil)then
    self.savedVariables.BGlist = {}
    self.savedVariables.bgKill = 0
    self.savedVariables.bgDeath = 0
    self.savedVariables.BGWin = 0
    self.savedVariables.BGPlayed = 0
    self.savedVariables.verbg = true
  end

  if(self.savedVariables.verduel == nil)then
    self.savedVariables.duellist = {}
    self.savedVariables.duelMeter = false
    self.savedVariables.duelWin = 0
    self.savedVariables.duelPlayed = 0
    self.savedVariables.verduel = true
  end

  if(self.savedVariables.currAP == nil)then
    self.savedVariables.currAP = false
  end

  self.PvpMeterLabelKill = PvpMeterLabelKill

  self.statLoaded = false

  self.nbrDeath = 0
  self.nbrTaken = 0
  self.nbrHeal = 0
  self.nbrKill = 0
  self.nbrAssist = 0
  self.nbrDone = 0

  self.nbrDM = 0
  self.nbrCTR = 0
  self.nbrDOM = 0
  self.nbrMUR = 0
  self.nbrCRZ = 0

  self.nbrDMWin = 0
  self.nbrCTRWin = 0
  self.nbrDOMWin = 0
  self.nbrMURWin = 0
  self.nbrCRZWin = 0

  self.DnbrTaken = 0
  self.DnbrShield = 0
  self.DnbrBlock = 0
  self.DnbrDodge = 0
  self.DnbrHeal = 0
  self.DnbrDone = 0

  self.medalR = 0
  self.killR = 0
  self.deathR = 0

  self.inCombat = IsUnitInCombat("player")
  self.inAvA = IsPlayerInAvAWorld()
  self.inIC = IsInImperialCity()
  self.AP = GetAlliancePoints()
  self.currAP = 0
  self.kills = 0
  self.assistBG = 0
  self.killsCoef = 0
  self.death = 0
  self.inBG = IsActiveWorldBattleground()
  self.alliance = 0
  self.isHide = false
  self.lastAP = 0
  self.lastPercentKeep = 0
  self.allianceKill = 0
  self.allianceDeath = 0
  self.allianceMedal = 0
  self.allianceLastScore = 0
  self.allianceScore = 0
  self.displayBGList = 1
  self.displayDuelList = 1

  self.switch = 0
  self.dye =  false

  self.iBG = 1
  self.page = 1

  self.pageD = 1

  self.BGPlayed = 0
  self.BGWin = 0
  self.BGlist = {}

  self.duelRunning = false

  self.totalDone = 0
  self.totalTaken = 0
  self.totalHeal = 0
  self.totalBlock = 0
  self.totalShield = 0
  self.totalDodge = 0

  self.duelPlayed = 0
  self.duelWin = 0
  self.duelList = {}

  CreateControl("ControlName",LabelKill,CT_LABEL)

  if(self.savedVariables.hideMenu) then
    MenuPvpMeter:Initialize()
    BGPvpMeter:Initialize()
    DuelPvpMeter:Initialize()
    MenuPvpMeter:Finalize()
  end

  -- Creates the event variables used to run actions on game changes

  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

  --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_FOCUS_CHANGED, self.focus)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ALLIANCE_POINT_UPDATE, self.OnAPUpdate)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnKill)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEAD, self.OnDeath)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED   , self.UIswitch)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED ,self.zoneChange)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED   , self.gamepad)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.openBank)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE, self.openBank)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_TRADING_HOUSE, self.openBank)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_GUILD_BANK, self.openBank)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, self.openBank)


  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MEDAL_AWARDED, self.onPointUpdate)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED , self.onScoreUpdate)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DYEING_STATION_INTERACT_START, self.onDyeStart)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DYEING_STATION_INTERACT_END, self.onDyeEnd)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_FINISHED , self.onDuelFinish)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_STARTED , self.onDuelStart)

  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_GAME_CAMERA_CHARACTER_FRAMING_STARTED ,self.UIchange)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_KEEP_ALLIANCE_OWNER_CHANGED,self.updateMeter)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_BATTLEGROUND_KILL ,self.bgkill)

  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CAMPAIGN_QUEUE_JOINED ,self.queue_joined)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CAMPAIGN_QUEUE_LEFT  ,self.queue_left)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED  ,self.queue_position)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CAMPAIGN_QUEUE_STATE_CHANGED ,self.queue_state)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, self.onActivityFinderStatusUpdate)
end


function PvpMeter.resetDataBG()
  PvpMeter.savedVariables.BGlist = {}
  PvpMeter.BGlist = {}
  PvpMeter.savedVariables.bgKill = 0
  PvpMeter.savedVariables.bgDeath = 0
  PvpMeter.savedVariables.BGWin = 0
  PvpMeter.savedVariables.BGPlayed = 0
  ReloadUI()
end

function PvpMeter.resetDataDuel()
  PvpMeter.savedVariables.duelList = {}
  PvpMeter.duelList = {}
  PvpMeter.savedVariables.duelMeter = false
  PvpMeter.savedVariables.duelWin = 0
  PvpMeter.savedVariables.duelPlayed = 0
  PvpMeter.savedVariables.verduel = true
  ReloadUI()
end

function PvpMeter.gamepad(event, opt)
  PvpMeter.zoneChange(event,"qdq","qdq","qdq",0,0)

  --PvpMeter:Initialize()
  PvpMeter.updateAP()
  PvpMeter.updateKills()
  PvpMeter.updateDeath()
  --PvpMeter.hideCyro()
  PvpMeter.updateKillsBG()
  PvpMeter.updateDeathBG()
  PvpMeter.updateMedal()
  PvpMeter.updateMeter()
  --PvpMeter:initSettings()

end

-- NOTE Main function which runs on addon load. Location unknown, LUA function declartion issue?
function PvpMeter.OnAddOnLoaded(event, addonName)
  if addonName == PvpMeter.name then

    PvpMeter:Initialize()

    PvpMeter.updateAP()
    PvpMeter.updateKills()
    PvpMeter.updateDeath()
    PvpMeter.hideCyro()
    PvpMeter.updateKillsBG()
    PvpMeter.updateDeathBG()
    PvpMeter.updateMedal()
    PvpMeter.updateMeter()
    PvpMeter.prepareQuickButton()
    PvpMeter.updateButtonQuick()

    --SLEDUEL.Init()
    SLE.Init()

  end
end

-- NOTE Why not in the init function? 
EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_ADD_ON_LOADED, PvpMeter.OnAddOnLoaded)

function PvpMeter.hideCyro()
    HUDTelvarMeter_hide()
    PvpMeterIndicator:SetHidden(true)
    PvpMeterIndicr:SetHidden(true)
    myAtor:SetHidden(true)
    PvpMeterInd:SetHidden(true)

    Glow:SetHidden(true)
    LabelAP:SetHidden(true)
    APicon:SetHidden(true)
    LabelKill:SetHidden(true)
    LabelDeath:SetHidden(true)

    --HUDTelvarMeter_alpha(0.0)
end

function PvpMeter.showCyro()
  if(PvpMeter.savedVariables.showBeautifulMeter)then
    if(PvpMeter.inAvA) then
      HUDTelvarMeter_color(0,0.78,0.09)--HUDTelvarMeter_color(0.2,0.31,0.12)
      HUDTelvarMeter_colorAlert(0.15,0.93,0.12)
      PvpMeterIndicator:SetHidden(false)
      PvpMeterIndicr:SetHidden(false)
      myAtor:SetHidden(false)
      PvpMeterInd:SetHidden(false)

      Glow:SetHidden(false)
      LabelAP:SetHidden(false)
      APicon:SetHidden(false)
      LabelKill:SetHidden(false)

      LabelDeath:SetHidden(false)
      HUDInfamyMeter_hide()
      --HUDTelvarMeter_alpha(1.0)

    end
  else
    HUDTelvarMeter_hide()
  end
end

function PvpMeter.hideBG()
  frameBG:SetHidden(true)
  medailBG:SetHidden(true)
  iconBG:SetHidden(true)
  killBG:SetHidden(true)
  --PvpMeterInd:SetHidden(true)

  Gl:SetHidden(true)
  LabelMedal:SetHidden(true)
  scoreIcon:SetHidden(true)
  LabelKillBG:SetHidden(true)

  LabelAssist:SetHidden(true)
  LabelDeathBG:SetHidden(true)
end

function PvpMeter.showBG()
  if(PvpMeter.savedVariables.showBeautifulMeter)then
    frameBG:SetHidden(false)
    medailBG:SetHidden(false)
    iconBG:SetHidden(false)
    killBG:SetHidden(false)

    Gl:SetHidden(false)
    LabelMedal:SetHidden(false)
    scoreIcon:SetHidden(false)
    LabelKillBG:SetHidden(false)
    if(PvpMeter.savedVariables.BGAssist == true)then
      LabelAssist:SetHidden(false)
    end
    LabelDeathBG:SetHidden(false)
    HUDInfamyMeter_hide()
  else
    HUDTelvarMeter_hide()
  end
end

function PvpMeter.UIchange(eventCode)

  PvpMeter.inAvA = IsPlayerInAvAWorld()
  HUDInfamyMeter_hide()
  if( PvpMeter.inAvA) then
    PvpMeter.hideCyro()
  end

  if(PvpMeter.inBG) then
    PvpMeter.hideBG()
  end

  HUDTelvarMeter_hide()
end

function PvpMeter.UIswitch(eventCode)
  PvpMeter.switch = PvpMeter.switch+1

  if(ZO_WorldMap_IsWorldMapShowing() or GetCraftingInteractionType()~=0  or  PvpMeter.dye ) then
    PvpMeter.dye = false
    PvpMeter.inAvA = IsPlayerInAvAWorld()
    HUDInfamyMeter_hide()

    if( PvpMeter.inAvA) then
      PvpMeter.hideCyro()
    end

    if(PvpMeter.inBG) then
      PvpMeter.hideBG()
    end
    --HUDTelvarMeter_show()
  else
    PvpMeter.inAvA = IsPlayerInAvAWorld()
    if (PvpMeter.savedVariables.duelMeter ) then
      HUDInfamyMeter_show()
    else
      HUDInfamyMeter_hide()
    end

    if( PvpMeter.inAvA) then
      PvpMeter.showCyro()
      HUDInfamyMeter_hide()
    end

    if(PvpMeter.inBG) then
      PvpMeter.showBG()
      HUDInfamyMeter_hide()
    end

    HUDTelvarMeter_show()
  end

end

function PvpMeter.zoneChange(eventCode,zoneName,subZoneName,newSubzone, zoneId,ubZoneId)
  LabelPMenu:SetHidden(true)
  PercMenu:SetHidden(true)


  PvpMeter.inAvA = IsPlayerInAvAWorld()
  PvpMeter.inIC = IsInImperialCity()
  PvpMeter.inBG = IsActiveWorldBattleground()

  if(PvpMeter.inAvA) then
    PvpMeter.showCyro()
  else
    PvpMeter.hideCyro()
  end

  if(PvpMeter.inBG) then
    PvpMeter.alliance = GetUnitBattlegroundAlliance("player")
    --d(GetBattlegroundAllianceName(GetUnitBattlegroundAlliance("player")))
    PvpMeter.changeColor()
    PvpMeter.showBG()
    PvpMeter.hideCyro()
    PvpMeter.updateKillsBG()
    PvpMeter.updateDeathBG()
    PvpMeter.updateMedal()
  else
    PvpMeter.hideBG()
    PvpMeter.alliance = 0
    PvpMeter.allianceKill = 0
    PvpMeter.allianceDeath = 0
    PvpMeter.assistBG = 0
    PvpMeter.allianceMedal = 0
    PvpMeter.allianceScore = 0

  end

  if (PvpMeter.savedVariables.duelMeter ) then
    HUDInfamyMeter_show()
  else
    HUDInfamyMeter_hide()
  end

  if(PvpMeter.inAvA or PvpMeter.inBG) then
    --d("hide")
    HUDTelvarMeter_show()
    HUDInfamyMeter_hide()
  else
    --d("show")
    HUDTelvarMeter_hide()
  end

  --
  --PvpMeter.changeColor()
  --
  PvpMeter.restore()

  PvpMeter.updateMeter()
  PvpMeter.rotateMeter(PvpMeter.savedVariables.rotation)
  PvpMeter.updateMeterDuel()
  BGPvpMeter.init()
  DuelPvpMeter.init()
  PvpMeter.statLoaded = true
  PvpMeterNumPageDuel:SetText("1/"..math.ceil(PvpMeter.duelPlayed /50))
  PvpMeterNumPageBG:SetText("1/"..math.ceil(PvpMeter.BGPlayed/50))
  --

end


function PvpMeter.OnAPUpdate(event, nbAP, playSound, difference)
  PvpMeter.AP = nbAP
  PvpMeter.currAP = PvpMeter.currAP + difference
  --PlaySound(SOUNDS.ALLIANCE_POINT_TRANSACT)

  --d(PvpMeter.AP)
  PvpMeter.updateAP()
  PvpMeter.updateMeter()
end


--function PvpMeter.OnKill(eventCode , result , isError , abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )
function PvpMeter.OnKill(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

  if ( isError ) then
    return
  end

  if result == ACTION_RESULT_KILLING_BLOW and sourceType == COMBAT_UNIT_TYPE_PLAYER and GetUnitName("player") == zo_strformat("<<1>>", sourceName) and abilityName ~= "" then

    if( PvpMeter.inAvA) then

      --d(sourceName)
      --d(targetName)
      if( sourceName == targetName)then return end

      --d(-sourceName)
      --d(targetName)
      --d(GetKillingAttackInfo())
      --d(GetKillingAttackerInfo())

      --d(targetUnitId)
      --d(abilityName)
      --d(GetUnitAlliance(targetUnitId))
      --d(GetUnitAvARankPoints(targetUnitId))
      --d(GetUnitRace(targetUnitId))
      --d(GetUnitClass(targetUnitId))

      PvpMeter.kills = PvpMeter.kills + 1
      PvpMeter.savedVariables.cyroKill = PvpMeter.savedVariables.cyroKill + 1
      -- PlaySound
      --PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
      if(PvpMeter.savedVariables.playSound == true)then

        if(PvpMeter.savedVariables.nbrSound == 0)then
          PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
        end
        if(PvpMeter.savedVariables.nbrSound == 1)then
          PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
        end
      end
      PvpMeter.updateKills()
    end

  --elseif(sourceType == COMBAT_UNIT_TYPE_PLAYER and GetUnitName("player") == zo_strformat("<<1>>", sourceName) and
  -- GetUnitName("player") ~= zo_strformat("<<1>>", targetName) and hitValue > 0 and result ~= ACTION_RESULT_KILLING_BLOW) then
    --PvpMeter.assistCyro = PvpMeter.assistCyro + 1
    --LabelAssist:SetText(PvpMeter.assistCyro)

  end

  if(PvpMeter.duelRunning == true)then
    PvpMeter.OnDuelStat( result , abilityName , abilityGraphic , abilityActionSlotType , sourceName , sourceType , targetName , targetType , hitValue , powerType , damageType )
  end

end


function PvpMeter.OnDuelStat(result , abilityName , abilityGraphic , abilityActionSlotType , sourceName , sourceType , targetName , targetType , hitValue , powerType , damageType )
    -- ty FTC (damage/fonction.lua)

    local incomeDamage = false
    local player = zo_strformat("<<!aC:1>>",targetName)
    local me = false
    if ( sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET ) then incomeDamage = true
        --elseif ( target == player ) then incomeDamage = false
        end

    if(GetUnitName("player") == player)then
      me = true
    end

      --d( result .. " || " .. sourceType .. " || " .. sourceName .. " || " .. targetName .. " || " .. abilityName .. " || " .. hitValue  )

    if ( hitValue > 0 and ( result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL ) ) then

      if(incomeDamage == false)then
        -- damage taken
        if(abilityName ~= "")then
          --d("income " .. abilityName .. " -- " .. hitValue)
          PvpMeter.totalTaken = PvpMeter.totalTaken + hitValue
        end
      else
        -- damage done
        --d("done " .. abilityName .. " -- " .. hitValue)
        PvpMeter.totalDone = PvpMeter.totalDone + hitValue
      end

      if(result == ACTION_RESULT_BLOCKED_DAMAGE and me == true)then
        -- blocked
        --d("blocked " .. abilityName .. " -- " .. hitValue)
        PvpMeter.totalBlock = PvpMeter.totalBlock + hitValue
      end

    elseif ( result == ACTION_RESULT_DAMAGE_SHIELDED and me == true) then
      -- absorb
      --d("shielded " .. abilityName .. " -- " .. hitValue)
      PvpMeter.totalShield = PvpMeter.totalShield + hitValue
    end

    if((result == ACTION_RESULT_DODGED or result == ACTION_RESULT_MISS) and incomeDamage == false)then
      -- dodged
      --d("dodged " .. abilityName .. " -- " .. hitValue)
      PvpMeter.totalDodge = PvpMeter.totalDodge + 1
    end

    if ( me == true and hitValue > 0 and ( result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HOT_TICK_CRITICAL ) ) then
      -- heal
      --d("heal " .. abilityName .. " -- " .. hitValue)
      PvpMeter.totalHeal = PvpMeter.totalHeal + hitValue
    end

end


function PvpMeter.OnDeath(eventCode)
  if( PvpMeter.inAvA) then
    PvpMeter.death = PvpMeter.death + 1
    PvpMeter.savedVariables.cyroDeath = PvpMeter.savedVariables.cyroDeath + 1
    PvpMeter.updateDeath()
  end

  if(PvpMeter.inBG) then
    PvpMeter.allianceDeath = PvpMeter.allianceDeath + 1
    PvpMeter.savedVariables.bgDeath = PvpMeter.savedVariables.bgDeath + 1
    PvpMeter.updateDeathBG()
  end
end


function PvpMeter.updateKills()

  if(tonumber(LabelKill:GetText()) < PvpMeter.kills)then
    HUDTelvarMeter_Anim()
  end

  LabelKill:SetText(PvpMeter.kills)

  PvpMeter.updateMeter()
end


function PvpMeter.updateDeath()
  LabelDeath:SetText(PvpMeter.death)
end


function PvpMeter.updateAP()

  --local lab = PvpMeterIndicator:GetNamedChild("LabelAP")
  --lab:SetText(PvpMeter.AP)
  if(PvpMeter.savedVariables.showBeautifulMeter)then
    --TELVAR_METER.meterOverlayControl.fadeAnimation:PlayFromStart()
  end
  if(PvpMeter.savedVariables.currAP == true)then
    LabelAP:SetText(PvpMeter.currAP)
  else
    LabelAP:SetText(PvpMeter.AP)
  end

end


function PvpMeter.openBank(event)
  PvpMeter.hideCyro()
  HUDInfamyMeter_hide()
end


function PvpMeter.onDyeEnd(event)
  PvpMeter.dye = false
end


function PvpMeter.onDyeStart(event)
  PvpMeter.dye = true
end


function PvpMeter.onPointUpdate(event,medalId,name,icon,value)
  PvpMeter.allianceMedal = PvpMeter.allianceMedal + value
  PvpMeter.updateMedal()
end


function PvpMeter.updateBGstats()
    local Medallist= {}

    -- Loop through medals
    for indice=1,80 do
        local medalid = GetBattlegroundMedalIdByIndex(GetCurrentBattlegroundId(),indice)
        local nameM, iconTextureM, conditionM, scoreRewardM = GetMedalInfo(medalid)

        if(scoreRewardM~=0)then
            --d(medalid)
            if(GetScoreboardEntryNumEarnedMedalsById(GetScoreboardPlayerEntryIndex(),medalid)>0)then
                local multM = GetScoreboardEntryNumEarnedMedalsById(GetScoreboardPlayerEntryIndex(),medalid)
                --d(nameM .. " " .. multM)
                local unit= {
                    name = nameM,
                    iconTexture = iconTextureM,
                    condition = conditionM,
                    scoreReward = scoreRewardM,
                    mult = multM
                }
                Medallist[zo_strformat("<<1>>", indice)] = unit

            end

        else
            --d(GetMedalInfo(medalid))
            break
        end
    end


    local entryIndex = GetScoreboardPlayerEntryIndex()
    local characterName, displayName, battlegroundAlliance, isLocalPlayer = GetScoreboardEntryInfo(entryIndex)
    --d(GetBattlegroundGameType(GetCurrentBattlegroundId()))
    --d(battlegroundAlliance)

    local myScore = GetCurrentBattlegroundScore(PvpMeter.alliance)
    if(myScore < 500)then

        local pts = 0

        if(myScore >= GetCurrentBattlegroundScore(1))then  pts = pts + 1  end
        if(myScore >= GetCurrentBattlegroundScore(2))then  pts = pts + 1  end
        if(myScore >= GetCurrentBattlegroundScore(3))then  pts = pts + 1  end

        local diff = 0

        if(myScore == GetCurrentBattlegroundScore(1))then  diff = diff + 1  end
        if(myScore == GetCurrentBattlegroundScore(2))then  diff = diff + 1  end
        if(myScore == GetCurrentBattlegroundScore(3))then  diff = diff + 1  end

        if(pts == 3 and diff == 1)then
            myScore = myScore * 10
        end

    end

    if(myScore >= 500)then
        if(PvpMeter.BGWin ~= nil)then
            PvpMeter.BGWin = PvpMeter.BGWin+1
        else
            PvpMeter.BGWin = 1
        end
        PvpMeter.savedVariables.BGWin = PvpMeter.BGWin
    end

    if(PvpMeter.BGPlayed ~= nil)then
        PvpMeter.BGPlayed = PvpMeter.BGPlayed+1
    else
        PvpMeter.BGPlayed = 1
    end
    PvpMeter.savedVariables.BGPlayed = PvpMeter.BGPlayed


    local kills = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_KILL)
    local death = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_DEATH)
    local assist = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_ASSISTS)

    local damdone = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_DAMAGE_DONE)
    local damtaken = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_DAMAGE_TAKEN)
    local healdo = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_HEALING_DONE)

    local current = {
        kill = kills,
        death = death,
        assist = assist,
        damageDone = damdone,
        damageTaken = damtaken,
        healDone = healdo,
        medal = PvpMeter.allianceMedal,
        score = myScore,
        typeOfBG = GetBattlegroundGameType(GetCurrentBattlegroundId()),
        alliance = battlegroundAlliance,
        mList = Medallist
    }
    if(PvpMeter.BGlist == nil)then
        PvpMeter.BGlist = {}
    end
    PvpMeter.BGlist[zo_strformat("<<1>>", PvpMeter.BGPlayed)] = current
    PvpMeter.savedVariables.BGlist=PvpMeter.BGlist


    BGPvpMeter.updateStat()
end


function PvpMeter.onScoreUpdate(event)
  --d(GetCurrentBattlegroundScore(PvpMeter.alliance))
  --d(PvpMeter.allianceMedal)

  if(PvpMeter.allianceScore ~= GetCurrentBattlegroundScore(PvpMeter.alliance)) then
    PvpMeter.updateMedal()
    PvpMeter.updateMeter()
  end

  local entryInde = GetScoreboardPlayerEntryIndex()
  if(PvpMeter.assistBG ~=  GetScoreboardEntryScoreByType(entryInde, SCORE_TRACKER_TYPE_ASSISTS))then
    PvpMeter.assistBG =  GetScoreboardEntryScoreByType(entryInde, SCORE_TRACKER_TYPE_ASSISTS)
    PvpMeter.updateKillsBG()
  end

  if(PvpMeter.inBG) then
    --PvpMeter.allianceKill = PvpMeter.allianceKill + 1
    --PvpMeter.updateKillsBG()

    --d(GetBattlegroundGameType(GetCurrentBattlegroundId()))

    if( GetCurrentBattlegroundState() == 4) then --BG finish
          PvpMeter.updateBGstats()
    end
  end
end

function PvpMeter.bgkill (eventCode,killedPlayerCharacterName,killedPlayerDisplayName,killedPlayerBattlegroundAlliance,killingPlayerCharacterName,killingPlayerDisplayName,killingPlayerBattlegroundAlliance,battlegroundKillType)
  if(battlegroundKillType == BATTLEGROUND_KILL_TYPE_KILLING_BLOW)then
      PvpMeter.allianceKill = PvpMeter.allianceKill + 1
      PvpMeter.savedVariables.bgKill = PvpMeter.savedVariables.bgKill + 1
      HUDTelvarMeter_Anim()
      PvpMeter.updateKillsBG()
    if(PvpMeter.savedVariables.playSound == true)then
      if(PvpMeter.savedVariables.nbrSound == 0)then
        PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
      end
      if(PvpMeter.savedVariables.nbrSound == 1)then
        PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
      end
    end
  end
  if(battlegroundKillType == BATTLEGROUND_KILL_TYPE_ASSIST)then
    if(PvpMeter.savedVariables.playSound == true)then

    end
  end
end


function PvpMeter.onDuelStart (eventCode)
  --d("duel start")
  PvpMeter.duelRunning = true

  PvpMeter.totalDone = 0
  PvpMeter.totalTaken = 0
  PvpMeter.totalHeal = 0
  PvpMeter.totalBlock = 0
  PvpMeter.totalShield = 0
  PvpMeter.totalDodge = 0
end


function PvpMeter.onDuelFinish (eventCode,duelResult,wasLocalPlayersResult,opponentCharacterName,opponentDisplayName,opponentAlliance,opponentGender,opponentClassId,opponentRaceId)
    PvpMeter.duelRunning = false

    if(duelResult == 0)then return end

     local winR = wasLocalPlayersResult -- true for win, false for defeat
     local nameR = opponentCharacterName -- character name
     --d(opponentDisplayName) -- account name
     --d(opponentAlliance)
     --d(opponentGender)
     local classR = opponentClassId
     local raceR = opponentRaceId


    if(PvpMeter.duelWin ~= nil)then
      if(winR)then
        PvpMeter.duelWin = PvpMeter.duelWin + 1
      end
    else
      if(winR)then
        PvpMeter.duelWin = 1
      else
        PvpMeter.duelWin = 0
      end
    end
    PvpMeter.savedVariables.duelWin = PvpMeter.duelWin


    if(PvpMeter.duelPlayed ~= nil)then
      PvpMeter.duelPlayed = PvpMeter.duelPlayed + 1
      if(PvpMeter.duelPlayed == 1)then
        --PvpMeter.savedVariables.duelMeter = true
        --HUDInfamyMeter_show()
      end
    else
      PvpMeter.duelPlayed = 1
      PvpMeter.savedVariables.duelMeter = true
      HUDInfamyMeter_show()
    end
    PvpMeter.savedVariables.duelPlayed = PvpMeter.duelPlayed

    --d(PvpMeter.totalDone)
    --d(PvpMeter.totalTaken)
    --d(PvpMeter.totalHeal)
    --d(PvpMeter.totalBlock)
    --d(PvpMeter.totalShield)
    --d(PvpMeter.totalDodge)

    local current = {
      win = winR,
      name = nameR,
      class = classR,
      race = raceR,
      done = PvpMeter.totalDone,
      taken = PvpMeter.totalTaken,
      heal = PvpMeter.totalHeal,
      block = PvpMeter.totalBlock,
      shield = PvpMeter.totalShield,
      dodge = PvpMeter.totalDodge,
      gender = opponentGender
    }

    if(PvpMeter.duelList == nil)then
      PvpMeter.duelList = {}
    end
    PvpMeter.duelList[zo_strformat("<<1>>", PvpMeter.duelPlayed)] = current
    PvpMeter.savedVariables.duelList=PvpMeter.duelList

    PvpMeter.updateMeterDuel()
    DuelPvpMeter.updateStat()


  --[[if(currentState == BATTLEGROUND_STATE_FINISHED)then

    local entryIndex = GetScoreboardPlayerEntryIndex()
        local characterName, displayName, battlegroundAlliance, isLocalPlayer = GetScoreboardEntryInfo(entryIndex)
        local kills = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_KILL)
    local death = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_DEATH)
    local assist = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_ASSISTS)

    d(kills)
    d(death)
    d(assist)
    d(PvpMeter.allianceMedal)
    d(GetBattlegroundGameType(GetCurrentBattlegroundId()))

  end]]
end


function PvpMeter.updateKillsBG()
  LabelKillBG:SetText(PvpMeter.allianceKill)
  LabelAssist:SetText(PvpMeter.assistBG)
end


function PvpMeter.updateDeathBG()
  LabelDeathBG:SetText(PvpMeter.allianceDeath)
end


function PvpMeter.updateMedal()
  LabelMedal:SetText(PvpMeter.allianceMedal)
end


function PvpMeter.changeColor()
  if(PvpMeter.alliance == 1) then
    LabelKillBG:SetColor(0.85,0.4,00)
    LabelAssist:SetColor(0.85,0.4,00)
    LabelDeathBG:SetColor(0.85,0.4,00)
    LabelMedal:SetColor(0.85,0.4,00)
    --meterBarBG:SetColor(1,0.0,0.0)
    scoreIcon:SetTexture( GetBattlegroundTeamIcon(PvpMeter.alliance))
    --scoreIcon:SetColor(1,0.1,00)
    --Fill:SetFillColor(1,0.0,0.0)
    --Highlig:SetFillColor(1,0.0,0.0)
    HUDTelvarMeter_color(1,0.15,0.0)
    HUDTelvarMeter_colorAlert(0.5,0,0.0)

  elseif(PvpMeter.alliance == 2) then
    LabelKillBG:SetColor(0.36,0.6,0.0)
    LabelAssist:SetColor(0.36,0.6,0.0)
    LabelDeathBG:SetColor(0.36,0.6,0.0)
    LabelMedal:SetColor(0.36,0.6,0.0)
    --meterBarBG:SetColor(0.5,0.4,0.00)
    scoreIcon:SetTexture(GetBattlegroundTeamIcon(PvpMeter.alliance))
    --scoreIcon:SetColor(0.5,0.4,0.00)
    HUDTelvarMeter_color(0.5,0.4,0.00)
    HUDTelvarMeter_colorAlert(0.4,0.5,0.00)
    --Fill:SetFillColor(0.5,0.4,0.00)
    --Highlig:SetFillColor(0.5,0.4,0.00)

  else
    LabelKillBG:SetColor(0.5,0.3,0.6)
    LabelAssist:SetColor(0.5,0.3,0.6)
    LabelDeathBG:SetColor(0.5,0.3,0.6)
    LabelMedal:SetColor(0.5,0.3,0.6)
    --meterBarBG:SetColor(1.0,0.1,0.7)
    scoreIcon:SetTexture(GetBattlegroundTeamIcon(PvpMeter.alliance))
    --scoreIcon:SetColor(0.6,0.1,0.7)
    HUDTelvarMeter_color(1.0,0.1,0.5)
    HUDTelvarMeter_colorAlert(1.0,0.1,0.7)
    --Fill:SetFillColor(1.0,0.1,0.7)
    --Highlig:SetFillColor(1.0,0.1,0.7)
  end
end

function PvpMeter.updateMeter()
  local start = 0.0
  local endd = 0.0

  if(PvpMeter.inAvA) then

    if(PvpMeter.savedVariables.nbrCyro==0)then
      local isAllianceHoldingAllNativeKeeps, numEnemyKeepsThisAllianceHolds, numNativeKeepsThisAllianceHolds, totalNativeKeepsInThisAlliancesArea = GetAvAKeepScore( GetCurrentCampaignId() , GetUnitAlliance("player") )
      --d(isAllianceHoldingAllNativeKeeps)
      --d(numEnemyKeepsThisAllianceHolds)
      --d(numNativeKeepsThisAllianceHolds)
      --d(totalNativeKeepsInThisAlliancesArea)

      local num = (numEnemyKeepsThisAllianceHolds + numNativeKeepsThisAllianceHolds)/18
      start = PvpMeter.lastPercentKeep
      endd = num

      PvpMeter.lastPercentKeep = num
    end
    if(PvpMeter.savedVariables.nbrCyro==1)then
      if(PvpMeter.kills == 0) then
        start = 0.0
        endd = 0.0
      else
      if(PvpMeter.kills%5 == 0) then
        start = 0.0
        endd = 1.0
      else
        endd = (PvpMeter.kills%5)/5
        start = endd - 0.2
      end
    end
    end
    if(PvpMeter.savedVariables.nbrCyro==2)then
      local Aaa ,Bbb ,rankStartsAt,nextRankAt = GetAvARankProgress(GetUnitAvARankPoints("player"))
      local need  = nextRankAt-rankStartsAt
      local did = GetUnitAvARankPoints("player")-rankStartsAt

      endd = did/need

      if(PvpMeter.lastAP == 0)then
        start = 0.0
      else
        start = PvpMeter.lastAP
      end

      PvpMeter.lastAP = endd
    end

  end


  if(PvpMeter.inBG) then

    PvpMeter.allianceScore = GetCurrentBattlegroundScore(PvpMeter.alliance)
    endd = PvpMeter.allianceScore/500

    if(PvpMeter.allianceLastScore == 0) then
      start = 0.0
    else
      start = PvpMeter.allianceLastScore/500
    end

    PvpMeter.allianceLastScore = PvpMeter.allianceScore
  end

  HUDTelvarMeter_update(start,endd)
end


function PvpMeter.updateMeterDuel()

  local start = 0
  local endd = 0

  if(PvpMeter.duelPlayed == nil)then
    PvpMeter.duelPlayed = 0
    PvpMeter.duelWin = 0
  end

  if(PvpMeter.duelPlayed ~= 0) then
    endd = PvpMeter.duelWin/PvpMeter.duelPlayed
  else
    endd = 1
  end

  local hist1=2
  local hist2=2
  local hist3=2
  local hist4=2
  local hist5=2

  if(PvpMeter.duelPlayed == 1) then
    hist1=2
    hist2=2
    hist3=2
    hist4=2
    if(PvpMeter.duelList["1"].win)then hist5 = 0 else hist5 = 1 end
  end
  if(PvpMeter.duelPlayed == 2) then
    hist1=2
    hist2=2
    hist3=2
    if(PvpMeter.duelList["1"].win)then hist4 = 0 else hist4 = 1 end
    if(PvpMeter.duelList["2"].win)then hist5 = 0 else hist5 = 1 end
  end
  if(PvpMeter.duelPlayed == 3) then
    hist1=2
    hist2=2
    if(PvpMeter.duelList["1"].win)then hist3 = 0 else hist3 = 1 end
    if(PvpMeter.duelList["2"].win)then hist4 = 0 else hist4 = 1 end
    if(PvpMeter.duelList["3"].win)then hist5 = 0 else hist5 = 1 end
  end
  if(PvpMeter.duelPlayed == 4) then
    hist1=2
    if(PvpMeter.duelList["1"].win)then hist2 = 0 else hist2 = 1 end
    if(PvpMeter.duelList["2"].win)then hist3 = 0 else hist3 = 1 end
    if(PvpMeter.duelList["3"].win)then hist4 = 0 else hist4 = 1 end
    if(PvpMeter.duelList["4"].win)then hist5 = 0 else hist5 = 1 end
  end
  if(PvpMeter.duelPlayed == 5) then
    if(PvpMeter.duelList["1"].win)then hist1 = 0 else hist1 = 1 end
    if(PvpMeter.duelList["2"].win)then hist2 = 0 else hist2 = 1 end
    if(PvpMeter.duelList["3"].win)then hist3 = 0 else hist3 = 1 end
    if(PvpMeter.duelList["4"].win)then hist4 = 0 else hist4 = 1 end
    if(PvpMeter.duelList["5"].win)then hist5 = 0 else hist5 = 1 end
  end
  if(PvpMeter.duelPlayed > 5) then
    if(PvpMeter.duelList[zo_strformat("<<1>>", PvpMeter.duelPlayed-4)].win)then hist1 = 0 else hist1 = 1 end
    if(PvpMeter.duelList[zo_strformat("<<1>>", PvpMeter.duelPlayed-3)].win)then hist2 = 0 else hist2 = 1 end
    if(PvpMeter.duelList[zo_strformat("<<1>>", PvpMeter.duelPlayed-2)].win)then hist3 = 0 else hist3 = 1 end
    if(PvpMeter.duelList[zo_strformat("<<1>>", PvpMeter.duelPlayed-1)].win)then hist4 = 0 else hist4 = 1 end
    if(PvpMeter.duelList[zo_strformat("<<1>>", PvpMeter.duelPlayed)].win)then hist5 = 0 else hist5 = 1 end
  end

  HUDInfamyMeter_Update(start ,endd, hist1,hist2,hist3,hist4,hist5)
end


function PvpMeter.restore()
  local left = PvpMeter.savedVariables.left
  local top = PvpMeter.savedVariables.top

  HUDTelvarMeter_restore(top,left)

  PvpMeter.BGPlayed = PvpMeter.savedVariables.BGPlayed
  PvpMeter.BGWin = PvpMeter.savedVariables.BGWin
  PvpMeter.BGlist = PvpMeter.savedVariables.BGlist

  PvpMeter.duelPlayed = PvpMeter.savedVariables.duelPlayed
  PvpMeter.duelWin = PvpMeter.savedVariables.duelWin
  PvpMeter.duelList = PvpMeter.savedVariables.duelList
  HUDInfamyMeter_restore(top,left)
end


function PvpMeter.OnMeterMoveStop()
  PvpMeter.savedVariables.left = HUDTelvarMeter_getLeft()
  PvpMeter.savedVariables.top = HUDTelvarMeter_getTop()
end


function PvpMeter.OnDuelMoveStop()
  PvpMeter.savedVariables.left = HUDInfamyMeter_getLeft()
  PvpMeter.savedVariables.top = HUDInfamyMeter_getTop()
end


function PvpMeter.rotateMeter(param)
  if(param == 1)then
    Glow:SetTextureCoords(0,1,0,1)
    Gl:SetTextureCoords(0,1,0,1)

    LabelAP:ClearAnchors()
    LabelAP:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,42)
    LabelMedal:ClearAnchors()
    LabelMedal:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,42)

    -- texture
    teamiconAP:ClearAnchors()
    teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-14)

    teamiconBG:ClearAnchors()
    teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-4)

    LabelKill:ClearAnchors()
    LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,58)
    LabelDeath:ClearAnchors()
    LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,92)

    LabelKillBG:ClearAnchors()
    LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,58)
    LabelDeathBG:ClearAnchors()
    LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,92)
    LabelAssist:ClearAnchors()
    LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,89,50)

    --Anim
    HUDTelvarMeter_moveBar(0,0)
  end

  if(param == 2)then
    Glow:SetTextureCoords(1,0,0,1)
    Gl:SetTextureCoords(1,0,0,1)

    LabelAP:ClearAnchors()
    LabelAP:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,42)
    LabelMedal:ClearAnchors()
    LabelMedal:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,42)

    -- texture
    teamiconAP:ClearAnchors()
    teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-14)


    teamiconBG:ClearAnchors()
    teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-4)

    LabelKill:ClearAnchors()
    LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,58)
    LabelDeath:ClearAnchors()
    LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,92)

    LabelKillBG:ClearAnchors()
    LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,58)
    LabelDeathBG:ClearAnchors()
    LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,92)
    LabelAssist:ClearAnchors()
    LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-93,50)


    --Anim
    HUDTelvarMeter_moveBar(-164,0)

  end

  if(param == 3)then
    Glow:SetTextureCoords(1,0,1,0)
    Gl:SetTextureCoords(1,0,1,0)


    LabelAP:ClearAnchors()
    LabelAP:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,-42)
    LabelMedal:ClearAnchors()
    LabelMedal:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,-42)

    -- texture
    teamiconAP:ClearAnchors()
    teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-98)


    teamiconBG:ClearAnchors()
    teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-88)

    LabelKill:ClearAnchors()
    LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,22)
    LabelDeath:ClearAnchors()
    LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,56)

    LabelKillBG:ClearAnchors()
    LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,22)
    LabelDeathBG:ClearAnchors()
    LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,56)
    LabelAssist:ClearAnchors()
    LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-93,14)


    --Anim
    HUDTelvarMeter_moveBar(-164,-36)

  end

  if(param == 4)then
    Glow:SetTextureCoords(0,1,1,0)
    Gl:SetTextureCoords(0,1,1,0)

    LabelAP:ClearAnchors()
    LabelAP:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,-42)
    LabelMedal:ClearAnchors()
    LabelMedal:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,-42)

    -- texture
    teamiconAP:ClearAnchors()
    teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-98)


    teamiconBG:ClearAnchors()
    teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-88)

    LabelKill:ClearAnchors()
    LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,22)
    LabelDeath:ClearAnchors()
    LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,56)

    LabelKillBG:ClearAnchors()
    LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,22)
    LabelDeathBG:ClearAnchors()
    LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,56)
    LabelAssist:ClearAnchors()
    LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,89,14)

    --Anim
    HUDTelvarMeter_moveBar(0,-36)
  end
end


function PvpMeter.pageplusBG()
  if(PvpMeter.page > 1) then
    PvpMeter.page = PvpMeter.page -1
    PvpMeterNumPageBG:SetText(PvpMeter.page.."/"..math.ceil(PvpMeter.BGPlayed/50))

    BGPvpMeter.show2()
  end
end


function PvpMeter.pagemoinBG()
  if(PvpMeter.page<math.ceil(PvpMeter.BGPlayed/50))then
    PvpMeter.page = PvpMeter.page +1
    PvpMeterNumPageBG:SetText(PvpMeter.page.."/"..math.ceil(PvpMeter.BGPlayed/50))

    BGPvpMeter.show2()
  end
end


function PvpMeter.pageplusDuel()
  if(PvpMeter.pageD > 1) then
    PvpMeter.pageD = PvpMeter.pageD -1
    PvpMeterNumPageDuel:SetText(PvpMeter.pageD.."/"..math.ceil(PvpMeter.duelPlayed /50))

    DuelPvpMeter.show2()
  end
end


function PvpMeter.pagemoinDuel()

  if(PvpMeter.pageD<math.ceil(PvpMeter.duelPlayed /50))then
    PvpMeter.pageD = PvpMeter.pageD +1
    PvpMeterNumPageDuel:SetText(PvpMeter.pageD.."/"..math.ceil(PvpMeter.duelPlayed /50))

    DuelPvpMeter.show2()
  end
end


function PvpMeter.prepareQuickButton()

  --esoui/art/campaign/campaignbrowser_homecampaign.dds

  local taba = 25

  PvpMeter.button =  WINDOW_MANAGER:CreateControl("PvpMeter_home_button", ZO_ChatWindow, CT_BUTTON)
  PvpMeter.button:SetDimensions(30, 30)
  PvpMeter.button:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, taba, 0)
  PvpMeter.button:SetNormalTexture("esoui/art/guild/tabicon_home_up.dds")
  PvpMeter.button:SetPressedTexture("esoui/art/guild/tabicon_home_down.dds")
  PvpMeter.button:SetMouseOverTexture("esoui/art/guild/tabicon_home_over.dds")

  local tabb = taba+30+3

  PvpMeter.label_home =  WINDOW_MANAGER:CreateControl("PvpMeter_home_label", ZO_ChatWindow, CT_LABEL)
  PvpMeter.label_home:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, tabb , 4)
  PvpMeter.label_home:SetFont("ZoFontWinH4")
  PvpMeter.label_home:SetText("0")

  local tabc = tabb + 15

  PvpMeter.button2 =  WINDOW_MANAGER:CreateControl("PvpMeter_guest_button", ZO_ChatWindow, CT_BUTTON)
  PvpMeter.button2:SetDimensions(38, 32)
  PvpMeter.button2:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications,TOPRIGHT, tabc, -1)
  PvpMeter.button2:SetNormalTexture("esoui/art/journal/leaderboard_tabicon_guest_up.dds")
  PvpMeter.button2:SetPressedTexture("esoui/art/journal/leaderboard_tabicon_guest_down.dds")
  PvpMeter.button2:SetMouseOverTexture("esoui/art/journal/leaderboard_tabicon_guest_over.dds")


  PvpMeter.button2:SetHandler("OnMouseEnter", function(...)
    ZO_Tooltips_ShowTextTooltip(PvpMeter.button2, BOTTOM, GetCampaignName(GetGuestCampaignId()) )
  end)

  PvpMeter.button2:SetHandler("OnMouseExit", function(...)
    ZO_Tooltips_HideTextTooltip()
  end)

  PvpMeter.button:SetHandler("OnMouseEnter", function(...)
    ZO_Tooltips_ShowTextTooltip(PvpMeter.button, BOTTOM, GetCampaignName(GetAssignedCampaignId()) )
  end)
    PvpMeter.button:SetHandler("OnMouseExit", function(...)
    ZO_Tooltips_HideTextTooltip()
  end)


  local tabd = tabc +32 + 3

  PvpMeter.label_guest =  WINDOW_MANAGER:CreateControl("PvpMeter_guest_label", ZO_ChatWindow, CT_LABEL)
  PvpMeter.label_guest:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, tabd, 4)
  PvpMeter.label_guest:SetFont("ZoFontWinH4")
  PvpMeter.label_guest:SetText("0")

  PvpMeter.button:SetHandler("OnClicked", function(...)
    QueueForCampaign(GetAssignedCampaignId(),false)
    --label:SetText("...")
  end)

  PvpMeter.button2:SetHandler("OnClicked", function(...)
    QueueForCampaign(GetGuestCampaignId(),false)
    --label2:SetText("...")

  end)


  local minMaxClicked = ZO_ChatSystem_OnMinMaxClicked
  ZO_ChatSystem_OnMinMaxClicked = function(control)

    if CHAT_SYSTEM:IsMinimized() then
      --d("je maximize")

      if(PvpMeter.savedVariables.quickButton)then

        PvpMeter.button:SetHidden(false)
        PvpMeter.button2:SetHidden(false)
        PvpMeter.label_home:SetHidden(false)
        PvpMeter.label_guest:SetHidden(false)
      end

    else
      --d("je minimize")
      --if(PvpMeter.savedVariables.quickButton)then
        PvpMeter.button:SetHidden(true)
        PvpMeter.button2:SetHidden(true)
        PvpMeter.label_home:SetHidden(true)
        PvpMeter.label_guest:SetHidden(true)
      --end

    end
    minMaxClicked()
  end

  ZO_PreHook(CHAT_SYSTEM, "Minimize",
  function(self)
    --d("je minimize")
      --if(PvpMeter.savedVariables.quickButton)then
        PvpMeter.button:SetHidden(true)
        PvpMeter.button2:SetHidden(true)
        PvpMeter.label_home:SetHidden(true)
        PvpMeter.label_guest:SetHidden(true)
      --end

  end)

  ZO_PreHook(CHAT_SYSTEM, "Maximize",
  function(self)

    if(PvpMeter.savedVariables.quickButton)then

        PvpMeter.button:SetHidden(false)
        PvpMeter.button2:SetHidden(false)
        PvpMeter.label_home:SetHidden(false)
        PvpMeter.label_guest:SetHidden(false)
      end


  end)

  ZO_PreHook(SharedChatSystem, "StartTextEntry",
  function(self)
    if(PvpMeter.savedVariables.quickButton)then
      PvpMeter.button:SetHidden(false)
      PvpMeter.button2:SetHidden(false)
      PvpMeter.label_home:SetHidden(false)
      PvpMeter.label_guest:SetHidden(false)
    end
  end)

end


function PvpMeter.updateButtonQuick()
  if(PvpMeter.savedVariables.quickButton == false)then
    PvpMeter.button:SetHidden(true)
    PvpMeter.button2:SetHidden(true)
    PvpMeter.label_home:SetHidden(true)
    PvpMeter.label_guest:SetHidden(true)
  end

  if(PvpMeter.savedVariables.quickButton)then
    PvpMeter.button:SetHidden(false)
    PvpMeter.button2:SetHidden(false)
    PvpMeter.label_home:SetHidden(false)
    PvpMeter.label_guest:SetHidden(false)
    end
end

function PvpMeter.queue_joined (eventCode, campaignId, isGroup)
  --d("queue")
  if(campaignId==GetAssignedCampaignId())then
    PvpMeter.label_home:SetText("...")
  end
  if(campaignId==GetGuestCampaignId())then
    PvpMeter.label_guest:SetText("...")
  end

end


function PvpMeter.queue_left (eventCode, campaignId, isGroup)
  --d("left")
  if(campaignId==GetAssignedCampaignId())then
    PvpMeter.label_home:SetText("0")
  end
  if(campaignId==GetGuestCampaignId())then
    PvpMeter.label_guest:SetText("0")
  end
end


function PvpMeter.queue_position (eventCode, campaignId, isGroup, position)
  --d(position)
  if(campaignId==GetAssignedCampaignId())then
    PvpMeter.label_home:SetText(position)
  end
  if(campaignId==GetGuestCampaignId())then
    PvpMeter.label_guest:SetText(position)
  end
end


function PvpMeter.queue_state(eventCode, campaignId, isGroup, state)

  --d(state)
  if(state == 2)then

    if(PvpMeter.savedVariables.autoqueue)then
      ConfirmCampaignEntry(campaignId, isGroup, true)
    end

    if(campaignId==GetAssignedCampaignId())then
      PvpMeter.label_home:SetText("...")
    end
    if(campaignId==GetGuestCampaignId())then
      PvpMeter.label_guest:SetText("...")
    end

  end
end


function PvpMeter.onActivityFinderStatusUpdate(eventCode, status)
  if status == ACTIVITY_FINDER_STATUS_READY_CHECK then
    if(PvpMeter.savedVariables.autoqueue) then
      AcceptLFGReadyCheckNotification()
    end
  end
end