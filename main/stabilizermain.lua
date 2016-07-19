--! stabilizer
--@ stabilizer getselfinfo
function Update(I)
   if not I:IsDocked() and I.AIMode ~= "off" then
      GetSelfInfo(I)

      Stabilizer_Update(I)
   end
end
