-- This files contains the GUI Overlay for the duels

INFAMY_METER_WIDTH = 256
INFAMY_METER_HEIGHT = 128
INFAMY_METER_KEYBOARD_BAR_OFFSET_X = 14
INFAMY_METER_KEYBOARD_BAR_OFFSET_Y = 15
INFAMY_METER_GAMEPAD_BAR_OFFSET = 10

local INFAMY_METER_UPDATE_DELAY_SECONDS = 1

 -- Forces the bar to be at least 3% full, in order to make it visible even at one or two bounty
local MIN_BAR_PERCENTAGE = 0.03
local UPDATE_TYPE_EVENT = 1
local HUDInfamyMeter = ZO_Object:Subclass()


function HUDInfamyMeter:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end


function HUDInfamyMeter:Initialize(control)
    -- Initialize state
    self.nextUpdateTime = 0
    self.hiddenExternalRequest = false
    self.meterTotal = GetInfamyMeterSize()

    self.infamyMeterState = {}
    --self:UpdateInfamyMeterState(0, 0, false, false)

    self.isInGamepadMode = IsInGamepadPreferredMode()

    self.currencyOptions =
    {
        showTooltips = true,
        customTooltip = SI_STATS_BOUNTY_LABEL,
        font = self.isInGamepadMode and "ZoFontGamepadHeaderDataValue" or "ZoFontGameLargeBold",
        overrideTexture = self.isInGamepadMode and "EsoUI/Art/currency/gamepad/gp_gold.dds" or nil,
        iconSide = RIGHT,
        isGamepad = self.isInGamepadMode
    }

    -- Set up controls
    ApplyTemplateToControl(control, self.isInGamepadMode and "HUDInfamyMeter_GamepadTemplate" or "HUDInfamyMeter_KeyboardTemplate")
    self.control = control
    self.background = control:GetNamedChild("Background")
    self.meterFrame = control:GetNamedChild("Frame")
    self.infamyBar = control:GetNamedChild("InfamyBar")
    self.bountyBar = control:GetNamedChild("BountyBar")
    self.centerIconAnimatingTexture = control:GetNamedChild("CenterIconAnimatingTexture")
    self.centerIconPersistentTexture = control:GetNamedChild("CenterIconPersistentTexture")
    self.bountyLabel = control:GetNamedChild("BountyDisplay")

    -- Set up fade in/out animations
    self.fadeAnim = ZO_AlphaAnimation:New(control)
    self.fadeAnim:SetMinMaxAlpha(0.0, 1.0)

    -- Initialize bar states and animations
    self.infamyBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDInfamyMeterEasing")
    self.infamyBar.startPercent = 0
    self.infamyBar.endPercent = 0.5

    self.bountyBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDInfamyMeterEasing")
    self.bountyBar.startPercent = 0
    self.bountyBar.endPercent = 1

    control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
        self.control:SetHidden(false)
    end)
end


function HUDInfamyMeter:Update(time)
    if self.nextUpdateTime <= time and not self.hiddenExternalRequest and IsInJusticeEnabledZone() then
        self.nextUpdateTime = time + INFAMY_METER_UPDATE_DELAY_SECONDS
    end
end

function HUDInfamyMeter:UpdateBar(bar, start, endd)
    if not bar.easeAnimation:IsPlaying() or updateType == UPDATE_TYPE_EVENT then
        -- Update Values
        bar.startPercent = start
        bar.endPercent = endd

       self:SetBarValue(bar, bar.startPercent)

        -- Start the animation
        bar.easeAnimation:PlayFromStart()
    end
end


function HUDInfamyMeter:AnimateMeter(progress)
    local infamyFillPercentage = zo_min((progress * (self.infamyBar.endPercent - self.infamyBar.startPercent)) + self.infamyBar.startPercent, 1)
    local bountyFillPercentage = zo_min((progress * (self.bountyBar.endPercent - self.bountyBar.startPercent)) + self.bountyBar.startPercent, 1)
    local infamyMinPercentage = self.infamyMeterState["infamy"] ~= 0 and MIN_BAR_PERCENTAGE or 0
    local bountyMinPercentage = self.infamyMeterState["bounty"] ~= 0 and MIN_BAR_PERCENTAGE or 0
    self:SetBarValue(self.infamyBar, zo_max(infamyFillPercentage, infamyMinPercentage))
    self:SetBarValue(self.bountyBar, zo_max(bountyFillPercentage, bountyMinPercentage))
end


function HUDInfamyMeter:SetBarValue(bar, percentFilled)
    bar:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE) -- CD_TIME_TYPE_TIME_REMAINING causes clockwise scroll
end


function HUDInfamyMeter:changeColor(endd)
  if(endd > 0.49) then
    LabelP:SetColor(0.2,0.7,0)
    Perc:SetColor(0.2,0.7,0)
  end
  if(endd <= 0.49) then
    LabelP:SetColor(0.7,0,0)
    Perc:SetColor(0.7,0,0)
  end

  local txt = math.floor(endd*100)
  LabelP:SetText(txt)
  Perc:SetText("%")


  if(txt<100) then
    Perc:SetAnchor(BOTTOMRIGHT,self.background,BOTTOMLEFT,87,-50) -- -103
  else
    Perc:SetAnchor(BOTTOMRIGHT,self.background,BOTTOMLEFT,92,-50) -- -103
  end
end


function HUDInfamyMeter:updateHisto(hist1, hist2, hist3, hist4, hist5)

  if(PvpMeter.savedVariables.duelMeter == false)then

    histo1:SetText("")
    histo2:SetText("")
    histo3:SetText("")
    histo4:SetText("")
    histo5:SetText("")

    return
  end

  if(hist1 == 2) then histo1:SetHidden(true)
  else
    histo1:SetHidden(false)
    if(hist1 == 1)then
      histo1:SetColor(0.7,0,0)
      histo1:SetText("D")
    else
      histo1:SetColor(0.2,0.7,0)
      histo1:SetText("V")
    end
  end

  if(hist2 == 2) then histo2:SetHidden(true)
  else
    histo2:SetHidden(false)
    if(hist2 == 1)then
      histo2:SetColor(0.7,0,0)
      histo2:SetText("D")
    else
      histo2:SetColor(0.2,0.7,0)
      histo2:SetText("V")
    end
  end

  if(hist3 == 2) then histo3:SetHidden(true)
  else
    histo3:SetHidden(false)
    if(hist3 == 1)then
      histo3:SetColor(0.7,0,0)
      histo3:SetText("D")
    else
      histo3:SetColor(0.2,0.7,0)
      histo3:SetText("V")
    end
  end

  if(hist4 == 2) then histo4:SetHidden(true)
  else
    histo4:SetHidden(false)
    if(hist4 == 1)then
      histo4:SetColor(0.7,0,0)
      histo4:SetText("D")
    else
      histo4:SetColor(0.2,0.7,0)
      histo4:SetText("V")
    end
  end

  if(hist5 == 2) then histo5:SetHidden(true)
  else
    histo5:SetHidden(false)
    if(hist5 == 1)then
      histo5:SetColor(0.7,0,0)
      histo5:SetText("D")
    else
      histo5:SetColor(0.2,0.7,0)
      histo5:SetText("V")
    end
  end

end


function HUDInfamyMeter_Initialize(control)
    HUD_DUEL_METER = HUDInfamyMeter:New(control)
end


function HUDInfamyMeter_Update(start ,endd , hist1, hist2, hist3, hist4, hist5)
  if HUD_DUEL_METER then
    if(endd<0.01)then endd = 0 end
    HUD_DUEL_METER:UpdateBar(HUD_DUEL_METER.infamyBar, 0, 1)
    HUD_DUEL_METER:UpdateBar(HUD_DUEL_METER.bountyBar, start, endd)
    HUD_DUEL_METER:changeColor(endd)
    HUD_DUEL_METER:updateHisto(hist1, hist2, hist3, hist4, hist5)
  end
end


function HUDInfamyMeter_AnimateMeter(progress)
    if HUD_DUEL_METER then
        HUD_DUEL_METER:AnimateMeter(progress)
    end
end


function HUDInfamyMeter_show()
  if HUD_DUEL_METER then
    HUD_DUEL_METER.control:SetHidden(false)
    HUD_DUEL_METER.background:SetHidden(true)
    LabelP:SetHidden(false)
    Perc:SetHidden(false)

    HUD_DUEL_METER.meterFrame:SetHidden(false)
    HUD_DUEL_METER.infamyBar:SetHidden(false)
    HUD_DUEL_METER.bountyBar:SetHidden(false)
    -- REVIEW Is this used and or needed?
    histo1:SetHidden(false)
    histo2:SetHidden(false)
    histo3:SetHidden(false)
    histo4:SetHidden(false)
    histo5:SetHidden(false)
  end
end


function HUDInfamyMeter_hide()
  if HUD_DUEL_METER then
    HUD_DUEL_METER.control:SetHidden(true)
    LabelP:SetHidden(true)
    Perc:SetHidden(true)
    HUD_DUEL_METER.meterFrame:SetHidden(true)
    HUD_DUEL_METER.infamyBar:SetHidden(true)
    HUD_DUEL_METER.bountyBar:SetHidden(true)
  end
end


function HUDInfamyMeter_restore(top,left)
  if HUD_DUEL_METER then
    HUD_DUEL_METER.control:ClearAnchors()
    HUD_DUEL_METER.control:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, left, top)
  end
end


function HUDInfamyMeter_getLeft()
  if HUD_DUEL_METER then
    return HUD_DUEL_METER.control:GetLeft()
  end
end


function HUDInfamyMeter_getTop()
  if HUD_DUEL_METER then
    return HUD_DUEL_METER.control:GetTop()
  end
end