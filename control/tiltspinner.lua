--@ commons sign pid normalizebearing
TiltSpinner = {}

--# TODO Selection of spinners by local offset from origin?
function TiltSpinner.create(Axis, PIDConfig)
   local self = {}

   self.Axis = Axis
   self.PIDConfig = PIDConfig

   --# Probably a mathematical way of doing this, but eh
   if Axis.x ~= 0 then
      self.Forward = Vector3.forward
   elseif Axis.y ~= 0 then
      self.Forward = Vector3.forward
   else
      self.Forward = Vector3(0, -Sign(Axis.z), 0)
   end
   self.Right = Vector3.Cross(-self.Forward, Axis)

   self.LastSpinnerCount = 0
   self.SpinnerInfos = {}

   self.TargetAngles = { 0, 0, 0, 0, 0, 0, 0, 0 }

   self.Classify = TiltSpinner.Classify
   self.SetAngles = TiltSpinner.SetAngles
   self.Update = TiltSpinner.Update
   self.Disable = TiltSpinner.Disable

   return self
end

function TiltSpinner_GetOctantIndex(Position)
   local Index = Position.x > 0 and 1 or 0
   Index = Index + Position.y > 0 and 2 or 0
   Index = Index + Position.z > 0 and 4 or 0
   return 1+Index
end

TiltSpinner_Eps = .001

function TiltSpinner:Classify(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= self.LastSpinnerCount then
      self.LastSpinnerCount = SpinnerCount
      self.SpinnerInfos = {}

      local Axis = self.Axis

      for i = 0,SpinnerCount-1 do
         -- Only process spinners (not dediblades)
         if not I:IsSpinnerDedicatedHelispinner(i) then
            local BlockInfo = I:GetSpinnerInfo(i)
            --# Can't use BlockLocal.LocalForwards because that's the spinner
            --# assembly
            -- Get world "up" vector
            local Up = BlockInfo.Rotation * Vector3.up
            -- And rotate to local space
            local LocalUp = C:ToLocal() * Up
            -- Along our axis?
            local DotAxis = Vector3.Dot(LocalUp, Axis)
            local AxisSign = Sign(DotAxis, 0, TiltSpinner_Eps)
            if AxisSign ~= 0 then
               local Info = {
                  Index = i,
                  AxisSign = AxisSign,
                  PID = PID.create(self.PIDConfig, -1, 1),
                  AngleIndex = TiltSpinner_GetOctantIndex(C:ToLocal() * (BlockInfo.Position - C:CoM())),
               }
               table.insert(self.SpinnerInfos, Info)
            end
         end
      end
   end
end

function TiltSpinner:SetAngles(Angles)
   self.TargetAngles = Angles
end

function TiltSpinner:Update(I)
   self:Classify(I)

   local Forward,Right = self.Forward,self.Right
   local TargetAngles = self.TargetAngles

   for _,Info in pairs(self.SpinnerInfos) do
      --# Yes, there is a SetSpinnerRotationAngle. But insta-spinning
      --# is apparently faster?
      local Index = Info.Index
      local BlockInfo = I:GetSpinnerInfo(Index)
      local LocalForwards = BlockInfo.LocalForwards
      -- Get current angle
      local z = Vector3.Dot(LocalForwards, Forward)
      local x = Vector3.Dot(LocalForwards, Right) * Info.AxisSign
      local PV = math.deg(math.atan2(x, z))
      local TargetAngle = TargetAngles[Info.AngleIndex]
      local CV = Info.PID:Control(NormalizeBearing(Info.AxisSign * TargetAngle - PV))
      I:SetSpinnerInstaSpin(Index, CV)
   end
end

function TiltSpinner:Disable(I)
   self:Classify(I)
   for _,Info in pairs(self.SpinnerInfos) do
      I:SetSpinnerRotationAngle(Info.Index, 0)
   end
end
