--! prstabilizer
--@ commons pitchrollstab
function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      PRStabilizer_Update(I)
   end
end
