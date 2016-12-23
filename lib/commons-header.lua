-- COMMONS SETTINGS

Commons = {
   -- Preferred mainframe indexes for target priority.
   -- Once a mainframe is successfully queried, the rest are ignored.
   -- First mainframe (in "C" screen) = 0, 2nd = 1, etc.
   -- The last one in the list should always be 0.
   -- For example, to query the 2nd, 3rd, and 1st (in that order), set
   -- to { 1, 2, 0 }
   PreferredTargetMainframes = { 0 },

   -- Maximum range for an enemy to still be considered a threat.
   MaxEnemyRange = 10000,
}
