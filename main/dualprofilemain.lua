--! dualprofile
--@ periodic dualprofile
MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

Now = 0

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      Now = I:GetTimeSinceSpawn()
      MissileMain:Tick(I)
   end
end
