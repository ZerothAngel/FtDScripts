--@ deepcopy quadraticintercept
-- Fake TDC module

FakeTDC = {}

function FakeTDC.new(Config)
   local self = deepcopy(Config)

   self.Guide = FakeTDC.Guide

   return self
end

function FakeTDC:Guide(_, _, _, Target, Missile, MissileState)
   -- State management
   if MissileState.Active == nil then
      -- Always start active, regardless of launch timer
      MissileState.Active = true
   end

   if MissileState.Active then
      local MissilePosition,MissileVelocity = Missile.Position,Missile.Velocity
      local AimPoint = QuadraticIntercept(MissilePosition, Vector3.Dot(MissileVelocity, MissileVelocity), Target.AimPoint, Target.Velocity, 9999)
      -- If 2D only (torpedo), constrain to current missile altitude
      if self.IsTorpedo then
         AimPoint.y = MissilePosition.y
      end

      if Missile.TimeSinceLaunch >= self.OneTurnTime then
         -- Extend aim point to "infinity"
         local Offset = AimPoint - MissilePosition
         AimPoint = MissilePosition + Offset.normalized * 9999
         -- No longer active starting next update
         MissileState.Active = false
      end
      return AimPoint
   else
      -- No more guidance
      return nil
   end
end
