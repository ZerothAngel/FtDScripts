--! rocketnn
--@ commonstargets commonsweapons commons eventdriver firstrun weapontypes neuralnet secant shuffle debug
-- Neural net-based rocket turret predictor
Main = EventDriver.new()

NN = NeuralNet.new(1, 3, 1)
NN:Randomize()

TrainingSets = {}
TrainingSamplesCaptured = 0
TrainingEpoch = 0
TrainingSetIndex = 0
LastMaxRMS = 0
DummyPrediction = true

AddFirstRun(function (_)
               Main:Schedule(0, RocketControl_Capture)
               Main:Schedule(0, RocketControl_Update)
            end)

function RocketControl_Train(I)
   local Count = 0
   repeat
      local Set = TrainingSets[1+TrainingSetIndex]

      NN:Run({ Set[1] })
      local RMS = NN:Backprop({ Set[2] })
      LastMaxRMS = math.max(LastMaxRMS, RMS)

      Count = Count + 1

      TrainingSetIndex = (TrainingSetIndex + 1) % #TrainingSets
   until Count >= TrainingBatchSize or TrainingSetIndex == 0

   if TrainingSetIndex == 0 then
      TrainingEpoch = TrainingEpoch + 1
      if (TrainingEpoch % 10) == 0 then
         Log("Epoch #%d MaxRMS = %.03f", TrainingEpoch, LastMaxRMS)
      end

      if LastMaxRMS < DummyPredictionRMS then
         DummyPrediction = false
      end

      if LastMaxRMS > TrainingMaxRMS then
         if TrainingEpoch >= TrainingMaxEpochs then
            I:LogToHud("Training failed, trying again!")
            -- Try again with different weights
            NN:Randomize()
            TrainingEpoch = 0
            DummyPrediction = true
         end

         shuffle(TrainingSets)
         -- TrainingSetIndex already 0
         LastMaxRMS = 0
         Main:Schedule(1, RocketControl_Train)
      else
         I:LogToHud("Training complete!")
      end
   else
      Main:Schedule(1, RocketControl_Train)
   end
end

RocketControl_MissileStates = {}

function RocketControl_Capture(I)
   local NewMissileStates = {}
   for tindex = 0,I:GetLuaTransceiverCount()-1 do
      local LaunchPad = I:GetLuaTransceiverInfo(tindex)
      for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
         local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
         local MissileId = Missile.Id
         local State = RocketControl_MissileStates[MissileId]
         if not State then State = {} end
         -- Copy state to next update
         NewMissileStates[MissileId] = State

         local Now = Missile.TimeSinceLaunch

         local DataPoints = State.DataPoints
         if not DataPoints then
            DataPoints = {}
            State.DataPoints = DataPoints
            State.Submitted = false
            -- DQ if too old
            State.Disqualified = Now > 1
         end

         if Missile.Position.y < SampleMinAltitude then
            -- Disqualify it
            State.Disqualified = true
         end

         if not State.Disqualified then
            if Now <= TimeScale then
               -- Save data point
               local Distance = (Missile.Position - LaunchPad.Position).magnitude
               table.insert(DataPoints, { Now / TimeScale, Distance / DistanceScale })
            else
               -- Submit data for training if needed and it hasn't already been
               if not State.Submitted and TrainingSamplesCaptured < TrainingSamplesNeeded then
                  -- Copy over to TrainingSets
                  for _,v in ipairs(DataPoints) do
                     table.insert(TrainingSets, v)
                  end
                  State.Submitted = true

                  TrainingSamplesCaptured = TrainingSamplesCaptured + 1
                  I:LogToHud(string.format("Sample #%d captured!", TrainingSamplesCaptured))
               end
            end
         end
      end
   end
   RocketControl_MissileStates = NewMissileStates

   -- Keep capturing until we have enough samples, otherwise start training
   if TrainingSamplesCaptured >= TrainingSamplesNeeded then
      I:LogToHud(string.format("Starting training with %d sets!", #TrainingSets))
      shuffle(TrainingSets)
      Main:Schedule(1, RocketControl_Train)
   else
      Main:Schedule(Capture_UpdateRate, RocketControl_Capture)
   end
end

function MissileDistance(t)
   return NN:Run({ t / TimeScale })[1]*DistanceScale
end

-- Returns relative aim point for given weapon & target or nil
function RocketControl_Predict(Weapon, Target)
   local AimPoint = Target.AimPoint
   local ConstrainWaterline = RocketLimits.ConstrainWaterline
   if ConstrainWaterline then
      AimPoint = Vector3(AimPoint.x, math.max(ConstrainWaterline, AimPoint.y), AimPoint.z)
   end
   local RelativePosition = AimPoint - Weapon.Position

   if DummyPrediction then
      -- Just aim straight at target so we can fire and begin capturing data
      return RelativePosition
   end

   -- Solve MissileDistance(t)^2 = (TP + TV*t)^2 for t
   local TimeToTarget = Secant(function (t)
                                  local TargetPosition = RelativePosition + Target.Velocity*t
                                  return MissileDistance(t)^2 - Vector3.Dot(TargetPosition, TargetPosition)
                               end,
                               FirstGuess)
   if TimeToTarget then
      return RelativePosition + Target.Velocity*TimeToTarget
   else
      return nil
   end
end

function RocketControl_Update(I)
   -- Get highest-priority target within limits
   local Target = nil
   for _,T in ipairs(C:Targets()) do
      local Altitude = T.AimPoint.y
      if (T.Range >= RocketLimits.MinRange and T.Range <= RocketLimits.MaxRange and
          Altitude >= RocketLimits.MinAltitude and Altitude <= RocketLimits.MaxAltitude) then
         Target = T
         break
      end
   end
   if Target then
      -- Aim & fire all turrets/missile controllers of the appropriate slot
      for _,Weapon in pairs(C:HullWeaponControllers()) do
         if Weapon.Slot == RocketWeaponSlot and (Weapon.Type == TURRET or Weapon.Type == MISSILECONTROL) and not Weapon.PlayerControl then
            -- Calculate aim point
            local AimPoint = RocketControl_Predict(Weapon, Target)
            if AimPoint and I:AimWeaponInDirection(Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, RocketWeaponSlot) > 0 then
               I:FireWeapon(Weapon.Index, RocketWeaponSlot)
            end
         end
      end
   end

   Main:Schedule(1, RocketControl_Update)
end

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() and ActivateWhen[I.AIMode] then
      Main:Tick(I)
   end
end
