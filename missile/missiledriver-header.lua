-- GENERAL MISSILE SETTINGS

-- You can configure the missiles to use one or more mainframes here,
-- with 0 being the first mainframe, 1 being the 2nd, etc. The mainframes
-- are scanned in the order given and any unique targets are remembered.
-- In general, all mainframes can see all targets, so this is more of a
-- backup list.

-- However, this is unreliable in the face of damage, e.g. if the first
-- mainframe gets destroyed, then the 2nd mainframe becomes mainframe 0.

-- For best results, it should point to mainframe(s) with priorization and
-- aim point cards. If your list doesn't include mainframe 0, then that
-- should be added to the end of the list.

-- For example, to check only the 2nd and 3rd mainframes for targets,
-- set this to { 1, 2, 0 }. Remember, having 0 in the list is for
-- absolute last-resort backup as there will always be a mainframe 0
-- as long as there is at least one mainframe.

-- FINALLY... Because of the nature of this script, multiple mainframes
-- don't help in prioritizing targets. Multiple mainframes merely serve
-- as backups and priorities comes from the first live mainframe scanned.
-- Sorry!
PreferredMainframes = { 0 }

-- Detonate after this many seconds of being out of combat.
-- Set to some large number (e.g. 999) to disable.
DetonateAfter = 10
