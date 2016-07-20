--! dualprofile
--@ periodic dualprofile
MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I)
   MissileMain:Tick(I)
end
