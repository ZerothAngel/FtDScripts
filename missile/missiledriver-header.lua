-- MISSILE DRIVER SETTINGS

-- Detonate after this many seconds of being out of combat.
-- Set to some large number (e.g. 999) to disable.
DetonateAfter = 10

-- Reset/clear the transceiver cache every so often.
-- Set to some large number (e.g. 9999) to disable.
-- This is mainly important for any scripts that use GetLuaTransceiverInfo
-- to select a guidance instance, such as multiprofile. This is because
-- damage may knock out a launchpad (which is what is normally returned)
-- and instead return the transceiver BlockInfo, which may ultimately lead
-- to a different selection.
TransceiverResetInterval = 5
