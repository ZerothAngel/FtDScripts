-- CONFIGURATION

-- Targets below this altitude will be considered surface
-- targets. The missile will approach surface targets
-- by skimming the surface and then "popping up" near the target
-- (see below). Set to -500 or lower to disable pop up behavior.
AirTargetAltitude = 10

-- POP-UP SETTINGS

-- Altitude to skim the surface
PopUpSkimAltitude = 3
-- When skimming, this is the distance toward the target
-- that it will aim for (smaller means it reaches skimming
-- altitude quicker).
-- This also affects terrain hugging, see below.
PopUpSkimDistance = 50
-- Ground distance from target to pop-up
PopUpDistance = 250
-- Altitude to pop-up to
PopUpAltitude = 30
-- Within this ground distance, the missile will follow a simple
-- intercept course (such as when targeting air targets)
PopUpTerminalDistance = 100

-- TERRAIN HUGGING

-- Resolution, in meters, when looking ahead.
-- The smaller the resolution, the more samples will be taken.
-- While closing (>PopUpDistance from target), the missile will look
-- PopUpSkimDistance meters ahead and adjust according to the highest
-- terrain sampled.
-- When popping up, it will look from its current position to
-- PopUpTerminalDistance *from the target*. (So maximum look-ahead
-- during pop-up is PopUpDistance - PopUpTerminalDistance meters.)
-- Set to a non-positive number to disable terrain hugging
-- (guidance will then always assume you and your target are
-- in/over the ocean...)
LookAheadResolution = 3

-- MISCELLANEOUS

-- The update rate, i.e. run every UpdateRate calls to Update method.
-- Set to 1 to update every call.
-- Setting to e.g. 10 means to run every 10th call.
-- Smaller means more responsive, but also means more processor usage.
UpdateRate = 10
