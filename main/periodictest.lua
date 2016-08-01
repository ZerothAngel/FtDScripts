--! periodictest
--@ getselfinfo periodic
Tick = 0

function PeriodicTest_Update(I)
   I:Log(string.format("%f: %d", Now, Tick))
   Tick = Tick + 1
end

PeriodicTest = Periodic.create(UpdateRate, PeriodicTest_Update)

function Update(I)
   if ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      PeriodicTest:Tick(I)
   end
end
