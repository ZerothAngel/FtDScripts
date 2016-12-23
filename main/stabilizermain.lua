--! stabilizer
--@ stabilizer commons
function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      C = Commons.create(I)

      Stabilizer_Update(I)
   end
end
