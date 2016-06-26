-- CONFIGURATION

-- Targets below this altitude will be considered surface
-- targets. The missile will approach surface targets
-- by skimming the surface and then "popping up" near the target
-- (see below). Set to -500 or lower to disable pop up behavior.
AirTargetAltitude = 10

-- POP-UP SETTINGS

-- Altitude to skim the surface
-- Note, does not currently follow terrain. (Maybe someday...)
PopUpSkimAltitude = 3
-- When skimming, this is the distance toward the target
-- that it will aim for (smaller means it reaches skimming
-- altitude quicker).
PopUpSkimDistance = 50
-- Ground distance from target to pop-up
PopUpDistance = 250
-- Altitude to pop-up to
PopUpAltitude = 30
-- Within this ground distance, the missile will follow a simple
-- intercept course (such as when targeting air targets)
PopUpTerminalDistance = 100
