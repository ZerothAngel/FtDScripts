# airplane Configuration #

## Overview ##

Since my airplane combo script is basically just my naval-ai with special controls, setting it up requires slightly more effort (since naval-ai was meant for water craft and airships, i.e. things that can actually come to a halt).

 1. Decide on attack behavior (naval-ai configuration)
 2. Modify waypoint behavior (so it never comes to a dead stop)
 3. Choose your altitude(s) and vertical behaviors
 4. Configure the airplane PIDs and other parameters
 5. Configure balloon manager (optional)

## Attack Behavior ##

Decide: Do you want broadsiding behavior or attack runs, like the stock aerial AI?

Either way, set `MinDistance` and `MaxDistance`. Also, for both behaviors, you might want to set `AirRaidEvasion` to `nil`.

If broadsiding, try out the defaults and then adjust the angles/evasion settings.

For attack runs:

 1. Set `AttackRuns` to `true`
 2. Set `AttackAngle` to 0 or some small angle. This is the relative bearing of the target when the plane makes an attack run. 0 is dead ahead, good for strafing runs but prone to collisions if you match altitude (more on that later).
 3. Similarly, reduce `ClosingAngle` since you probably want it to attack ASAP, even while distant.
 4. Adjust `ForceAttackTime` and `MinAttackTime` to taste. Read the comments. Be aware that `MinAttackTime` allows the AI to override the `MinDistance` setting, which might lead to collisions. So keep it short or keep your `AttackAngle` wide.

## Waypoint Behavior ##

This governs how the plane behaves when heading toward the 'M' map waypoint or when following the fleet flagship when in "fleetmove" mode.

Inside `WaypointMoveConfig`:

 1. Set both `MaxWanderDistance` and `MaxFormationDistance` to larger distances, something like 500-1000 depending on the speed of your plane. This ensures it drops down to minimum speed sooner.
 2. Set `MinimumSpeed` to some number. This is in meters per second. It's the speed of the plane while it loiters out-of-combat or in fleet formation.
 3. Set `StopOnStationaryWaypoint` to `false`.

## Altitudes ##

Basic setup for the "ALTITUDE CONTROL" section:

 1. Set `DesiredAltitudeCombat`. This is the default combat altitude.
 2. Set `DesiredAltitudeIdle`. This is the out-of-combat loitering altitude.
 3. I generally set `AbsoluteAltitude` to true so it doesn't follow terrain. (The naval AI will still attempt to avoid terrain.) This is up to you.
 4. If you want it to match the target's altitude, set `MatchTargetAboveAltitude` and `MatchTargetOffset`. If you use this feature, you'll generally want to set `MatchTargetAboveAltitude` to something like 100 or 200. You don't want it attempting to match the altitude of submarine targets. :P
 5. **Very important**. Set `HardMinAltitude` to the absolute minimum altitude.

## Airplane Configuration ##

Under the "AIRPLANE CONFIGURATION" section:

 1. Tune the PIDs. The defaults are OK, they work fine on the few test craft I used. Look elsewhere for tips on how to tune a PID.
 2. Modify `MaxPitch` if you want. But generally, if your `AltitudePID` is tuned well, you won't have to limit `MaxPitch` much.
 3. Decide if you want to bank to turn and if so, how many degrees difference before banking. Typically, your plane will need very strong yaw authority to counteract the climb caused by the roll + pitch up maneuver.

## Balloon Manager ##

If your plane has balloons and requires them to deploy when starting in water, then:

 1. Near the top, set `BalloonManager_UpdateRate` to something like 20 (= .5 seconds at normal 1X time).
 2. Look for `BalloonManagerConfig` and change the settings within to the desired deploy/sever altitudes.
