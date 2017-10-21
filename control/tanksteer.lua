--@ commons pid thrusthack normalizebearing
-- Tank steering module via drive maintainers
TankSteer_YawPID = PID.create(TankSteerConfig.YawPIDConfig, -1, 1)

TankSteer_DesiredHeading = nil
TankSteer_DesiredThrottle = nil
TankSteer_CurrentThrottle = 0

TankSteer_LeftTrackControl = ThrustHack.create(TankSteerConfig.LeftTrackDriveMaintainerFacing)
TankSteer_RightTrackControl = ThrustHack.create(TankSteerConfig.RightTrackDriveMaintainerFacing)

TankSteer_NeedsRelease = false

TankSteer = {}

function TankSteer.SetHeading(Heading)
   TankSteer_DesiredHeading = Heading % 360
end

function TankSteer.ResetHeading()
   TankSteer_DesiredHeading = nil
end

function TankSteer.SetThrottle(Throttle)
   TankSteer_DesiredThrottle = math.max(-1, math.min(1, Throttle))
end

function TankSteer.GetThrottle()
   return TankSteer_CurrentThrottle
end

function TankSteer.ResetThrottle()
   TankSteer_DesiredThrottle = nil
end

function TankSteer.Update(I)
   local YawCV = TankSteer_DesiredHeading and TankSteer_YawPID:Control(NormalizeBearing(TankSteer_DesiredHeading - C:Yaw())) or 0
   local ForwardCV = 0
   if TankSteer_DesiredThrottle then
      ForwardCV = TankSteer_DesiredThrottle -- YawPID is scaled up
      TankSteer_CurrentThrottle = TankSteer_DesiredThrottle
   end

   local LeftTrack = math.max(-1, math.min(1, ForwardCV + YawCV))
   local RightTrack = math.max(-1, math.min(1, ForwardCV - YawCV))

   TankSteer_LeftTrackControl:SetThrottle(I, LeftTrack)
   TankSteer_RightTrackControl:SetThrottle(I, RightTrack)

   if TankSteer_DesiredHeading or TankSteer_DesiredThrottle then
      TankSteer_NeedsRelease = true
   end
end

function TankSteer.Disable(I)
   TankSteer_CurrentThrottle = 0
   TankSteer_LeftTrackControl:SetThrottle(I, 0)
   TankSteer_RightTrackControl:SetThrottle(I, 0)
end

function TankSteer.Release(I)
   if TankSteer_NeedsRelease then
      TankSteer.Disable(I)
      TankSteer_NeedsRelease = false
   end
end
