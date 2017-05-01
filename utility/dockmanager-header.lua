-- DOCK MANAGER

DockManagerConfig = {
   -- Ground distance from an enemy to be considered a threat.
   ThreatDistance = 5000,
   -- Delay this many seconds after the first enemy detection before releasing
   -- the first dock.
   ReleaseDelay = 0,
   -- If nil then all tractor beams will be released simultaneously. Otherwise,
   -- they will be released in front-to-back order (i.e. based on their
   -- relative position to the CoM) with this many seconds in between.
   SequentialDelay = 10,
   -- After all threats have disappeared, reactivate all tractor beams after
   -- this delay.
   RecallDelay = 60,
}
