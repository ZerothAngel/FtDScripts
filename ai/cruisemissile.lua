--@ commonstargets commons control planarvector quadraticintercept getbearingtopoint evasion
--@ dodgeyaw avoidance waypointmove
-- Cruise Missile AI
DodgeAltitudeOffset = nil
CruiseIsClosing = false
CruiseArmed = false
CruiseSpeedSamples = {}
CruiseSpeedIndex = 0

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
   local AimPoint = QuadraticIntercept(C:CoM(), Vector3.Dot(Velocity, Velocity), TargetPosition, Target.Velocity)

   CruiseIsClosing = false

   -- 3D guidance
   if Distance < CMC.TerminalDistance then
      -- Terminal phase
      -- (use AimPoint as-is)
      if CMC.TerminalKey then
         I:RequestComplexControllerStimulus(CMC.TerminalKey)
      end

      if CMC.DetonationKey and CMC.DetonationDecel then
         local Speed = Vector3.Dot(Velocity, C:ForwardVector())
         -- Detonate if magnitude of deceleration is > config
         if CruiseArmed and #CruiseSpeedSamples >= CruiseSpeedLength then
            local Accel = Speed - CruiseSpeedSamples[1+CruiseSpeedIndex]
            if Accel <  CMC.DetonationDecel then
               I:RequestComplexControllerStimulus(CMC.DetonationKey)
            end
         end
         -- Save speed sample
         CruiseSpeedSamples[1+CruiseSpeedIndex] = Speed
         CruiseSpeedIndex = (CruiseSpeedIndex + 1) % CruiseSpeedLength
      end

      V.SetPosition(AimPoint)
      V.SetThrottle(CMC.TerminalThrottle)
      return
   end

   -- 2D guidance
   local TargetBearing = GetBearingToPoint(AimPoint)
   -- Start with target's ground
   local TargetAltitude = math.max(I:GetTerrainAltitudeForPosition(TargetPosition), 0)
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
   CruiseSpeedSamples = {}
   CruiseSpeedIndex = 0
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
