--! periodictest
--@ commons periodic
Tick = 0

function PeriodicTest_Update(I)
   I:Log(string.format("%f: %d", Now, Tick))
   Tick = Tick + 1
end

PeriodicTest = Periodic.create(UpdateRate, PeriodicTest_Update)

function Update(I) -- luacheck: ignore 131
   if ActivateWhen[I.AIMode] then
      C = Commons.create(I)

      PeriodicTest:Tick(I)
   end
end
