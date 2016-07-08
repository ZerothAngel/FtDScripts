-- GetTargetInfo module
TargetInfo = nil

-- Finds first valid target on first mainframe
function GetTargetInfo(I)
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         TargetInfo = I:GetTargetInfo(mindex, tindex)
         if TargetInfo.Valid and TargetInfo.Protected then return true end
      end
   end
   TargetInfo = nil
   return false
end
