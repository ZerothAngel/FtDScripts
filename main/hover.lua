--! hover
--@ commons pid
AltitudePID = PID.create(AltitudePIDValues[1], AltitudePIDValues[2], AltitudePIDValues[3], CanReverseBlades and -30 or 0, 30)

Spinners = {}

TargetInfo = nil

function ClassifySpinners(I)
   local __func__ = "ClassifySpinners"

   Spinners = {}
   for i = 0,I:GetSpinnerCount()-1 do
      if I:IsSpinnerDedicatedHelispinner(i) then
         local Info = I:GetSpinnerInfo(i)
         local UpFraction = Vector3.Dot(Info.LocalRotation * Vector3.up,
                                        Vector3.up)
         if math.abs(UpFraction) > 0.001 then -- Sometimes there's -0
            if Debugging then Debug(I, __func__, "Index %d UpFraction %f", i, UpFraction) end
            local Spinner = {
               Index = i,
               UpFraction = UpFraction
            }
            Spinners[#Spinners+1] = Spinner
         end
      end
   end
end

-- Finds first valid target on first mainframe
function GetTarget(I)
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         TargetInfo = I:GetTargetPositionInfo(mindex, tindex)
         if TargetInfo.Valid then return true end
      end
   end
   TargetInfo = nil
   return false
end

function Update(I)
   local __func__ = "Update"

   ClassifySpinners(I)

   if I.AIMode ~= "off" then
      GetSelfInfo(I)

      local DesiredAltitude
      if GetTarget(I) then
         DesiredAltitude = DesiredAltitudeCombat
      else
         DesiredAltitude = DesiredAltitudeIdle
      end

      if not AbsoluteAltitude then
         -- Add terrain height under CoM
         local Height = I:GetTerrainAltitudeForPosition(CoM)
         -- Check additional look-ahead positions
         local Velocity = I:GetVelocityVector()
         for i,t in pairs(AltitudeLookAhead) do
            Height = math.max(Height, I:GetTerrainAltitudeForPosition(CoM + Velocity * t))
         end
         -- Finally, don't fly lower than sea level
         Height = math.max(Height, 0)
         DesiredAltitude = DesiredAltitude + Height
      end

      local CV = AltitudePID:Control(DesiredAltitude - Altitude)

      if Debugging then Debug(I, __func__, "Altitude %f CV %f", Altitude, CV) end

      for i,Spinner in pairs(Spinners) do
         I:SetSpinnerContinuousSpeed(Spinner.Index, CV / Spinner.UpFraction)
      end
   else
      for i,Spinner in pairs(Spinners) do
         I:SetSpinnerContinuousSpeed(Spinner.Index, 0)
      end
   end
end
