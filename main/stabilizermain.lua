--! stabilizer
--@ stabilizer getselfinfo
function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      Stabilizer_Update(I)
   end
end
