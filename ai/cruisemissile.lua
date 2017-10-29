--@ commonstargets commons control planarvector quadraticintercept getbearingtopoint evasion
--@ dodgeyaw avoidance waypointmove
-- Cruise Missile AI
DodgeAltitudeOffset = nil
CruiseIsClosing = false
CruiseArmed = false
CruiseSpeedSamples = {}
CruiseSpeedIndex = 0
CruiseSpeedMax = -math.huge

-- Pre-square
CruiseMissileConfig.ArmingRange = CruiseMissileConfig.ArmingRange^2
if CruiseMissileConfig.DetonationRange then
   CruiseMissileConfig.DetonationRange = CruiseMissileConfig.DetonationRange^2
end
-- And pre-negate (because deceleration)
if CruiseMissileConfig.DetonationDecel then
   CruiseMissileConfig.DetonationDecel = -CruiseMissileConfig.DetonationDecel
end

CruiseSpeedLength = 40 / CruiseMissileConfig.UpdateRate

function CruiseArmingReset()
   CruiseSpeedSamples = {}
   CruiseSpeedIndex = 0
   CruiseSpeedMax = -math.huge
end

function CruiseGetTarget()
   local MinAltitude = CruiseMissileConfig.MinTargetAltitude
   for _,Target in ipairs(C:Targets()) do
      -- Always take the first one (highest priority)
      if Target.AimPoint.y > MinAltitude then
         return Target
      end
   end
   return nil
end

function CruiseGuidance(I, Target)
   local CMC = CruiseMissileConfig

   local TargetPosition = Target.AimPoint
   local SqrRange = (TargetPosition - C:CoM()).sqrMagnitude
   local Distance = PlanarVector(C:CoM(), TargetPosition).magnitude

   if not CruiseArmed and SqrRange < CMC.ArmingRange then
      CruiseArmed = true
      CruiseArmingReset()
   elseif CruiseArmed and SqrRange >= CMC.ArmingRange then
      CruiseArmed = false
   end

   -- Detonation check
   if CMC.DetonationKey and CMC.DetonationRange and CruiseArmed then
      if SqrRange < CMC.DetonationRange then
         I:RequestComplexControllerStimulus(CMC.DetonationKey)
      end
   end

   -- Guidance
   local Velocity = C:Velocity()
   CruiseIsClosing = false

   -- 3D guidance
   if Distance < CMC.TerminalDistance then
      -- Terminal phase
      if CMC.TerminalKey then
         I:RequestComplexControllerStimulus(CMC.TerminalKey)
      end

      if CMC.DetonationKey and CMC.DetonationDecel and CruiseArmed then
         local Speed = Vector3.Dot(Velocity, C:ForwardVector())
         -- Detonate if magnitude of deceleration is > config
         if (Speed - CruiseSpeedMax) < CMC.DetonationDecel then
            I:RequestComplexControllerStimulus(CMC.DetonationKey)
         end
         -- If buffer full and oldest sample was >= max, recalculate
         --# Also don't bother doing this if current speed >= max
         if #CruiseSpeedSamples >= CruiseSpeedLength and Speed < CruiseSpeedMax and CruiseSpeedSamples[1+CruiseSpeedIndex] >= CruiseSpeedMax then
            -- (Better way to do this?)
            CruiseSpeedMax = -math.huge
            for i = 0,#CruiseSpeedSamples-1 do
               -- Be sure to ignore outgoing sample
               if i ~= CruiseSpeedIndex then
                  CruiseSpeedMax = math.max(CruiseSpeedMax, CruiseSpeedSamples[1+i])
               end
            end
         else
            CruiseSpeedMax = math.max(CruiseSpeedMax, Speed)
         end
         -- Save speed sample
         CruiseSpeedSamples[1+CruiseSpeedIndex] = Speed
         CruiseSpeedIndex = (CruiseSpeedIndex + 1) % CruiseSpeedLength
      end

      -- Textbook proportional navigation
      local Offset = TargetPosition - C:CoM()
      local RelativeVelocity = Target.Velocity - Velocity
      local Omega = Vector3.Cross(Offset, RelativeVelocity) / Vector3.Dot(Offset, Offset)
      local Direction = Velocity.normalized
      local Acceleration = Vector3.Cross(Direction * CMC.Gain * -RelativeVelocity.magnitude, Omega)
      -- Add augmented term
      -- (just offset our gravity for now)
      Acceleration = Acceleration - I:GetGravityForAltitude(C:Altitude()) * CMC.Gain * 0.5

      --# Fixing the time step at 1 second was a lot better for
      --# vehicle pro-nav. Why?
      V.AdjustPosition(Velocity + Acceleration * 0.5)
      V.SetThrottle(CMC.TerminalThrottle)
      return
   end

   -- 2D guidance
   local AimPoint = QuadraticIntercept(C:CoM(), Vector3.Dot(Velocity, Velocity), TargetPosition, Target.Velocity)
   local TargetBearing = GetBearingToPoint(AimPoint)
   -- Start with target's ground
   local TargetAltitude = Target:Ground(I)
   local Throttle
   if CMC.MiddleDistance and Distance < CMC.MiddleDistance then
      -- Middle phase
      TargetAltitude = math.max(TargetAltitude + CMC.MiddleAltitude, AimPoint.y)
      Throttle = CMC.MiddleThrottle

      if CMC.MiddleKey then
         I:RequestComplexControllerStimulus(CMC.MiddleKey)
      end
   else
      -- Cruise phase
      TargetAltitude = math.max(TargetAltitude + CMC.CruiseAltitude, AimPoint.y)
      Throttle = CMC.CruiseThrottle

      -- Dodging
      local DodgeAngle,DodgeY,Dodging = Dodge()
      if Dodging then
         TargetBearing = DodgeAngle
         DodgeAltitudeOffset = DodgeY * VehicleRadius
      else
         -- Evasion
         TargetBearing = TargetBearing + CalculateEvasion(CMC.CruiseEvasion)
         TargetBearing = NormalizeBearing(TargetBearing)
         DodgeAltitudeOffset = nil
      end

      if CMC.CruiseKey then
         I:RequestComplexControllerStimulus(CMC.CruiseKey)
      end

      CruiseIsClosing = true
   end

   V.AdjustHeading(Avoidance(I, TargetBearing))
   V.SetThrottle(Throttle)
   --# A hack, but eh.
   DesiredAltitudeCombat = TargetAltitude
end

function CruiseAI_Reset()
   DodgeAltitudeOffset = nil
   CruiseIsClosing = false
   CruiseArmed = false
   CruiseArmingReset()
end

function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(Waypoint, function (Bearing) V.AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      Control_MoveToWaypoint(I, Flagship.ReferencePosition + Flagship.Rotation * I.IdealFleetPosition, Flagship.Velocity)
   else
      Control_MoveToWaypoint(I, I.Waypoint) -- Waypoint assumed to be stationary
   end
end

function CruiseAI_Update(I)
   V.Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      local Target = CruiseGetTarget()
      if Target then
         CruiseGuidance(I, Target)
      elseif ReturnToOrigin then
         CruiseAI_Reset()
         FormationMove(I)
      else
         CruiseAI_Reset()
         -- Just continue along with avoidance active
         V.AdjustHeading(Avoidance(I, 0))
      end
   else
      CruiseAI_Reset()
      FormationMove(I)
   end
end
