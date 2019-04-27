--@ commons namedcomponent componenttypes
Commons_MainframeNamedComponent = NamedComponent.new(MAINFRAME)

--# The big assumption here is that component index == mainframe index
--# (wrt targeting, warnings, etc.)
function Commons:MainframeIndex(Specifier)
   -- If it's already a number, use that
   if type(Specifier) == "number" then
      return Specifier
   end

   return Commons_MainframeNamedComponent:GetIndex(self.I, Specifier, 0)
end
