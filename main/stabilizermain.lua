--! stabilizer
--@ stabilizer commons
function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() then
      Stabilizer_Update(I)
   end
end
