-- Commons module
Position = nil
CoM = nil
Altitude = 0
Yaw = 0
Pitch = 0
Roll = 0

-- Simple logging wrapper with formatting support
-- Callers should still check Debugging to avoid evaluating arguments
function Debug(I, Subsystem, Message, ...)
   if not Subsystem or Debugging == Subsystem then
      local Formatted = string.format(Message, ...)
      if DebugToHud then
         I:LogToHud(Formatted)
      else
         I:Log(Formatted)
      end
   end
end

-- Grab & save info about the ship, adjust them so they match
-- the HUD's values.
function GetSelfInfo(I)
   local __func__ = "GetSelfInfo"

   Position = I:GetConstructPosition()
   CoM = I:GetConstructCenterOfMass()
   Altitude = CoM.y

   Yaw = I:GetConstructYaw()

   Pitch = I:GetConstructPitch()

   if Pitch > 180 then
      Pitch = 360 - Pitch
   else
      Pitch = -Pitch
   end

   Roll = I:GetConstructRoll()
   if Roll > 180 then
      Roll = Roll - 360
   end

   if Debugging then Debug(I, __func__, "Yaw %f Pitch %f Roll %f Alt %f", Yaw, Pitch, Roll, Altitude) end
end

-- Returns offset vector with target at same height as origin
function PlanarVector(Origin, Target)
   local NewTarget = Vector3(Target.x, Origin.y, Target.z)
   return NewTarget - Origin, NewTarget
end

-- Get bearing toward a given world point
function GetBearingToPoint(I, Point)
   return -I:GetTargetPositionInfoForPosition(0, Point.x, 0, Point.z).Azimuth
end
