function SetWheelDriveFraction(I, Left, Right)
   for i=0,I:Component_GetCount(9)-1 do
      local Info = I:Component_GetBlockInfo(9, i)
      local Position = Info.LocalPositionRelativeToCom
      if Position.x < 0 then
         I:Component_SetFloatLogic(9, i, Left)
      elseif Position.x > 0 then
         I:Component_SetFloatLogic(9, i, Right)
      end
   end
end

function Update(I) -- luacheck: ignore 131
   I:RequestControl(0, 8, .5)
   SetWheelDriveFraction(I, 1, 0)
end
