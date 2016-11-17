--! shieldmanager
--@ periodic shieldmanager
ShieldManager = Periodic.create(UpdateRate, ShieldManager_Control)

Now = 0
CoM = nil

function Update(I) -- luacheck: ignore 131
   Now = I:GetTimeSinceSpawn()
   CoM = I:GetConstructCenterOfMass()

   ShieldManager:Tick(I)
end
