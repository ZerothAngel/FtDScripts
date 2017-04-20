-- UTILITY AI

-- Switches to determine utility behavior
IsCollector = true
IsGatherer = true

-- Multiplied by max material storage to determine when to head out.
-- Should be <= 1. Goes collecting or gathering when on-board material
-- is < (max * FreeStorageThreshold).
FreeStorageThreshold = .9

-- Enemy avoidance settings
RunAwayDistance = 3000
RunAwayEvasion = { 30, .25 }

-- Collector configuration
CollectMaxDistance = 5000
CollectMinDistance = 450

-- Gatherer configuration
GatherMaxDistance = 5000
