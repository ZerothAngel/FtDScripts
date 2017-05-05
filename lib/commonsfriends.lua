--@ commons
function Commons:Friendlies()
   if not self._Friendlies then
      local Friendlies = {}
      for findex = 0,self.I:GetFriendlyCount()-1 do
         local FriendlyInfo = self.I:GetFriendlyInfo(findex)
         if FriendlyInfo.Valid then -- Pointless check?
            table.insert(Friendlies, FriendlyInfo)
            -- Pre/re-populate ID mapping
            self._FriendliesById[FriendlyInfo.Id] = FriendlyInfo
         end
      end
      self._Friendlies = Friendlies
   end
   return self._Friendlies
end

function Commons:FriendlyById(Id)
   local FriendlyInfo = self._FriendliesById[Id]
   if not FriendlyInfo then
      FriendlyInfo = self.I:GetFriendlyInfoById(Id)
      -- Valid will be false if it doesn't exist, but save
      -- the table regardless so we don't check again
      self._FriendliesById[Id] = FriendlyInfo
   end
   return FriendlyInfo
end
