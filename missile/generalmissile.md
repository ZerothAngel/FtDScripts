Title: FtD GeneralMissile
Date: 2019-05-11 00:00
Category: From the Depths
Tags: fromthedepths

# generalmissile Configuration #

## How It Works ##

 * If configured for dual-mode operation, it will select the mode (anti-air or surface)
   based on the elevation of the target (i.e. how high it is off the ground/sea level).

 * The mode can switch in-flight, e.g. when an aircraft splashes down in the water, the
   missile will switch to surface mode, if one is configured.

 * In anti-air mode, it will use the anti-air profile, which has no regards for terrain.

 * In surface mode, it will use the surface profile. In non-terminal phases, it is
   capable of hugging the terrain.

 * Profiles are divided into an arbitrary number of phases. There are always at least
   two phases: closing phase and terminal phase.

    * The terminal phase is the inner-most phase. The closing phase is the outer-most.

    * For the anti-air profile, the current phase is selected by the range (straight
      line distance) from the target.

    * For the surface profile, the current phase is selected by the ground distance from
      the target, i.e. the distance without taking the altitude of either the target or
      missile into account.

    * The closing phase is selected when no other phases match.

    * In the terminal phase, the missile will pursue the target without any restrictions,
      i.e. no regards for terrain. The altitude of the final aim point may be raised or
      lowered in some way.

    * In a sense, for the anti-air profile, the phases can be thought of as concentric
      spheres around the target. For the surface profile, they are concentric
      cylinders.
 
    * In non-terminal phases, by default the missile will aim at a point that is between
      its current position and the *border* of the next inner phase.
      This point can be modified in two ways:

        * It can be rotated about the target (using the target's velocity to determine which
          way is "front"). Currently, only available to the surface profile.

        * It can also be raised or lowered relative to some other object, e.g. the target's
          current altitude, the ground underneath the target, or the target's depth under
          the ocean.

        * For the surface profile, if no aim point modification is done, it will simply
          hug the terrain.

    * All phases may conditionally modify thrust and other missile parameters, such as
      magnet range or ballast depth.

    * Non-terminal phases may apply pseudo-random horizontal evasion (which is pretty
      useless against most anti-missile defenses, but is there for rule-of-cool).
      Currently only available to the surface profile.

## Example ##

The following is for dual-mode sea-skimming pop-up anti-ship missiles.

It will switch to anti-air mode if the target's elevation is greater than 10
meters (i.e. more than 10 meters above sea level or the ground).

When the surface profile is active, it will pop-up 250 meters from the target (as given by ground distance) to a height 30 meters above the target's ground. At a ground distance of 100 meters, it will enter the terminal phase and aim straight for the predicted aim point.

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       AirProfileElevation = 10,
       AntiAir = {
          Phases = {
             {
                -- Basically, just terminal phase all of the time
             },
          },
       },

       Phases = {
          {
             Distance = 100,
          },
          {
             Distance = 250,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 30,
             RelativeTo = 3,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             Evasion = { 20, .25 },
          },
       },
    }

## Nomenclature ##

I try to keep the use of certain words consistent in the parameter names, regardless of the actual meanings outside of this context.

 * "elevation" &mdash; This is the height above the terrain or sea level.
 * "range" &mdash; The three-dimensional straight-line distance between the missile and target.
 * "distance" &mdash; The two-dimensional distance between the missile and target. Also known as ground distance.
 * "angle" &mdash; Most angle parameters are based on the angle between the missile's velocity and the target vector, i.e. an angle of 0 means heading straight toward the target.

## General Parameters ##

 * MinAltitude &mdash; Minimum operating altitude. The missile will always head straight up if ever below this altitude.
 * DetonationRange &mdash; Pseudo-proximity fuse. If non-nil, detonates at this range from the real aim point.
 * DetonationAngle &mdash; If non-nil, adds an additional condition in which to detonate. Detonates if the target vector is *greater* than this angle. e.g. Set to 90 and it will only detonate if the target is within DetonationRange and behind the missile.
 * LookAheadTime &mdash; The distance to look ahead at the terrain, given as a number of seconds (which is then multiplied by missile speed). nil disables terrain hugging.
 * LookAheadResolution &mdash; The resolution of the terrain look-ahead in meters. Smaller means more samples are taken, more processing is done. 0 disables terrain hugging.

 * AirProfileElevation &mdash; If the target's elevation is equal to or below this setting, the surface profile will be used. Otherwise the missile will use the anti-air profile. Only necessary if *both* anti-air and surface profiles are defined.

## Profile Configuration ##

Both anti-air and surface profiles have a *Phases* array. The first phase in the array is always the terminal phase. The last is always the closing phase. The array must be sorted from least to greatest according to their *Range* value (for anti-air) or *Distance* value (for surface) except for the very last (aka closing) phase.

 * For the anti-air profile:

    * The *Range* value is used to deterimine when this phase is active. This is the straight-line distance between the missile and target.
    * The closing phase may be omitted if there are no other phases other than the terminal phase. In this case, the terminal phase may also omit its *Range*.
    * If there is a closing phase, it may omit its *Range* (the range for the closing phase is always taken to be infinite).

 * For the surface profile, the *Distance* value is used to determine when the phase is active. This is the ground distance between missile and target.

## Common Phase Parameters ##

These are parameters that may be present in both anti-air and surface phases.

 * Altitude &mdash; If non-nil, the altitude will be modified by adding this number with another. See *RelativeTo*

   For the terminal phase, this allows modification of the final aim point, e.g. to constrain it above (or below) the water line.

 * RelativeTo &mdash; Determines what *Altitude* is relative to. May be a number from 0 to 6:

    * 0 &mdash; *Altitude* is an absolute altitude
    * 1 &mdash; *Altitude* is added to the target's absolute altitude
    * 2 &mdash; *Altitude* is added to the target's sea depth, which will be negative and at most 0 (so not really a true depth).
    * 3 &mdash; *Altitude* is added to the target's ground, which will be at the very least 0 and take into account terrain directly underneath the target.
    * 4 &mdash; *Altitude* is added to the missile's current altitude. Using 0 for *Altitude* is probably best.
    * 5 &mdash; *Altitude* is a lower bound, i.e. max(target altitude, *Altitude*)
    * 6 &mdash; *Altitude* is an upper bound, i.e. min(target altitude, *Altitude*)

 * Change &mdash; An optional (i.e. can be nil or omitted) table of parameters that specify changes to the missile's state, e.g. variable thrust change, ballast depth change, etc. See the section below for more details.

## Anti-Air Phase Parameters ##

Currently, the anti-air profile does not have any phase parameters specific to anti-air aside from *Range*, which may be omitted in certain situations as noted above.

## Surface Phase Parameters ##

All phases require *Distance*.

All non-terminal phases also require *AboveSeaLevel*, and *MinElevation*. All other phase parameters are optional (i.e. may be nil or omitted).

For the closing phase, *Distance* represents the maximum distance to aim for when adjusting altitude. Smaller means the closing altitude is reached sooner, but a steeper angle must be made.

 * AboveSeaLevel &mdash; true or false which determines whether this phase occurs above or below the water line. Affects terrain hugging.
 * MinElevation &mdash; Added to terrain height to give the minimum altitude that the missile will go during this phase.
 * ApproachAngle &mdash; If non-nil, the missile will approach at a certain angle. "Forward" is based on the target's velocity. "0" will approach in front of the target, "180" from the rear, and "90" directly from the (closest) side. Because only the target's instantaneous velocity is used, this may yield unstable results.
 * Evasion &mdash; nil or an array of two values. If non-nil, the first value is the maximum horizontal displacement in meters. The second value is the time scale, usually positive values <1 work well.

## Omitting Anti-Air or Surface Configs ##

If you omit the *AntiAir* section, then the profile defined by *Phases* will always be used.

If you omit the *Phases* section, then the missiles will always be in anti-air mode and always use the *AntiAir* parameters.

If neither are omitted, then you **must** define *AirProfileElevation* to differentiate between the two modes.

## Change Parameters ##

All phases in a profile may have an optional set of parameters that determine when and how to change the missile's state.

An example, which includes all currently supported parameters:

    Change = {
       When = {
          Angle = nil,
          Range = nil,
          AltitudeGT = nil,
          AltitudeLT = nil,
       },
       Thrust = nil,
       ThrustDelay = nil,
       ThrustDuration = nil,
       BallastDepth = nil,
       BallastBuoyancy = nil,
       MagnetRange = nil,
       MagnetDelay = nil,
    },

The *When* section describes when the state change is made. If it is omitted (or if all its conditions are nil), then the state will be changed immediately upon entering that phase.

### When Conditions ###

If there are multiple non-nil conditions, then all conditions must be met before the state is changed.

 * Angle &mdash; Maximum target vector angle before modifying state, e.g. if set to 7 then the state will be changed once the missile's velocity is pointing within 7 degrees of the aim point.
 * Range &mdash; Maximum range (straight-line distance) before modifying state, e.g. if set to 300 then the state will be changed once the missile is 300 meters or closer.
 * AltitudeGT &mdash; Altitude greater than some number. If the altitude of the missile is greater than this, then the state will be changed.
 * AltitudeLT &mdash; Altitude less than some number. If the altitude of the missile is less than this, then the state will be changed.

### State Parameters ###

Each parameter affects a single type of missile part. If there are multiple of such parts, then the same value is set in all of them (which the exception of variable thrusters, noted below).

 * Thrust &mdash; Set variable thrust. This number is divided by the number of variable thrusters. If *Thrust* is less than 0, then the thrust will be computed dynamically based on the estimated time to impact and the (estimated) remaining fuel. This is very useful for terminal phases, but should include some sort of *Angle* condition.
 * ThrustDelay &mdash; Start delay of short range thrusters. For example, you can configure the missile with maximum delay (using the 'Q' screen) of 60 seconds and then have the Lua script set the delay to 0 after a certain phase has been reached, which will ignite all short range thrusters.
 * ThrustDuration &mdash; Burn duration of short range thrusters. You can, for example, set this to 0 once reaching a certain phase to shut down all short range thrusters and glide (ballistically) the rest of the way to the target.
 * BallastDepth &mdash; Depth setting of all ballast tanks.
 * BallastBuoyancy &mdash; Buoyancy setting of all ballast tanks.
 * MagnetRange &mdash; Range of all magnets.
 * MagnetDelay &mdash; Start delay of all magnets. For example, useful for only enabling magnets after reaching terminal phase.

## More Examples ##

Note that none of these examples take advantage of *Change* parameters. That's really up to you and the type of missile you build.

However, in almost all non-torpedo cases that use variable thrusters, you will probably benefit from dynamic terminal thrust: set *Thrust* to -1 and *Angle* to something small, like 3 to 7 degrees, e.g.

    Phases = {
       -- The terminal phase
       {
          Distance = 150,
          Change = {
             When = { Angle = 3 },
             Thrust = -1,
          },
       },
       ...
    }

If you do set terminal thrust, it is also best to set *Thrust* of all non-terminal phases. This ensures the missile resumes normal thrust should it happen to miss.

    Phases = {
       ...
       -- Other phases
       {
          Distance = 400,
          ...
          Change = { Thrust = 300, },
       },
       ...
    }

Also be sure to read up on the wiki [on calculating turning radius](http://fromthedepths.gamepedia.com/Missile_aerodynamics#Turn_speed) from the displayed turning rate. Since many profiles involve a 90-degree turn in the terminal phase, knowing the radius will help tune altitude (or depth) and the terminal phase ground distance.

### Bottom-attack Torpedoes ###

Approaches 50 meters below target. In general, (closing depth)^2 + (terminal phase ground distance)^2 should be greater than (torpedo turn radius)^2.

    Config = {
       MinAltitude = -500,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       Phases = {
          {
             Distance = 175,
          },
          {
             Distance = 50,
             AboveSeaLevel = false,
             MinElevation = 10,
             Altitude = -50,
             RelativeTo = 2,
          },
       },
    }

### Javelin-style Missiles ###

This assumes vertical launch with ejectors or horizontal launch from high-flying (>100 meters)
aircraft.

If not the case, change the last phase (closing phase) *Altitude* to 100 and *RelativeTo* to 3
to keep the approach altitude consistent.

Like bottom-attack torpedoes above, (closing altitude)^2 + (terminal phase ground distance)^2 should be at least (missile turn radius)^2.

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = nil,
       LookAheadResolution = 3,

       AirProfileElevation = 10,
       AntiAir = {
          Phases = {
             {
             },
          },
       },

       Phases = {
          {
             Distance = 150,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 0,
             RelativeTo = 4,
             Evasion = { 20, .25 },
          },
       },
    }

### Javelin-style Missiles (Alternate) ###

Alternate high-altitude version. If launched >500 meters (ground distance) from the target, it will climb to 300 meters. Works best when the terminal phase *Thrust* is set to -1 (along with a suitably small terminal phase *Angle*).

If your normal engagement range is closer than 500 meters, change the *Distance* of the middle phase. The idea behind the middle phase is to prevent the missile from climbing to 300 meters should it miss (or while pursuing an air target that crashed).

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = nil,
       LookAheadResolution = 3,

       AirProfileElevation = 10,
       AntiAir = {
          Phases = {
             {
             },
          },
       },

       Phases = {
          {
             Distance = 150,
          },
          {
             Distance = 500,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 0,
             RelativeTo = 4,
             Evasion = { 20, .25 },
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 300,
             RelativeTo = 0,
             Evasion = { 20, .25 },
          },
       },
    }

### Duck-under Missiles ###

Approaches by skimming the sea. Dives ~100 meters from target to take advantage of underwater
explosive buff.

Missile should be a full explosive missile with a single torpedo propeller or ballast tank
(needs experimenting, but the propeller works well for my designs).

    Config = {
       MinAltitude = -50,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       AirProfileElevation = 10,
       AntiAir = {
          Phases = {
             {
             },
          },
       },

       Phases = {
          {
             Distance = 50,
          },
          {
             Distance = 110,
             AboveSeaLevel = false,
             MinElevation = 10,
             Altitude = -25,
             RelativeTo = 2,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             Evasion = { 20, .25 },
          },
       },
    }

### ASROC-style Torpedoes ###

Meant for underwater targets only, but can switch to AA-mode if needed. Missile should more
or less be a full torpedo (with ballast tanks and propellers) with a variable thruster.

Assumes horizontal launch close to sea level. If this isn't the case, adjust the closing
phase altitude appropriately (it is meant to approach <50 meters above the sea).

    Config = {
       MinAltitude = -500,
       DetonationRange = 15,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       AirProfileElevation = 10,
       AntiAir = {
          Phases = {
             {
             },
          },
       },

       Phases = {
          {
             Distance = 300,
          },
          {
             Distance = 400,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 50,
             RelativeTo = 3,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 0,
             RelativeTo = 4,
             Evasion = { 20, .25 },
          },
       },
    }

### Plain Torpedoes ###

This is basically a copy of the bottom-attack torpedo profile but with
less extreme closing depth.

    Config = {
       MinAltitude = -500,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       Phases = {
          {
             Distance = 150,
          },
          {
             Distance = 50,
             AboveSeaLevel = false,
             MinElevation = 10,
             Altitude = -10,
             RelativeTo = 2,
          },
       },
    }

### "Ballistic" Missiles ###

Vertically-launched missiles (with ejectors) made up of: fins, short range
thruster(s), fuel tanks, Lua receiver, APN (gain 10), warheads, and a seeker
head of some sort (radar works). Guidance delay should be set to max.

Climbs up to ~350 meters, gets within 650 meters (ground distance) of the
target, kills the short range thruster and then glides the rest of the way
in. Undetectable by missile warners.

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       Phases = {
          {
             Distance = 650,
             Change = {
                When = { AltitudeGT = 100, },
                ThrustDuration = 0,
             },
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             Altitude = 350,
             RelativeTo = 0,
          },
       },
    }
