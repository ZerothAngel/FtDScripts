# ZerothAngel's Naval AI Configuration #

## Modes of Operation ##

My naval AI supports 3 modes of operation:

  1. Simple broadsiding
  2. Broadsiding while maintaining a specific distance
  3. Attack runs

### Common Configuration ###

Firstly, distances are always measured as ground distance to the primary target. That is, the distance without taking the altitude of either vehicle or target into account.

Secondly, angles are always relative to the bearing of the primary target. So an angle of 0 will point your vehicle directly at the primary target. An angle of 180 will be directly away from it. And an angle of 90 will keep the primary target either directly to the left or right side (which side depends on the `PreferredBroadside` option, but by default it will pick the closest side, i.e. whichever side requires the smallest heading change).

All 3 modes require `MinDistance` and `MaxDistance` to be set and typically, the range inbetween defines the primary combat zone.

There are 3 different sets of settings:

  * Attack
  * Closing
  * Escape

All 3 sets are used by all 3 modes, but *when* they are used is largely dependent on the mode.

### Simple Broadsiding ###

Used when `AttackRuns = false` and `AttackDistance = nil`

This mode is very simple and is solely based on the ground distance to the primary target. It goes something like this:

  * If target distance < `MinDistance` then use **Escape** settings.
  * If target distance > `MaxDistance` then use **Closing** settings.
  * Otherwise (which means `MinDistance` < target distance < `MaxDistance`), use **Attack** settings.

In order to properly close with the target, `ClosingAngle` should be < 90 degrees.

In order to properly escape from the target, `EscapeAngle` should be > 90 degrees.

And that's pretty much it.

### Broadsiding ###

Used when `AttackRuns = false` and `AttackDistance` is non-nil.

`AttackDistance` should be set to a number between `MinDistance` and `MaxDistance`. It represents the ideal distance for attacking and as such, it means the vehicle will attempt to stay at this distance from the target at all times.

It largely behaves the same as simple broadsiding:

  * If target distance < `MinDistance` then use **Escape** settings.
  * If target distance > `MaxDistance` then use **Closing** settings.
  * Otherwise (which means `MinDistance` < target distance < `MaxDistance`), use **Attack** settings.

In order to properly close with the target, `ClosingAngle` should be < 90 degrees.

In order to properly escape from the target, `EscapeAngle` should be > 90 degrees.

#### With AttackReverse = false (default) ####

**However**, when attacking, the `AttackAngle` takes on a different meaning. It represents the maximum angle at which to close to `AttackDistance` (i.e. when `AttackDistance` < target distance < `MaxDistance`). Conversely, `180 - AttackAngle` then becomes the maximum angle at which to escape back out to `AttackDistance` (i.e. when `MinDistance` < target distance < `AttackDistance`).

So if `AttackAngle` is 75 degrees, it will close to `AttackDistance` at 75 degrees. If it is closer than `AttackDistance`, it will attempt to escape at 105 degrees (180 - 75).

In this mode, `AttackAngle` must never be explicitly set to 90 degrees.

But it's still a bit more complicated. The delta between target distance and `AttackDistance` (i.e. `AttackDistance - target distance`) is fed to a PID configured by `AttackPIDConfig`. The output of this PID is then used to compute the attacking angle. This smoothly scales the attack angle between `AttackAngle` and `180 - AttackAngle` and prevents the vehicle from rapidly switching between the two angles when straddling `AttackDistance`.

#### With AttackReverse = true ####

When `AttackReverse` is true, the method for maintaining `AttackDistance` changes: Rather than "flipping" `AttackAngle` (i.e. `180 - AttackAngle`), the script will instead negate `AttackDrive` resulting in reverse motion. This works best when `AttackAngle` is close to (or even equal to) 0 as it keeps the front facing the enemy. This is ideal for tanks, which are presumably armored primarily in the front. (This is the colloquially known "frontal broadside" mode.)

Needless to say, your vehicle should be able to move in reverse. Dediblades, propellers & wheels will work fine. Unfortunately, backwards-facing jets inexplicably do not activate when the main drive is reversed, so the default configuration (which acts by sending standard vehicle controls) does not work. Note that moving in reverse isn't a strict requirement, as this mode will still provide a stop-fire-move-stop-fire-move sort of behavior in that case.

Behind-the-scenes, the same PID that was used for `AttackAngle` is instead used to scale the throttle between `-AttackDrive` and `AttackDrive`. So in theory it should smoothly maintain `AttackDistance` as long as the vehicle response is "good enough" and the PID is tuned. (Wheels tend to slip a lot, so they will probably never be good enough.)

### Attack Runs ###

Used when `AttackRuns = true`

This mode emulates the "attack run" behavior of the stock aerial AI. Unlike the other modes which select a set of settings (attack, closing, escape) based solely on distance, this mode also keeps track of whether or not it was attacking previously (we'll call it the `Attacking` flag).

  * If target distance > `MaxDistance` then use **Closing** settings and set `Attacking = true`.
  * If target distance < `MinDistance` then use **Escape** settings and set `Attacking = false`.
  * Otherwise (i.e. `MinDistance` < target distance < `MaxDistance`) then:
    * If `Attacking = true` then use **Attack** settings.
    * If `Attacking = false` then use **Escape** settings.

The usual caveats about angles applies: If you want to actually get closer to the target, the angle should be < 90 degrees (i.e. both `AttackAngle` and `ClosingAngle`). If you want to get away from the target, the angle should be > 90 degrees (i.e. `EscapeAngle`).

In this mode, you will typically set `AttackAngle` to be 0 or some other small angle. And since you'd want to start the next attack run ASAP, `EscapeAngle` should be close to (or even equal to) 180.

This mode also keeps track of when the last attack run started (i.e. the time when target distance crosses under `MaxDistance`), and so two options unique to this mode come into play:

  * `ForceAttackTime` &mdash; This forces an attack run this many seconds after the last attack run. This is typically needed when facing off against a target that is faster.
  * `MinAttackTime` &mdash; Normally an attack run ends once reaching `MinDistance`, but this allows the vehicle to temporarily ignore that limit and get closer. Again, useful against faster targets. But note that it shouldn't be set too high, especially with a small `AttackAngle`, because otherwise the vehicle will probably ram the target. (Which may or may not be desireable I guess...)

## Evasion ##

All sets of settings (attack, closing, escape) have an evasion option, which is normally enabled by default (I don't believe in moving in straight lines during combat :P). Something like this:

    AttackEvasion = { 10, .125 }

The first number is the magnitude of the evasion in degrees. So the above tells the vehicle to randomly alter its attack angle by *up to* plus or minus 10 degrees while using the **Attack** settings.

The second number is a time scale. It has no units, really, but generally I've found values <1.0 to be suitable. Smaller means slower variations, larger means faster. I typically stick with .125 or .25.

Setting an evasion option to nil will disable it:

    AttackEvasion = nil

Deleting the option will do the same thing.

## Control Configuration ##

My naval AI is typically packaged with my 6dof/sixdof (6 degrees-of-freedom) module. However, only the yaw & forward axes are used.

By default it will use standard vehicle yaw & throttle controls, which will control rudders, propellers, and jets (if enabled in the 'V' menu).

You can enable dediblade control of yaw & propulsion by editing the following section:

    SpinnerFractions = {
       Altitude = 0,
       Yaw = 0, -- Set to positive number to enable dediblade yaw
       Pitch = 0,
       Roll = 0,
       Forward = 0, -- Set to positive number to enable dediblade propulsion
       Right = 0,
    }

Simply set the appropriate axis to 1. Like propellers/jets, side-facing dediblades will be used for yaw and forward-/reverse-facing dediblades will be used for propulsion.

Of the sixdof PIDs, only yaw is used:

    SixDoFPIDConfig = {
       ...
       Yaw = {
          Kp = .3,
          Ti = 5,
          Td = .4,
       },
       ...

The default values shown above are severely undertuned, but will probably work with many set ups. For my single rudder craft, I typically scale the yaw `Kp` up to 7.5 or so and leave the other values the same.

### Pitch & Roll Stabilization ###

As a benefit of using my 6dof/sixdof module, the *standalone* `naval-ai.lua` script can also perform pitch & roll stabilization. Under this section:

    ControlFractions = {
       -- Clashes with JetFractions.Yaw, Forward, AND Right
       Yaw = 1,
       -- Clashes with JetFractions.Altitude, Pitch, AND Roll
       Pitch = 0,
       -- Clashes with JetFractions.Altitude, Pitch, AND Roll
       Roll = 0,
       -- Clashes with JetFractions.Yaw, Forward, AND Right
       Forward = 1,
    }

Simply set `Pitch` and/or `Roll` to 1. Then place upward- and/or downward-facing jets/propellers on your vehicle and set their modes appropriately for their position (thruster, thruster reverse, lhs, rhs).

You will probably also need to scale up the `Kp` value on the appropriate PID in the `SixDoFPIDConfig` section. Start with 5 or so and keep increasing until you get the response you want.

Note that since the naval AI does not adjust roll or pitch at all, the set points are fixed at 0.

Scripts that have my naval AI packaged with an altitude module (e.g. hover or subcontrol) will typically have pitch & roll stabilized through that module.
