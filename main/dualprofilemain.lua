--! dualprofile
--@ periodic dualprofile
MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I)
   if not I:IsDocked() then
      MissileMain:Tick(I)
   end
end
