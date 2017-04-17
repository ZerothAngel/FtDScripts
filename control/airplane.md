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

Either way, set `MinDistance` and `MaxDistance`. Also, for both, you might want to set `AirRaidEvasion` to `nil`.

If broadsiding, try out the defaults and then adjust the angles/evasion settings.

For attack runs:

 1. Set `AttackRuns` to `true`
 2. Set `AttackAngle` to 0 or some small angle. This is the relative bearing of the target when the plane makes an attack run. 0 is dead ahead, good for strafing runs but prone to collisions if you match altitude (more on that later).
 3. Similarly, reduce `ClosingAngle` since you probably want it to attack ASAP, even while distant.
 4. Adjust `ForceAttackTime` and `MinAttackTime` to taste. Read the comments.

## Waypoint Behavior ##

Inside `WaypointMoveConfig`:

 1. Set both `MaxDistance` and `ApproachDistance` to larger distances, something like 500-1000 depending on the speed of your plane. This ensures it drops down to minimum speed sooner.
 2. Set `MinimumSpeed` to some number. This is in meters per second. It's how fast the plane will loiter.
 3. Set `StopOnStationaryWaypoint` to `false`.

## Altitudes ##

Basic setup for the "ALTITUDE CONTROL" section:

 1. Set `DesiredAltitudeCombat`. This is the default combat altitude.
 2. Set `DesiredAltitudeIdle`. This is the out-of-combat loitering altitude.
 3. If you want it to match the target's altitude, set `MatchTargetAboveAltitude` and `MatchTargetOffset`. If you use this feature, you'll generally want to set `MatchTargetAboveAltitude` to something like 100 or 200. You don't want it attempting to match surface targets. :P
 4. **Very important**. Set `HardMinAltitude` to the absolute minimum altitude.

## Airplane Configuration ##

Under the "AIRPLANE CONFIGURATION" section:

 1. Tune the PIDs. The defaults are OK, they work fine on the few test craft I used. Look elsewhere for tips on how to tune a PID.
 2. Look over the pitch settings (`MaxPitchAngle`) and modify them if you want. The default allows a maximum pitch down of 10 degrees and a maximum pitch up of 45 degrees at all altitudes. You can customize this for higher altitudes (e.g. allow more freedom the higher you are) by duplicating the line and modifying the three values.
 3. Decide if you want to bank to turn and if so, how many degrees difference before banking. By default, it will bank up to 50 degrees for heading changes more than 10 degrees as long as it is at least 200 meters high. See `AngleBeforeRoll`, `MaxRollAngle` and other settings.

## Balloon Manager ##

If your plane has balloons and requires them to deploy when starting in water, then:

 1. Near the top, set `BalloonManager_UpdateRate` to something like 20 (= .5 seconds at normal 1X time).
 2. Look for `BalloonManagerConfig` and change the settings within to the desired deploy/sever altitudes.
