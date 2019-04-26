--! mainframetest
--@ commonsmainframe

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      I:LogToHud(string.format("Main = %d, Backup = %d",
                               C:MainframeIndex("Main"),
                               C:MainframeIndex("Backup")))
   end
end
