--! stabilizer
--@ stabilizer getselfinfo
function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      Stabilizer_Update(I)
   end
end
