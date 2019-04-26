--@ commons componenttypes
Commons_LastMainframeCount = 0
Commons_MainframeCache = nil

--# The big assumption here is that component index == mainframe index
--# (wrt targeting, warnings, etc.)
function Commons:MainframeIndex(Specifier)
   -- If it's already a number, use that
   if type(Specifier) == "number" then
      return Specifier
   end

   if not self._MainframeCount then
      -- Potentially, this method can be called multiple times per update.
      -- So cache the one underlying call that cannot be avoided.
      self._MainframeCount = self.I:Component_GetCount(MAINFRAME)
   end
   local MainframeCount = self._MainframeCount
   if MainframeCount ~= Commons_LastMainframeCount then
      Commons_MainframeCache = nil
      Commons_LastMainframeCount = MainframeCount
   end

   if not Commons_MainframeCache then
      Commons_MainframeCache = {}
      for i = 0,MainframeCount-1 do
         local BlockInfo = self.I:Component_GetBlockInfo(MAINFRAME, i)
         local CustomName = BlockInfo.CustomName
         if CustomName and CustomName ~= "" then
            -- First one wins
            if not Commons_MainframeCache[CustomName] then
               Commons_MainframeCache[CustomName] = i
            end
         end
      end
   end

   local Index = Commons_MainframeCache[Specifier]
   if Index then
      return Index
   else
      return 0
   end
end
