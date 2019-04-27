--@ commons
-- Named components
NamedComponent = {}

function NamedComponent.new(Type)
   local self = {}
   self.Type = Type
   self.LastCount = 0
   self.IndexCache = {}

   self.GetIndex = NamedComponent.GetIndex

   return self
end

function NamedComponent:GetIndex(I, Name, Default)
   if not Default then Default = -1 end

   -- We keeps count cached in commons (gets cleared every update)
   local CountCache = C._NamedComponentCounts
   if not CountCache then
      CountCache = {}
      C._NamedComponentCounts = CountCache
   end

   local Type = self.Type
   local ComponentCount = CountCache[Type]
   if not ComponentCount then
      ComponentCount = I:Component_GetCount(Type)
      CountCache[Type] = ComponentCount
   end

   local IndexCache = self.IndexCache

   if ComponentCount ~= self.LastCount then
      self.LastCount = ComponentCount
      IndexCache = {}
      self.IndexCache = IndexCache

      for i = 0,ComponentCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(Type, i)
         local CustomName = BlockInfo.CustomName
         if CustomName and CustomName ~= "" then
            -- First one wins
            if not IndexCache[CustomName] then
               IndexCache[CustomName] = i
            end
         end
      end
   end

   local Index = IndexCache[Name]
   if Index then
      return Index
   else
      return Default
   end
end
