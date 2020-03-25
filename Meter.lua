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
        template = "MeterBar_KeyboardTemplate" ,
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


function MeterBar_color(r,g,b)
	if TELVAR_METER then
		TELVAR_METER.meterBarFill:SetFillColor(r,g,b)
		TELVAR_METER.meterBarHighlight:SetFillColor(r,g,b)
		TELVAR_METER.meterOverlayControl:SetColor(r,g,b,0)
		--truck:SetEdgeColor(r,g,b)
	end
end


function MeterBar_moveBar(x,y)
	if TELVAR_METER then
		TELVAR_METER.meterBarControl:ClearAnchors()
		TELVAR_METER.meterOverlayControl:ClearAnchors()

		TELVAR_METER.meterBarControl:SetAnchor(RIGHT,MeterBar_KeyboardTemplate,RIGHT,18+x,18+y)
		TELVAR_METER.meterOverlayControl:SetAnchor(RIGHT,MeterBar_KeyboardTemplate,RIGHT,24+x,18+y)
	end
end


function MeterBar_restore(top,left)
	if TELVAR_METER then
		TELVAR_METER.control:ClearAnchors()
		TELVAR_METER.control:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, left, top)
	end
end


function MeterBar_show()
	if TELVAR_METER then
		TELVAR_METER:SetHiddenForReason("disabledInZone", false)
		--TELVAR_METER.meterBarHighlight:SetHidden()
	end
end


function MeterBar_hide()
	if TELVAR_METER then
		TELVAR_METER:SetHiddenForReason("disabledInZone", true)
		--TELVAR_METER.meterBarHighlight:SetFillColor(r,g,b)
	end
end


function MeterBar_alpha(alpha)
	if TELVAR_METER then
		TELVAR_METER.meterBarControl:SetAlpha(alpha)
	end
end


function MeterBar_first()
	if TELVAR_METER then
		TELVAR_METER.meterBarControl:SetAnchor(RIGHT,MeterBar_KeyboardTemplate,RIGHT,TELVAR_METER_KEYBOARD_BAR_OFFSET_X,18)
	end
end


function MeterBar_sec()
	if TELVAR_METER then
		TELVAR_METER.meterBarControl:SetAnchor(RIGHT,MeterBar_KeyboardTemplate,RIGHT,TELVAR_METER_KEYBOARD_BAR_OFFSET_X,-72)
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
		if(PvpMeter.savedVariables.showBeautifulMeter)then
			TELVAR_METER.meterOverlayControl.fadeAnimation:PlayFromStart()
		end
		if(PvpMeter.savedVariables.alertBorder)then
			TELVAR_METER.alertBorder.pulseAnimation:PlayFromStart()
		end
	end
end