--@ commons
-- Named components
NamedComponent = {}

function NamedComponent.new(Type)
   local self = {}
   self.Type = Type
   self.LastCount = 0
   self.IndexCache = {}
   self.AllIndexCache = {}

   self.Gather = NamedComponent.Gather
   self.GetIndex = NamedComponent.GetIndex
   self.GetIndices = NamedComponent.GetIndices

   return self
end

function NamedComponent:Gather(I)
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

   if ComponentCount ~= self.LastCount then
      self.LastCount = ComponentCount
      local IndexCache = {}
      self.IndexCache = IndexCache
      local AllIndexCache = {}
      self.AllIndexCache = AllIndexCache

      for i = 0,ComponentCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(Type, i)
         local CustomName = BlockInfo.CustomName
         if CustomName and CustomName ~= "" then
            -- First one wins
            if not IndexCache[CustomName] then
               IndexCache[CustomName] = i
            end
            -- And capture duplicates in a list
            local Indices = AllIndexCache[CustomName]
            if not Indices then
               Indices = {}
               AllIndexCache[CustomName] = Indices
            end
            table.insert(Indices, i)
         end
      end
   end
end

function NamedComponent:GetIndex(I, Name, Default)
   if not Default then Default = -1 end

   self:Gather(I)

   local Index = self.IndexCache[Name]
   if Index then
      return Index
   else
      return Default
   end
end

function NamedComponent:GetIndices(I, Name)
   self:Gather(I)

   local Indices = self.AllIndexCache[Name]
   if Indices then
      -- Return a copy
      return { unpack(Indices) }
   else
      return {}
   end
end
