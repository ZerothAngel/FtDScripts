--@ maxenemyrange
-- GetTargetPositionInfo module
TargetPositionInfo = nil

-- Finds first valid target on first mainframe
function GetTargetPositionInfo(I)
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         TargetPositionInfo = I:GetTargetPositionInfo(mindex, tindex)
         if TargetPositionInfo.Valid and TargetPositionInfo.Range <= MaxEnemyRange then return true end
      end
   end
   TargetPositionInfo = nil
   return false
end
