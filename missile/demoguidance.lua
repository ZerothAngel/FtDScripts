-- Demo guidance module

-- The MissileDriver module does all the magic: target locking, target
-- re-acquisition, self-destruction.
-- The only thing a guidance module has to worry about is what to aim
-- a missile at.

-- Every update (or 4th update or whatever) that enemies and your
-- missiles are active will result in the following sequence:

--   Call BeginUpdate
--   for every target your missile can hit
--     Call SetTarget for that target
--     for every missile locked onto this target
--       Call Guide for that missile

-- And this just repeats indefinitely...

-- There are many ways to define classes in Lua.
-- This is one way. IDGAF whether the Lua gods approve or not.
-- The language has the syntactic sugar for this, so let's take
-- advantage of it.

-- Also see http://lua-users.org/wiki/SimpleLuaClasses but note
-- we don't have access to setmetatable.

-- The table for your class
DemoGuidance = {}

-- The constructor for the class
-- We'll go ahead and accept a single argument used for configuration.
function DemoGuidance.create(Config)
   -- Create an "instance" of your class
   local self = {}

   -- Add whatever instance variables you want here
   self.Foo = 42
   -- Do something with Config. Save it, whatever.
   self.Bar = Config.Bar

   -- This next part is necessary because we can't use setmetatable
   self.BeginUpdate = DemoGuidance.BeginUpdate
   self.SetTarget = DemoGuidance.SetTarget
   self.Guide = DemoGuidance.Guide

   return self
end

-- The BeginUpdate method
-- This is called by MissileDriver once per Update.
-- The purpose is to do any "global" guidance-specific things
-- that would potentially apply to all targets.

-- This method is optional.

-- Note the way the function is defined: with a colon (':')
function DemoGuidance:BeginUpdate(I, Targets)
   -- Targets is a list of Target structures (see SetTarget below)
   -- of all active targets. The list will be filtered (so only
   -- targets that this guidance module can hit are available)
   -- and it will be in priority order.
end

-- The SetTarget method
-- This is called by MissileDriver once per target per Update.
-- Its purpose is to set any target-specific instance variables
-- that later calls to Guide can use (so they don't have to
-- constantly recompute). Good examples are altitude, acceleration,
-- or target-specific flags.

-- This method is optional.

function DemoGuidance:SetTarget(I, Target)
   -- Target has many useful members. Most relevant would be
   --   Position
   --   AimPoint
   --   Velocity
   -- See ConvertTarget in lib/commonstargets.lua
   self.TargetAltitude = Target.AimPoint.y

   -- Note you don't have to save Target because it will be passed to
   -- your Guide method below.
end

-- The Guide method
-- This is called by MissileDriver for each missile locked on to the
-- target (given above, by SetTarget).

-- It must do one thing: return an aim point, which is a Vector3.
-- The missile will aim at this aim point... and that's really all there
-- is to it. You can do more advanced stuff, like set variable thrusters
-- or change other missile settings, but that's beyond this simple demo.

-- It is also valid to return nil. In this case,
-- I:SetLuaControlledMissileAimPoint will NOT be called. This may be
-- useful for unguided missiles (e.g. rockets, bombs, mines).

function DemoGuidance:Guide(I, TransceiverIndex, MissileIndex, Target, Missile, MissileState)
   -- Most of the parameters probably don't need explanation, except:
   --   Missile: This is the MissileWarningInfo returned by
   --     I:GetLuaControlledMissileInfo. It's already been fetched for you.
   --   MissileState: This is a Lua table that is saved in between calls
   --     that is specific to this particular missile. You can save whatever
   --     values you want to it and the same table will be passed back to
   --     Guide the next time it is called for this missile.
   --     Newly-launched missiles will start out with their own empty
   --     MissileState table.

   -- At this point, you do whatever math you want to calculate the aim
   -- point.
   -- Or you can do nothing and just return Target.AimPoint, which is an
   -- example of pure pursuit guidance (which isn't all that good for
   -- moving targets).

   -- This example will use target predictive guidance as implemented by FtD
   -- itself.

   local TargetAimPoint = Target.AimPoint

   -- Check if we have a previous prediction. If not, use current target
   -- position.
   if not MissileState.Prediction then
      MissileState.Prediction = TargetAimPoint
   end

   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local MissileSpeed = MissileVelocity.magnitude

   -- Get relative positions & distances
   local RelativePosition = TargetAimPoint - MissilePosition
   local TargetDistance = RelativePosition.magnitude
   local PredRelativePosition = MissileState.Prediction - MissilePosition
   local PredDistance = PredRelativePosition.magnitude
   -- Determine closing speed by projection
   local ClosingSpeed = Vector3.Dot(MissileVelocity, PredRelativePosition / PredDistance)
   -- Clamp to lower bound 1/3rd of current speed
   ClosingSpeed = math.max(ClosingSpeed, MissileSpeed / 3)
   -- Determine time to target using shortest distance
   local TimeToTarget = math.min(TargetDistance, PredDistance) / ClosingSpeed
   -- Clamp to 20 seconds max
   TimeToTarget = math.min(TimeToTarget, 20)
   -- Aim at point where the target will be after TimeToTarget seconds
   local Prediction = TargetAimPoint + Target.Velocity * TimeToTarget
   -- Save prediction for next update
   MissileState.Prediction = Prediction
   -- Return missile aim point
   return Prediction
end
