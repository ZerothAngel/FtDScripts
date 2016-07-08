--! mixedmissiles
--@ popupmissile bottomattacktorpedo periodic
-- Mixed missiles main
MyMissile = PopUpMissile.create()
MyTorpedo = BottomAttackTorpedo.create()

VERTICAL = 0
HORIZONTAL = 1

TransceiverOrientations = {}
LastTransceiverCount = 0

MissileTargetInfo = nil
TorpedoTargetInfo = nil

-- Custom GetTargetInfo to deal with secondary targets
function GetTargetInfo(I)
   MissileTargetInfo = nil
   TorpedoTargetInfo = nil
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         local TargetInfo = I:GetTargetInfo(mindex, tindex)
         if TargetInfo.Valid and TargetInfo.Protected then
            local TargetAltitude = TargetInfo.Position.y
            if not MissileTargetInfo and TargetAltitude >= MissileMinAltitude then
               MissileTargetInfo = TargetInfo
            end
            if not TorpedoTargetInfo and TargetAltitude <= TorpedoMaxAltitude then
               TorpedoTargetInfo = TargetInfo
            end
            -- Once we have both, return right away
            if MissileTargetInfo and TorpedoTargetInfo then return true end
         end
      end
   end
   return MissileTargetInfo or TorpedoTargetInfo
end

function IsVertical(Info)
   -- NB If perpendicular, it's usually never exactly 0
   return math.abs(Vector3.Dot(Info.LocalForwards, Vector3.up)) > 0.001
end

function SetTarget(I, MyController, TargetInfo)
   if TargetInfo then
      local TargetPosition,TargetAimPoint,TargetVelocity = TargetInfo.Position,TargetInfo.AimPointPosition,TargetInfo.Velocity
      MyController:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity)
      return TargetPosition, TargetAimPoint, TargetVelocity
   else
      return nil, nil, nil
   end
end

function Guide(I, tindex, MyController, TargetPosition, TargetAimPoint, TargetVelocity)
   for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
      local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
      if Missile.Valid then
         local AimPoint = MyController:Guide(I, tindex, mindex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)

         I:SetLuaControlledMissileAimPoint(tindex, mindex, AimPoint.x, AimPoint.y, AimPoint.z)
      end
   end
end

-- Main update loop
function MissileMain_Update(I)
   if GetTargetInfo(I) then
      local MTargetPosition,MTargetAimPoint,MTargetVelocity = SetTarget(I, MyMissile, MissileTargetInfo)
      local TTargetPosition,TTargetAimPoint,TTargetVelocity = SetTarget(I, MyTorpedo, TorpedoTargetInfo)

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

         if Orientation == VERTICAL and MissileTargetInfo then
            Guide(I, tindex, MyMissile, MTargetPosition, MTargetAimPoint, MTargetVelocity)
         elseif Orientation == HORIZONTAL and TorpedoTargetInfo then
            Guide(I, tindex, MyTorpedo, TTargetPosition, TTargetAimPoint, TTargetVelocity)
         end
      end
   end
end

MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I)
   MissileMain:Tick(I)
end
