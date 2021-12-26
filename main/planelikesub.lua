--! planelikesub
--@ commons control firstrun periodic
--@ shieldmanager multiprofile sixdof planelike planelikedefaults depthcontrol naval-ai
-- Plane-like sub main
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 2)
DepthControl = Periodic.new(DepthControl_UpdateRate, Depth_Control, 1)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(SixDoF, PlaneLikeControl)
SelectPitchImpl(SixDoF, PlaneLikeControl)
SelectRollImpl(SixDoF, PlaneLikeControl)

SelectHeadingImpl(PlaneLike)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      DepthControl:Tick(I)

      if ActivateWhen[C:MovementMode()] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         Depth_Apply(I, DodgeAltitudeOffset)
         PlaneLike.Update(I)
      else
         NavalAI_Reset()
         V.Reset()
         SixDoF.Release(I)

         Depth_Apply(I)
      end

      SixDoF.Update(I)

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
end
