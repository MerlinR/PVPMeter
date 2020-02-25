MENU_METER_WIDTH = 256
MENU_METER_HEIGHT = 128
MENU_METER_KEYBOARD_BAR_OFFSET_X = 14
MENU_METER_KEYBOARD_BAR_OFFSET_Y = 15
MENU_METER_GAMEPAD_BAR_OFFSET = 10

local MENU_METER_UPDATE_DELAY_SECONDS = 1

 -- Forces the bar to be at least 3% full, in order to make it visible even at one or two bounty
local MIN_BAR_PERCENTAGE = 0.03

local UPDATE_TYPE_TICK = 0
local UPDATE_TYPE_EVENT = 1

local MENU_METER_SLOW_FADE_TIME = 1400 -- in milliseconds
local MENU_METER_SLOW_FADE_DELAY = 600 -- in milliseconds
local MENU_METER_FADE_TIME = 200 -- in milliseconds

local CENTER_ICON_STATE_DAGGER_GREY = 1
local CENTER_ICON_STATE_DAGGER_RED = 2
local CENTER_ICON_STATE_EYE = 3

local GREY_DAGGER_ICON = ""
local RED_DAGGER_ICON = ""
local DAGGER_ICON_CUTOUT = ""
local RED_EYE_ICON = "EsoUI/Art/HUD/trespassing_eye-red.dds"
local EYE_ICON_CUTOUT = "EsoUI/Art/HUD/trespassing_eye-cutout.dds"

local HUDMenuMeter = ZO_Object:Subclass()


function HUDMenuMeter:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end


function HUDMenuMeter:Initialize(control)
  -- Initialize state
  self.nextUpdateTime = 0
  self.hiddenExternalRequest = false
  self.meterTotal = GetInfamyMeterSize()
  --d( GetInfamyMeterSize())
  self.MenuMeterState = {}
  --self:UpdateMenuMeterState(0, 0, false, false)

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
  ApplyTemplateToControl(control, self.isInGamepadMode and "HUDMenuMeter_GamepadTemplate" or "HUDMenuMeter_KeyboardTemplate")
  self.control = control
  self.background = control:GetNamedChild("Background")
  self.meterFrame = control:GetNamedChild("Frame")
  self.MenuBar = control:GetNamedChild("MenuBar")
  self.bountyBar = control:GetNamedChild("BountyBar")
  self.centerIconAnimatingTexture = control:GetNamedChild("CenterIconAnimatingTexture")
  self.centerIconPersistentTexture = control:GetNamedChild("CenterIconPersistentTexture")
  self.bountyLabel = control:GetNamedChild("BountyDisplay")

  -- Set up fade in/out animations
  self.fadeAnim = ZO_AlphaAnimation:New(control)
  self.fadeAnim:SetMinMaxAlpha(0.0, 1.0)

  -- Initialize bar states and animations
  self.MenuBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDMenuMeterEasing")
  self.MenuBar.startPercent = 0
  self.MenuBar.endPercent = 0.5

  self.bountyBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDMenuMeterEasing")
  self.bountyBar.startPercent = 0
  self.bountyBar.endPercent = 1

  control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
    self.control:SetHidden(false)
  end)

end


function HUDMenuMeter:ShouldProcessUpdateEvent()
    local Menu = GetMenu()
    local isKOS = IsKillOnSight()
    local isTrespassing = IsTrespassing()
    return IsInJusticeEnabledZone()
           and not self.hiddenExternalRequest
           and ((Menu ~= 0 and Menu ~= self.MenuMeterState["Menu"]) or isTrespassing ~= self.MenuMeterState["isTrespassing"])
end


function HUDMenuMeter:Update(time)
    if self.nextUpdateTime <= time and not self.hiddenExternalRequest and IsInJusticeEnabledZone() then
        self.nextUpdateTime = time + MENU_METER_UPDATE_DELAY_SECONDS
        --self:OnMenuUpdated(UPDATE_TYPE_TICK)
    end
end


function HUDMenuMeter:OnMenuUpdated(updateType)
    --local oldMenu, oldBounty, wasKOS, wasTrespassing = self:GetOldMenuMeterState()
    --self:UpdateMenuMeterState()

    --local gamepadModeSwitchUpdate = IsInGamepadPreferredMode() ~= self.isInGamepadMode

  self:UpdateBar(self.MenuBar, 0, 1)
  self:UpdateBar(self.bountyBar, 0, 0.5)
end


function HUDMenuMeter:UpdateBar(bar, start, endd)
    if not bar.easeAnimation:IsPlaying() or updateType == UPDATE_TYPE_EVENT then
      -- Update Values
        bar.startPercent = start
      bar.endPercent = endd

      self:SetBarValue(bar, bar.startPercent)

      -- Start the animation
      bar.easeAnimation:PlayFromStart()
    end
end


function HUDMenuMeter:AnimateMeter(progress)
  local MenuFillPercentage = zo_min((progress * (self.MenuBar.endPercent - self.MenuBar.startPercent)) + self.MenuBar.startPercent, 1)
  local bountyFillPercentage = zo_min((progress * (self.bountyBar.endPercent - self.bountyBar.startPercent)) + self.bountyBar.startPercent, 1)
  local MenuMinPercentage = self.MenuMeterState["Menu"] ~= 0 and MIN_BAR_PERCENTAGE or 0
  local bountyMinPercentage = self.MenuMeterState["bounty"] ~= 0 and MIN_BAR_PERCENTAGE or 0
  self:SetBarValue(self.MenuBar, zo_max(MenuFillPercentage, MenuMinPercentage))
  self:SetBarValue(self.bountyBar, zo_max(bountyFillPercentage, bountyMinPercentage))
end


function HUDMenuMeter:SetBarValue(bar, percentFilled)
  bar:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE) -- CD_TIME_TYPE_TIME_REMAINING causes clockwise scroll
end


function HUDMenuMeter:changeColor(endd)
  if(endd > 0.49) then
    LabelPMenu:SetColor(0.2,0.7,0)
    PercMenu:SetColor(0.2,0.7,0)
  end
  if(endd <= 0.49) then
    LabelPMenu:SetColor(0.7,0,0)
    PercMenu:SetColor(0.7,0,0)
  end

  local txt = math.floor(endd*100)

  LabelPMenu:SetText(txt)
  PercMenu:SetText("%")

  if(txt<100) then
    PercMenu:SetAnchor(BOTTOMRIGHT,LabelPMenu,BOTTOMLEFT,42,-3) -- -103
  else
    PercMenu:SetAnchor(BOTTOMRIGHT,LabelPMenu,BOTTOMLEFT,54,-3) -- -103
  end
end


function HUDMenuMeter:updateHisto(hist1, hist2, hist3, hist4, hist5)
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

function HUDMenuMeter_Initialize(control)
    HUD_MENU_METER = HUDMenuMeter:New(control)
end

function HUDMenuMeter_Update(start ,endd)
  if HUD_MENU_METER then
    if(endd<0.01)then endd = 0 end
    HUD_MENU_METER:UpdateBar(HUD_MENU_METER.MenuBar, 0, 1)
    HUD_MENU_METER:UpdateBar(HUD_MENU_METER.bountyBar, start, endd)
    HUD_MENU_METER:changeColor(endd)
  end
end

function HUDMenuMeter_AnimateMeter(progress)
    if HUD_MENU_METER then
        HUD_MENU_METER:AnimateMeter(progress)
    end
end

function HUDMenuMeter_show()
  if HUD_MENU_METER then
    HUD_MENU_METER.control:SetHidden(false)

    HUD_MENU_METER.centerIconAnimatingTexture:SetHidden(true)
    HUD_MENU_METER.centerIconPersistentTexture:SetHidden(true)
    HUD_MENU_METER.background:SetHidden(true)

    LabelPMenu:SetHidden(false)
    PercMenu:SetHidden(false)
    HUD_MENU_METER.MenuBar:SetHidden(false)
    HUD_MENU_METER.bountyBar:SetHidden(false)
  end
end

function HUDMenuMeter_hide()
  if HUD_MENU_METER then
    HUD_MENU_METER.control:SetHidden(true)
    LabelPMenu:SetHidden(true)
    PercMenu:SetHidden(true)
    HUD_MENU_METER.MenuBar:SetHidden(true)
    HUD_MENU_METER.bountyBar:SetHidden(true)
  end
end


function HUDMenuMeter_restore(top,left)
  if HUD_MENU_METER then
    HUD_MENU_METER.control:ClearAnchors()
    HUD_MENU_METER.control:SetAnchor(TOPLEFT, PvpMeterMenu,TOPLEFT, left, top)
  end
end


function HUDMenuMeter_getLeft()
  if HUD_MENU_METER then
    return HUD_MENU_METER.control:GetLeft()
  end
end


function HUDMenuMeter_getTop()
  if HUD_MENU_METER then
    return HUD_MENU_METER.control:GetTop()
  end
end

