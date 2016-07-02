--! popupmissile
--@ popupmissile gettargetinfo periodic
-- Pop up missile main
MyMissile = PopUpMissile.create()

-- Main update loop
function MissileMain_Update(I)
   if GetTargetInfo(I) then
      local TargetPosition = TargetInfo.Position
      local TargetAimPoint = TargetInfo.AimPointPosition
      local TargetVelocity = TargetInfo.Velocity

      MyMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)

      for tindex = 0,I:GetLuaTransceiverCount()-1 do
         for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
            local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
            if Missile.Valid then
               local AimPoint = MyMissile:Guide(I, tindex, mindex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)

               I:SetLuaControlledMissileAimPoint(tindex, mindex, AimPoint.x, AimPoint.y, AimPoint.z)
            end
         end
      end
   end
end

MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I)
   MissileMain:Tick(I)
end
