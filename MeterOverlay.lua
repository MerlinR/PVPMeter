TELVAR_METER_WIDTH = 256
TELVAR_METER_HEIGHT = 128

local MeterBar = ZO_Object:Subclass()

function MeterBar:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function MeterBar:Initialize(control)
  -- Initialize state
  self.hiddenReasons = ZO_HiddenReasons:New()
  self.telvarStoneThreshold = GetTelvarStoneMultiplierThresholdIndex()
  
  -- Set up controls
  self.alertBorder = MeterBarAlertBorder
  self.telvarDisplayControl = control:GetNamedChild("TelvarDisplay")
  self.meterTelvarMultiplierControl = control:GetNamedChild("Multiplier")
  self.meterFrameControl = control:GetNamedChild("Frame")
  self.meterBarControl = control:GetNamedChild("Bar")
  self.meterOverlayControl = control:GetNamedChild("Overlay")
  self.meterBarFill = self.meterBarControl:GetNamedChild("Fill")
  self.meterBarHighlight = self.meterBarControl:GetNamedChild("Highlight")
  self.multiplierContainer = control:GetNamedChild("MultiplierContainer")
  self.multiplierLabel = self.multiplierContainer:GetNamedChild("MultiplierLabel")
  self.multiplierWholePart = self.multiplierContainer:GetNamedChild("WholePart")
  self.multiplierFractionalPart = self.multiplierContainer:GetNamedChild("FractionalPart")
  self.control = control

  -- Set up platform styles
  self.keyboardStyle = 
  { 
    template = "MeterBarOV" ,
    currencyOptions = 
    {
      showTooltips = true,
      customTooltip = SI_CURRENCYTYPE3,
      isGamepad = false,
      font = "ZoFontGameLargeBold",
      iconSide = RIGHT,
    },
  }
  ZO_PlatformStyle:New(function(...) self:UpdatePlatformStyle(...) end, self.keyboardStyle, self.keyboardStyle)

  self.labelScore = control:GetNamedChild("Score")
  self.labelKills = control:GetNamedChild("Kill")
  self.labelAssist = control:GetNamedChild("Assist")
  self.labelDeath = control:GetNamedChild("Death")
  self.IconC = control:GetNamedChild("IconC")
  self.labelIcon = self.IconC:GetNamedChild("Icon")
  

  -- Initialize alert border animation
  self.alertBorder.pulseAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("MeterBarBorderAnimation", self.alertBorder)

  -- Initialize overlay animation
  self.meterOverlayControl.fadeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("MeterBarOverlayFade", self.meterOverlayControl)

  -- Initialize label animation
  self.multiplierContainer.bounceAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("MeterBarMultiplierBounce", self.multiplierContainer)

  -- Initialize bar states and animations
  self.meterBarControl.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("MeterBarEasing")
  self.meterBarControl.startPercent = 0
  self.meterBarControl.endPercent = 0

  -- Do our initial update
  self:SetBarValue(self.meterBarControl.startPercent)
  self:UpdateMeterBar()
end


function MeterBar:SetHiddenForReason(reason, hidden)
  self.hiddenReasons:SetHiddenForReason(reason, hidden)
  self.control:SetHidden(self.hiddenReasons:IsHidden())
end


function MeterBar:UpdateMeterBar()
  -- Start the bar animation
  self.meterBarControl.easeAnimation:PlayFromStart()
end


function MeterBar:AnimateMeter(progress)
  local fillPercentage = zo_min((progress * (self.meterBarControl.endPercent - self.meterBarControl.startPercent)) + self.meterBarControl.startPercent, 1)
  self:SetBarValue(fillPercentage)
end


function MeterBar:SetBarValue(percentFilled)
  self.meterBarFill:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE) -- CD_TIME_TYPE_TIME_REMAINING causes clockwise scroll
  self.meterBarHighlight:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
end


function MeterBar:UpdatePlatformStyle(styleTable)
  ApplyTemplateToControl(self.control, styleTable.template)
  ZO_CurrencyControl_SetSimpleCurrency(self.telvarDisplayControl, CURT_TELVAR_STONES, GetCarriedCurrencyAmount(CURT_TELVAR_STONES), styleTable.currencyOptions, CURRENCY_SHOW_ALL) 

  local isMaxThreshold = IsMaxTelvarStoneMultiplierThreshold(self.telvarStoneThreshold)
  self.meterBarControl:SetHidden(isMaxThreshold)
  self.meterOverlayControl:SetAlpha(isMaxThreshold and 1 or 0)
end


function MeterBar_Initialize(control)
  TELVAR_METER = MeterBar:New(control)
end


function MeterBar_update(startP,endP)
  if TELVAR_METER then
    TELVAR_METER.meterBarControl.startPercent = startP
    TELVAR_METER.meterBarControl.endPercent = endP
    TELVAR_METER:UpdateMeterBar()
  end
end


function MeterBar_increment(percentFilled)
  if TELVAR_METER then
    TELVAR_METER.meterBarControl.startPercent = TELVAR_METER.meterBarControl.endPercent
    TELVAR_METER.meterBarControl.endPercent = percentFilled
    TELVAR_METER:UpdateMeterBar()
  end
end


function MeterBar_setLabels(score, kills, assists, deaths)
  if TELVAR_METER then
    TELVAR_METER.labelKills:SetText(kills)
    TELVAR_METER.labelAssist:SetText(assists)
    TELVAR_METER.labelDeath:SetText(deaths)
    TELVAR_METER.labelScore:SetText(score)
  end
end


function MeterBar_resetLabels()
  if TELVAR_METER then
    TELVAR_METER.labelKills:SetText(0)
    TELVAR_METER.labelAssist:SetText(0)
    TELVAR_METER.labelDeath:SetText(0)
    TELVAR_METER.labelScore:SetText(0)
  end
end


function MeterBar_resetBar()
  if TELVAR_METER then
    TELVAR_METER.meterBarControl.startPercent = 0
    TELVAR_METER.meterBarControl.endPercent = 0
    TELVAR_METER:UpdateMeterBar()
  end
end


function MeterBar_resetMeter()
  if TELVAR_METER then
    MeterBar_resetLabels()
    MeterBar_resetBar()
  end
end


function MeterBar_barColor(r,g,b)
  if TELVAR_METER then
    TELVAR_METER.meterBarFill:SetFillColor(r,g,b)
    TELVAR_METER.meterBarHighlight:SetFillColor(r,g,b)
    TELVAR_METER.meterOverlayControl:SetColor(r,g,b,0)
    --truck:SetEdgeColor(r,g,b)
  end
end


function MeterBar_setColors(zone, alliance)
  if TELVAR_METER then
    if ( zone == DEFINES.BG ) then

      if ( alliance == BATTLEGROUND_ALLIANCE_FIRE_DRAKES ) then
        TELVAR_METER.labelIcon:SetColor(0.85,0.4,00)
        MeterBar_barColor(1,0.15,0.0)
      elseif ( alliance == BATTLEGROUND_ALLIANCE_PIT_DAEMONS ) then
        TELVAR_METER.labelIcon:SetColor(0.36,0.6,0.0)
        MeterBar_barColor(0.5,0.4,0.00)
      elseif ( alliance == BATTLEGROUND_ALLIANCE_STORM_LORDS ) then
        TELVAR_METER.labelIcon:SetColor(0.5,0.3,0.6)
        MeterBar_barColor(1.0,0.1,0.5)
      end
      TELVAR_METER.labelIcon:SetTexture( GetBattlegroundTeamIcon(alliance))

    elseif ( zone == DEFINES.CYRO ) then
      -- FIXME This colors are wrong, cant be fuked
      if ( alliance == ALLIANCE_ALDMERI_DOMINION ) then
        TELVAR_METER.labelIcon:SetColor(0.85,0.4,00)
        MeterBar_barColor(1,0.15,0.0)
      elseif ( alliance == ALLIANCE_DAGGERFALL_COVENANT ) then
        TELVAR_METER.labelIcon:SetColor(0.36,0.6,0.0)
        MeterBar_barColor(0.5,0.4,0.00)
      elseif ( alliance == ALLIANCE_EBONHEART_PACT ) then
        TELVAR_METER.labelIcon:SetColor(0.5,0.3,0.6)
        MeterBar_barColor(1.0,0.1,0.5)
      end
      TELVAR_METER.labelIcon:SetTexture("esoui/art/currency/alliancepoints_32.dds")
    end
  end
end


function MeterBar_moveBar(x,y)
  if TELVAR_METER then
    TELVAR_METER.meterBarControl:ClearAnchors()
    TELVAR_METER.meterOverlayControl:ClearAnchors()

    TELVAR_METER.meterBarControl:SetAnchor(RIGHT,MeterBarOV,RIGHT,18+x,18+y)
    TELVAR_METER.meterOverlayControl:SetAnchor(RIGHT,MeterBarOV,RIGHT,24+x,18+y)
  end
end


function MeterBar_restore(left,top)
  if TELVAR_METER then
    if top ~= nil or left ~= nil then
      TELVAR_METER.control:ClearAnchors()
      TELVAR_METER.control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    else
      TELVAR_METER.control:ClearAnchors()
      TELVAR_METER.control:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, left, top)
    end
  end
end


function MeterBar_display(display)
  if TELVAR_METER then
    if display then
      TELVAR_METER:SetHiddenForReason("disabledInZone", false)
    else
      TELVAR_METER:SetHiddenForReason("disabledInZone", true)
    end
  end
end

function MeterBar_displayToggle()
  if TELVAR_METER then
    if 1 then
      TELVAR_METER:SetHiddenForReason("disabledInZone", false)
    else
      TELVAR_METER:SetHiddenForReason("disabledInZone", true)
    end
  end
end

function MeterBar_alpha(alpha)
  if TELVAR_METER then
    TELVAR_METER.meterBarControl:SetAlpha(alpha)
  end
end


function MeterBar_first()
  if TELVAR_METER then
    TELVAR_METER.meterBarControl:SetAnchor(RIGHT,MeterBarOV,RIGHT,TELVAR_METER_KEYBOARD_BAR_OFFSET_X,18)
  end
end


function MeterBar_sec()
  if TELVAR_METER then
    TELVAR_METER.meterBarControl:SetAnchor(RIGHT,MeterBarOV,RIGHT,TELVAR_METER_KEYBOARD_BAR_OFFSET_X,-72)
  end
end


function MeterBar_getLeft()
  if TELVAR_METER then
    return TELVAR_METER.control:GetLeft()
  end
end


function MeterBar_getTop()
  if TELVAR_METER then
    return TELVAR_METER.control:GetTop()
  end
end


function MeterBar_UpdateMeterToAnimationProgress(progress)
  if TELVAR_METER then
    TELVAR_METER:AnimateMeter(progress)
  end
end


function MeterBar_Anim()
  if TELVAR_METER then
    TELVAR_METER.meterOverlayControl.fadeAnimation:PlayFromStart()
    --TELVAR_METER.alertBorder.pulseAnimation:PlayFromStart()
  end
end