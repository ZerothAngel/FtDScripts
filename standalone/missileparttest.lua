local KeepGoing = true

function Update(I)
   if KeepGoing then
      for tindex = 0,I:GetLuaTransceiverCount()-1 do
         for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
            local MissileInfo = I:GetMissileInfo(tindex, mindex)
            for i = 1,#MissileInfo.Parts do
               local part = MissileInfo.Parts[i]
               I:Log(string.format("%d %s", i, part.Name))
            end
            KeepGoing = false
         end
      end
   end
end
