-- Common functions

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
