--! periodictest
--@ commons periodic
Tick = 0

function PeriodicTest_Update(I)
   I:Log(string.format("%f: %d", C:Now(), Tick))
   Tick = Tick + 1
end

PeriodicTest = Periodic.create(UpdateRate, PeriodicTest_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if ActivateWhen[I.AIMode] then
      PeriodicTest:Tick(I)
   end
end
