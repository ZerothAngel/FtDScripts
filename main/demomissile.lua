--! demomissile
--@ commons periodic missiledriver demoguidance
-- Demo missile main

-- Create an array of GuidanceInfo tables.
-- Each one is a distinct class of missile, with its own guidance code
-- and parameters.
-- This is largely dependent on how you choose to differentiate between
-- Lua transceivers.
GuidanceInfos = {
   {
      Controller = DemoGuidance.create(Config),
      MinAltitude = Limits.MinAltitude,
      MaxAltitude = Limits.MaxAltitude,
      MinRange = Limits.MinRange * Limits.MinRange,
      MaxRange = Limits.MaxRange * Limits.MaxRange,
      WeaponSlot = MissileWeaponSlot,
      TargetSelector = MissileTargetSelector,
   }
}

-- This function is called by the MissileDriver module.
-- It must return an index into the above GuidanceInfos table, i.e.
-- 1 to however many entries.
-- It may return a number less than 1 to ignore all missiles from this
-- transceiver.
function SelectGuidance(I, TransceiverIndex)
   -- Differentiate your Lua transceivers however you want. Some examples:
   --   by position, e.g. left/right/forward/behind CoM
   --   by orientation, e.g. horizontal/vertical, or pointing downward
   --   by closest missile controller
   --   etc.

   -- For any of the above examples, you will typically call
   -- I:GetLuaTransceiverInfo(TransceiverIndex) to get the transceiver's
   -- BlockInfo table. From there, you can do the necessary math to
   -- figure things out.

   -- In this demo, there's only one GuidanceInfo, so return 1 so that
   -- GuidanceInfos[1] is used.
   return 1
end

-- Main update loop
function MissileMain_Update(I)
   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end

MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() then
      MissileMain:Tick(I)
   end
end
