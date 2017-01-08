--! cannoncontrol
--@ commons periodic cannoncontrol
Cannon = Periodic.create(UpdateRate, CannonControl_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() and ActivateWhen[I.AIMode] then
      Cannon:Tick(I)
   end
end
