--@ dodgecommon
-- Dodge (yaw-only) module
function Dodge_LastDodge()
   -- Turn toward opposite side, reverse if behind CoM
   -- Also return opposite of Y impact, since it might be useful for
   -- non-surface ships.
   return -45*LastDodgeDirection[1] * LastDodgeDirection[3],-LastDodgeDirection[2],true
end

function Dodge_NoDodge()
   return 0,0,false
end
