--! steamregulator
--@ commons periodic namedcomponent pid clamp
SteamRegulator = {}

STEAMBOILER = 17
SteamRegulator_NamedComponent = NamedComponent.new(STEAMBOILER)
SteamRegulator_PID = PID.new(SteamRegulatorConfig.PIDConfig, -SteamRegulatorConfig.MaxBurnRate, SteamRegulatorConfig.MaxBurnRate)

function SteamRegulator.Update(I)
   local Energy = I:GetEnergyFraction()

   -- No such thing as negative burn rate, so clamp appropriately
   local CV = Clamp(SteamRegulator_PID:Control(SteamRegulatorConfig.TargetLevel - Energy), 0, SteamRegulatorConfig.MaxBurnRate)
   I:LogToHud(string.format("Energy = %f, CV = %f", Energy, CV))
   for _,index in ipairs(SteamRegulator_NamedComponent:GetIndices(I, SteamRegulatorConfig.Name)) do
      I:Component_SetFloatLogic(STEAMBOILER, index, CV)
   end
end

function SteamRegulator.Disable(I)
   -- Not sure if this is actually needed when docked
   for _,index in ipairs(SteamRegulator_NamedComponent:GetIndices(I, SteamRegulatorConfig.Name)) do
      I:Component_SetFloatLogic(STEAMBOILER, index, 0)
   end
end

MySteamRegulator = Periodic.new(UpdateRate, SteamRegulator.Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      MySteamRegulator:Tick(I)
   else
      SteamRegulator.Disable(I)
   end
end
