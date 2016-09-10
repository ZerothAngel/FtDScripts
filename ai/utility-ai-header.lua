-- UTILITY AI

-- Switches to determine utility behavior
IsCollector = true
IsGatherer = true

-- Enemy avoidance settings
RunAwayDistance = 2500
RunAwayDrive = 1
RunAwayEvasion = { 30, .25 }

-- Collector configuration
CollectMaxDistance = 5000
CollectMinDistance = 450
CollectDrive = 1

-- Gatherer configuration
GatherMaxDistance = 5000
GatherMinDistance = 50
GatherDrive = 1
GatherApproachDrive = .1

-- Return-to-origin settings
ReturnToOrigin = true
ReturnDrive = 1
-- Stops after getting within this distance of origin
-- Should be quite generous, depending on your ship's turning
-- radius.
OriginMaxDistance = 250
