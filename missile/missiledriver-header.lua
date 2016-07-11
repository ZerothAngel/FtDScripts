-- GENERAL MISSILE SETTINGS

-- Set up the list of preferred mainframes here. The mainframes are queried
-- in the order given. Once a mainframe is successfully queried, the rest are
-- no longer consulted. Note that this also means that target priorities are
-- taken from the first mainframe successfully queried. This makes it very
-- important to set proper constraints in your Local Weapon Controller so
-- missiles aren't being fired at targets they can't hit!

-- Mainframes are numbered starting from 0, so the 1st mainframe is 0, the 2nd
-- is 1, etc. In the face of damage (or repair), the ordering of mainframes
-- changes. So this something to keep in mind.

-- If your list doesn't include mainframe 0, it is a good idea to add it at the
-- end as an ultimate backup. For example, if you want to query the 2nd then the
-- 3rd mainframes, set this to { 1, 2, 0 }. There will always be a mainframe 0 as
-- long as there is at least one mainframe on the vehicle.
PreferredMainframes = { 0 }

-- Detonate after this many seconds of being out of combat.
-- Set to some large number (e.g. 999) to disable.
DetonateAfter = 10
