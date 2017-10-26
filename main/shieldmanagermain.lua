--! shieldmanager
--@ commons periodic shieldmanager
ShieldManager = Periodic.new(UpdateRate, ShieldManager_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   ShieldManager:Tick(I)
end
