--@ commons commonsmainframe
function Commons:MissileWarnings()
   if not self._MissileWarnings then
      local Mainframe = self:MainframeIndex(CommonsWarningConfig.MissileWarningMainframe)
      local Warnings = {}
      for i = 0,self.I:GetNumberOfWarnings(Mainframe)-1 do
         local Warning = self.I:GetMissileWarning(Mainframe, i)
         if Warning.Valid then
            --# Need to evaluate if copying it is necessary...
            local Info = {
               Id = Warning.Id,
               MainframeIndex = Mainframe, -- Only 1 mainframe for now...
               Index = i,
               Position = Warning.Position,
               Velocity = Warning.Velocity,
               Range = Warning.Range,
            }
            table.insert(Warnings, Info)
         end
      end
      self._MissileWarnings = Warnings
   end
   return self._MissileWarnings
end
