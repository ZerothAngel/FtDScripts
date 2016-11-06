--@ debug
-- GetSelfInfo module
Now = 0
Position = nil -- luacheck: ignore 131
CoM = nil
Altitude = 0
Yaw = 0
Pitch = 0
Roll = 0

-- Grab & save info about the ship, adjust them so they match
-- the HUD's values.
function GetSelfInfo(I)
   local __func__ = "GetSelfInfo"

   Now = I:GetTimeSinceSpawn()
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
