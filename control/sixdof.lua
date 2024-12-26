--@ commons componenttypes propulsionapi normalizebearing sign pid clamp
--# Packages don't exist, and screw accessing everything through a table.
--# It's just a search/replace away to convert to 'proper' Lua anyway.
-- 6DoF module (Altitude, Yaw, Pitch, Roll, Forward/Reverse, Right/Left)
SixDoF_AltitudePID = PID.new(SixDoFPIDConfig.Altitude, -1, 1)
SixDoF_YawPID = PID.new(SixDoFPIDConfig.Yaw, -1, 1)
SixDoF_PitchPID = PID.new(SixDoFPIDConfig.Pitch, -1, 1)
SixDoF_RollPID = PID.new(SixDoFPIDConfig.Roll, -1, 1)
SixDoF_ForwardPID = PID.new(SixDoFPIDConfig.Forward, -1, 1)
SixDoF_RightPID = PID.new(SixDoFPIDConfig.Right, -1, 1)

SixDoF_DesiredAltitude = 0
SixDoF_DesiredHeading = nil
SixDoF_DesiredPosition = nil
SixDoF_DesiredThrottle = nil
SixDoF_CurrentThrottle = 0
SixDoF_DesiredPitch = 0
SixDoF_DesiredRoll = 0

-- Through configuration, these axes can be skipped entirely
SixDoF_ControlAltitude = ControlFractions.Altitude > 0
SixDoF_ControlPitch = ControlFractions.Pitch > 0
SixDoF_ControlRoll = ControlFractions.Roll > 0
-- The others (yaw/forward/right) depend on an AI

SixDoF_NeedsRelease = false

--# Public methods on the other hand...
SixDoF = {}

function SixDoF.SetAltitude(Alt)
   SixDoF_DesiredAltitude = Alt
end

function SixDoF.SetHeading(Heading)
   SixDoF_DesiredHeading = Heading % 360
end

function SixDoF.ResetHeading()
   SixDoF_DesiredHeading = nil
end

function SixDoF.SetPosition(Pos)
   -- Make copy to be safe
   SixDoF_DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function SixDoF.ResetPosition()
   SixDoF_DesiredPosition = nil
end

function SixDoF.SetThrottle(Throttle)
   SixDoF_DesiredThrottle = Clamp(Throttle, -1, 1)
end

function SixDoF.GetThrottle()
   return SixDoF_CurrentThrottle
end

function SixDoF.ResetThrottle()
   SixDoF_DesiredThrottle = nil
end

function SixDoF.SetPitch(Angle)
   SixDoF_DesiredPitch = Angle
end

function SixDoF.SetRoll(Angle)
   SixDoF_DesiredRoll = Angle
end

function SixDoF.Update(I)
   local AltitudeCV = 0
   if SixDoF_ControlAltitude then
      local AltitudeDelta = SixDoF_DesiredAltitude - C:Altitude()
      -- Scale by vehicle up vector's Y component
      AltitudeDelta = AltitudeDelta * C:UpVector().y
      AltitudeCV = SixDoF_AltitudePID:Control(AltitudeDelta)
   end
   local YawCV = SixDoF_DesiredHeading and SixDoF_YawPID:Control(NormalizeBearing(SixDoF_DesiredHeading - C:Yaw())) or 0
   local PitchCV = SixDoF_ControlPitch and SixDoF_PitchPID:Control(SixDoF_DesiredPitch - C:Pitch()) or 0
   local RollCV = SixDoF_ControlRoll and SixDoF_RollPID:Control(SixDoF_DesiredRoll - C:Roll()) or 0

   local ForwardCV,RightCV = 0,0
   if SixDoF_DesiredPosition then
      local Offset = SixDoF_DesiredPosition - C:CoM()
      local ZProj = Vector3.Dot(Offset, C:ForwardVector())
      local XProj = Vector3.Dot(Offset, C:RightVector())
      ForwardCV = SixDoF_ForwardPID:Control(ZProj)
      RightCV = SixDoF_RightPID:Control(XProj)
   elseif SixDoF_DesiredThrottle then
      ForwardCV = SixDoF_DesiredThrottle
      SixDoF_CurrentThrottle = SixDoF_DesiredThrottle
   end

   local PlanarMovement = SixDoF_DesiredHeading or SixDoF_DesiredPosition or SixDoF_DesiredThrottle

   if I.SetInputs then
      --# Only set YLL if doing planar movement. Allows for manual control.
      local yllValues
      if PlanarMovement then
         yllValues = {
            YawCV * ControlFractions.Yaw,
            ForwardCV * ControlFractions.Forward,
            RightCV * ControlFractions.Right
         }
      else
         yllValues = {}
      end
      I:SetInputs(yllValues,
                  --# These are unconditionally set
                  { AltitudeCV * ControlFractions.Altitude,
                     PitchCV * ControlFractions.Pitch,
                     RollCV * ControlFractions.Roll })
   else
      -- Vanilla (untested)
      if PlanarMovement then
         I:SetPropulsionRequest(DRIVETYPE_YAW, YawCV * ControlFractions.Yaw)
         I:SetPropulsionRequest(DRIVETYPE_FORWARDS, ForwardCV * ControlFractions.Forward)
         I:SetPropulsionRequest(DRIVETYPE_RIGHT, RightCV * ControlFractions.Right)
      end
      I:SetPropulsionRequest(DRIVETYPE_UP, AltitudeCV * ControlFractions.Altitude)
      I:SetPropulsionRequest(DRIVETYPE_PITCH, PitchCV * ControlFractions.Pitch)
      I:SetPropulsionRequest(DRIVETYPE_ROLL, RollCV * ControlFractions.Roll)
   end

   if PlanarMovement then
      SixDoF_NeedsRelease = true
   end
end

function SixDoF.Disable(I)
   SixDoF_CurrentThrottle = 0
   -- Only MAINPROPULSION is stateful
   I:SetPropulsionRequest(DRIVETYPE_FORWARDS, 0)
   -- And altitide too, apparently
   if I.SetInput then
      I:SetInputs({}, { 0 })
   else
      I:SetPropulsionRequest(DRIVETYPE_UP, 0)
   end
end

function SixDoF.Release(I)
   if SixDoF_NeedsRelease then
      -- Be sure to only disable non-vertical spinners
      SixDoF.Disable(I)
      SixDoF_NeedsRelease = false
   end
end
