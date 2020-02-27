PVPMetrics = {}
PVPMetrics.name = "PVPMetrics"


-- PVP Metrics class
function PVPMetrics:Initialize()
  PVPMetrics.savedData = ZO_SavedVars:New("PVPMetricsData", 1, nil,{})
  PVPMetrics.savedDataAcc = ZO_SavedVars:NewAccountWide("PVPMetricsData", 1, nil,{})
end


function PVPMetrics.OnAddOnLoaded(event, addonName)
  if addonName == PVPMetrics.name then	
     PVPMetrics.Initialize()
  end
end
 

-- The initial event to load the Addon
do
    EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED, PVPMetrics.OnAddOnLoaded)
end
