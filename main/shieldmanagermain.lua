--! shieldmanager
--@ commons periodic shieldmanager
ShieldManager = Periodic.create(UpdateRate, ShieldManager_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   ShieldManager:Tick(I)
end
