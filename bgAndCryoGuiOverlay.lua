-- This files contains the GUI Overlay for Cryo and BG

BG_AVA_OVERLAY_WIDTH = 256
BG_AVA_OVERLAY_HEIGHT = 128
BG_AVA_OVERLAY_KEYBOARD_BAR_OFFSET_X = 14
BG_AVA_OVERLAY_KEYBOARD_BAR_OFFSET_Y = 18
BG_AVA_OVERLAY_GAMEPAD_BAR_OFFSET_X = -9
BG_AVA_OVERLAY_GAMEPAD_BAR_OFFSET_Y = 15

local BGandAvAOverlay = ZO_Object:Subclass()

function BGandAvAOverlay:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end


function BGandAvAOverlay:Initialize(control)
  -- Initialize state
  self.hiddenReasons = ZO_HiddenReasons:New()
  self.telvarStoneThreshold = GetTelvarStoneMultiplierThresholdIndex()

  -- Set up controls
  self.alertBorder = HUDTelvarAlertBorder
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
    template = "BGandAvAOverlay_KeyboardTemplate" ,
    currencyOptions =
    {
      showTooltips = true,
      customTooltip = SI_CURRENCYTYPE3,
      isGamepad = false,
      font = "ZoFontGameLargeBold",
      iconSide = RIGHT,
    },
  }
  self.gamepadStyle =
  {
    template = "BGandAvAOverlay_KeyboardTemplate",
    currencyOptions =
    {
      showTooltips = true,
      customTooltip = SI_CURRENCYTYPE3,
      isGamepad = false,
      font = "ZoFontGameLargeBold",
      iconSide = RIGHT,
    },
  }
  ZO_PlatformStyle:New(function(...) self:UpdatePlatformStyle(...) end, self.keyboardStyle, self.gamepadStyle)

  -- Initialize alert border animation
  self.alertBorder.pulseAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDTelvarAlertBorderAnimation", self.alertBorder)

  -- Initialize overlay animation
  self.meterOverlayControl.fadeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("BGandAvAOverlayOverlayFade", self.meterOverlayControl)

  -- Initialize label animation
  self.multiplierContainer.bounceAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("BGandAvAOverlayMultiplierBounce", self.multiplierContainer)

  -- Initialize bar states and animations
  self.meterBarControl.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("BGandAvAOverlayEasing")
  self.meterBarControl.startPercent = 0
  self.meterBarControl.endPercent = 0

  -- Initialize edge animation

  -- Register for events
  --control:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function(...) self:OnTelvarStonesUpdated(...) end)

  control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
    if DoesCurrentZoneHaveTelvarStoneBehavior() then
      TriggerTutorial(TUTORIAL_TRIGGER_TELVAR_ZONE_ENTERED)
      self:SetHiddenForReason("disabledInZone", false)
    else
      self:SetHiddenForReason("disabledInZone", false)
      --self:UpdateMeterBar()
    end
  end)

  --control:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function() self:UpdateMeterBa end)

  -- Do our initial update
  self:SetBarValue(self.meterBarControl.startPercent)
  self:OnTelvarStonesUpdated()
end


function BGandAvAOverlay:SetHiddenForReason(reason, hidden)
  self.hiddenReasons:SetHiddenForReason(reason, hidden)
  self.control:SetHidden(self.hiddenReasons:IsHidden())
end


function BGandAvAOverlay:OnTelvarStonesUpdated()
  newTelvarStones = 80
  oldTelvarStones = 10
  --reason = CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER

  --PlaySound(SOUNDS.TELVAR_GAINED)
  self:UpdateMeterBar()
end


function BGandAvAOverlay:UpdateMeterBar()
  -- Update bar values
  --self.meterBarControl.startPercent = 0.01
  --self.meterBarControl.endPercent = 0.99

  -- Start the bar animation
  self.meterBarControl.easeAnimation:PlayFromStart()
end

function BGandAvAOverlay:AnimateMeter(progress)
  local fillPercentage = zo_min((progress * (self.meterBarControl.endPercent - self.meterBarControl.startPercent)) + self.meterBarControl.startPercent, 1)
  self:SetBarValue(fillPercentage)
end


function BGandAvAOverlay:SetBarValue(percentFilled)
  self.meterBarFill:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE) -- CD_TIME_TYPE_TIME_REMAINING causes clockwise scroll
  self.meterBarHighlight:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
end


function BGandAvAOverlay:UpdatePlatformStyle(styleTable)
  ApplyTemplateToControl(self.control, styleTable.template)
  ZO_CurrencyControl_SetSimpleCurrency(self.telvarDisplayControl, CURT_TELVAR_STONES, GetCarriedCurrencyAmount(CURT_TELVAR_STONES), styleTable.currencyOptions, CURRENCY_SHOW_ALL)

  local isMaxThreshold = IsMaxTelvarStoneMultiplierThreshold(self.telvarStoneThreshold)
  self.meterBarControl:SetHidden(isMaxThreshold)
  self.meterOverlayControl:SetAlpha(isMaxThreshold and 1 or 0)
end



function BGandAvAOverlay:CalculateMeterFillPercentage()
  if IsMaxTelvarStoneMultiplierThreshold(self.telvarStoneThreshold) then
    return 1
  elseif self.telvarStoneThreshold then -- Protect against self.telvarStoneThreshold being nil.
    local currentThresholdAmount = GetTelvarStoneThresholdAmount(self.telvarStoneThreshold)
    local nextThresholdAmount = GetTelvarStoneThresholdAmount(self.telvarStoneThreshold + 1)
    local result = (GetCarriedCurrencyAmount(CURT_TELVAR_STONES) - currentThresholdAmount) / (nextThresholdAmount - currentThresholdAmount)
    return zo_max(result, 0)
  else
    return 0
  end
end


function BGandAvAOverlay_Initialize(control)
  BG_AVA_OVERLAY = BGandAvAOverlay:New(control)
end


function BGandAvAOverlay_update(startP,endP)
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.meterBarControl.startPercent = startP
    BG_AVA_OVERLAY.meterBarControl.endPercent = endP
    BG_AVA_OVERLAY:OnTelvarStonesUpdated()
  end
end


function BGandAvAOverlay_color(r,g,b)
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.meterBarFill:SetFillColor(r,g,b)
    BG_AVA_OVERLAY.meterBarHighlight:SetFillColor(r,g,b)
    BG_AVA_OVERLAY.meterOverlayControl:SetColor(r,g,b,0)
  end
end


function BGandAvAOverlay_moveBar(x,y)
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.meterBarControl:ClearAnchors()
    BG_AVA_OVERLAY.meterOverlayControl:ClearAnchors()

    BG_AVA_OVERLAY.meterBarControl:SetAnchor(RIGHT,BGandAvAOverlay_KeyboardTemplate,RIGHT,18+x,18+y)
    BG_AVA_OVERLAY.meterOverlayControl:SetAnchor(RIGHT,BGandAvAOverlay_KeyboardTemplate,RIGHT,24+x,18+y)
  end

end


function BGandAvAOverlay_colorAlert(r,g,b)
  if BG_AVA_OVERLAY then
    local truck = HUDTelvarAlertBorder:GetNamedChild("Overlay")
    truck:SetEdgeColor(r,g,b)
  end
end


function BGandAvAOverlay_restore(top,left)
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.control:ClearAnchors()
    BG_AVA_OVERLAY.control:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, left, top)
  end
end


function BGandAvAOverlay_show()
  if (PvpMeter.savedVariables.showBeautifulMeter) then
    if BG_AVA_OVERLAY then
      BG_AVA_OVERLAY:SetHiddenForReason("disabledInZone", false)
      --BG_AVA_OVERLAY.meterBarHighlight:SetHidden()
    end
  end
end


function BGandAvAOverlay_hide()
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY:SetHiddenForReason("disabledInZone", true)
    --BG_AVA_OVERLAY.meterBarHighlight:SetFillColor(r,g,b)
  end
end


function BGandAvAOverlay_alpha(alpha)
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.meterBarControl:SetAlpha(alpha)
  end
end


function BGandAvAOverlay_first()
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.meterBarControl:SetAnchor(RIGHT,BGandAvAOverlay_KeyboardTemplate,RIGHT,BG_AVA_OVERLAY_KEYBOARD_BAR_OFFSET_X,18)
  end
end


function BGandAvAOverlay_sec()
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY.meterBarControl:SetAnchor(RIGHT,BGandAvAOverlay_KeyboardTemplate,RIGHT,BG_AVA_OVERLAY_KEYBOARD_BAR_OFFSET_X,-72)
  end
end


function BGandAvAOverlay_getLeft()
  if BG_AVA_OVERLAY then
    return BG_AVA_OVERLAY.control:GetLeft()
  end
end


function BGandAvAOverlay_getTop()
  if BG_AVA_OVERLAY then
    return BG_AVA_OVERLAY.control:GetTop()
  end
end


function BGandAvAOverlay_UpdateMeterToAnimationProgress(progress)
  if BG_AVA_OVERLAY then
    BG_AVA_OVERLAY:AnimateMeter(progress)
  end
end


function BGandAvAOverlay_gamepad(option,left)
  if BG_AVA_OVERLAY then
    if (option) then
      BG_AVA_OVERLAY.meterBarControl:SetAnchor(RIGHT,BGandAvAOverlay_KeyboardTemplate,RIGHT,80,18)
    else
      BG_AVA_OVERLAY.meterBarControl:SetAnchor(RIGHT,BGandAvAOverlay_KeyboardTemplate,RIGHT,18,18)
    end
  end
end


function BGandAvAOverlay_Anim()
  if BG_AVA_OVERLAY then
    if (PvpMeter.savedVariables.showBeautifulMeter) then
      BG_AVA_OVERLAY.meterOverlayControl.fadeAnimation:PlayFromStart()
    end
    if (PvpMeter.savedVariables.alertBorder) then
      BG_AVA_OVERLAY.alertBorder.pulseAnimation:PlayFromStart()
    end
  end
end