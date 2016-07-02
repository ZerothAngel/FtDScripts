--! mixedmissiles
--@ popupmissile bottomattacktorpedo gettargetinfo periodic
-- Mixed missiles main
MyMissile = PopUpMissile.create()
MyTorpedo = BottomAttackTorpedo.create()

VERTICAL = 0
HORIZONTAL = 1

TransceiverOrientations = {}
LastTransceiverCount = 0

function IsVertical(Info)
   -- NB If perpendicular, it's usually never exactly 0
   return math.abs(Vector3.Dot(Info.LocalForwards, Vector3.up)) > 0.001
end

-- Main update loop
function MissileMain_Update(I)
   if GetTargetInfo(I) then
      local TargetPosition = TargetInfo.Position
      local TargetAimPoint = TargetInfo.AimPointPosition
      local TargetVelocity = TargetInfo.Velocity

      MyMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
      MyTorpedo:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)

      local TransceiverCount = I:GetLuaTransceiverCount()
      if TransceiverCount ~= LastTransceiverCount then
         -- Reset orientations if transceiver count changed
         -- (most likely due to damage)
         TransceiverOrientations = {}
         LastTranceiverCount = TransceiverCount
      end

      for tindex = 0,TransceiverCount-1 do
         local Orientation = TransceiverOrientations[tindex]
         if not Orientation then
            -- Get launch pad orientation and cache it
            local Info = I:GetLuaTransceiverInfo(tindex)
            Orientation = IsVertical(Info) and VERTICAL or HORIZONTAL
            TransceiverOrientations[tindex] = Orientation
         end

         local MyController = Orientation == VERTICAL and MyMissile or MyTorpedo

         for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
            local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
            if Missile.Valid then
               local AimPoint = MyController:Guide(I, tindex, mindex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)

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
