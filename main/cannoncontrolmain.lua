--! cannoncontrol
--@ commons periodic cannoncontrol targetaccel
Cannon = Periodic.new(UpdateRate, CannonControl_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() and ActivateWhen[I.AIMode] then
      if AccelerationSamples then CalculateTargetAcceleration(AccelerationSamples) end
      Cannon:Tick(I)
   end
end
