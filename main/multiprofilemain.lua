--! multiprofile
--@ periodic multiprofile
MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

Now = 0

function Update(I)
   if not I:IsDocked() then
      Now = I:GetTimeSinceSpawn()
      MissileMain:Tick(I)
   end
end
