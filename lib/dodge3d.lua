--@ dodgecommon
-- Dodge (vertical, lateral, longitudinal) module
function Dodge_LastDodge()
   -- Invert signs of impact point coordinates. That is the dodge direction.
   return -LastDodgeDirection[1],-LastDodgeDirection[2],-LastDodgeDirection[3],true
end

function Dodge_NoDodge()
   return 0,0,0,false
end
