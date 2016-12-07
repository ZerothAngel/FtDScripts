# generalmissile Configuration #

## How It Works ##

 * If configured for dual-mode operation, it will select the mode (anti-air or profile)
   based on the elevation of the target (i.e. how high it is off the ground/sea level).

 * The mode can switch in-flight, e.g. when an aircraft splashes down in the water, the
   missile will switch to profile mode, if one is configured.

 * In anti-air mode, it will pursue the target with no restrictions. Optionally, when
   entering a configured "terminal range," it can modify the thrust settings of any
   variable thrusters.

   * Even though I call it anti-air mode, this mode may also be suitable for surface targets
     and for guiding torpedoes. As mentioned, it will pursue targets with no restrictions.

   * Because there's no restrictions, there's also no consideration for terrain at all.

 * Profiles are divided into an arbitrary number of phases. There are always at least
   two phases: closing phase and terminal phase.

   * The current phase is selected by determining the ground distance from the target, i.e.
     the distance without taking the altitude of either the target or missile into account.

   * The closing phase is selected when no other phases match.

   * In the terminal phase, the missile will pursue the target without any restrictions.
     It may optionally modify thrust.

   * In non-terminal phases, by default the missile will aim at a point that is between
     its current position and the *border* of the next inner phase.

     This point can be modified in two ways:

     * It can be rotated about the target (using the target's velocity to determine which
       way is "front").

     * It can also be raised or lowered relative to some other object, e.g. the target's
       current altitude, the ground underneath the target, or the target's depth under
       the ocean.

   * Non-terminal phases may also modify thrust and also apply pseudo-random horizontal
     evasion (which is pretty useless against most anti-missile defenses, but is there
     for rule-of-cool).

   * If configured for terrain-hugging, the missile will never aim below a set elevation
     above the terrain. This can be useful for torpedoes or targeting things on land.

## Example ##

The following is for dual-mode sea-skimming pop-up anti-ship missiles.

It will switch to anti-air mode if the target's elevation is greater than 10
meters (i.e. more than 10 meters above sea level or the ground).

When the profile is active, it will pop-up 250 meters from the target (as given by ground distance) to a height 30 meters above the target's ground. At a ground distance of 100 meters, it will enter the terminal phase and aim straight for the predicted aim point.

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       AntiAir = {
          DefaultThrust = nil,
          TerminalRange = nil,
          Thrust = nil,
          ThrustAngle = nil,
          OneTurnTime = 3,
          OneTurnAngle = 15,
          Gain = 5,
       },

       ProfileActivationElevation = 10,
       Phases = {
          {
             Distance = 100,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 250,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = 30,
             RelativeTo = 3,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = nil,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = nil,
             RelativeTo = 0,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = { 20, .25 },
          },
       },
    }

## Nomenclature ##

I try to keep the use of certain words consistent in the parameter names.

 * "elevation" &mdash; This is the height above the terrain or sea level.
 * "range" &mdash; The three-dimensional distance between the missile and target.
 * "distance" &mdash; The two-dimensional distance between the missile and target. Also known as ground distance.
 * "angle" &mdash; Most angle parameters are based on the angle between the missile's velocity and the target vector, i.e. an angle of 0 means heading straight toward the target.

## General Parameters ##

 * MinAltitude &mdash; Minimum operating altitude. The missile will always head straight up if ever below this altitude.
 * DetonationRange &mdash; Pseudo-proximity fuse. If non-nil, detonates at this range from the real aim point.
 * DetonationAngle &mdash; If non-nil, adds an additional condition in which to detonate. Detonates if the target vector is *greater* than this angle. e.g. Set to 90 and it will only detonate if the target is within DetonationRange and behind the missile.
 * LookAheadTime &mdash; The distance to look ahead at the terrain, given as a number of seconds (which is then multiplied by missile speed). nil disables terrain hugging.
 * LookAheadResolution &mdash; The resolution of the terrain look-ahead in meters. Smaller means more samples are taken, more processing is done. 0 disables terrain hugging.

## Anti-Air Parameters ##

These are used when the profile is not active.

For now, the script will use textbook Proportional-Navigation guidance when
in this mode.

 * DefaultThrust &mdash; If non-nil, set variable thrusters to this value when outside of terminal range.
 * TerminalRange &mdash; If non-nil, range from the target in which to use *Thrust* and *ThrustAngle*
 * Thrust &mdash; Thrust to use when within *TerminalRange* and *ThrustAngle* condition met. If negative then thrust is computed dynamically based on estimated remaining fuel and predicted impact time.
 * ThrustAngle &mdash; If non-nil, this is the maximum target vector angle before modifying thrust.
 * OneTurnTime &mdash; If non-nil, turn the missile directly at the target within this number of seconds after launch.
 * OneTurnAngle &mdash; If nil, base one-turn solely on launch time. Otherwise, the one-turn phase will potentially end early once the target vector angle is below this angle.
 * Gain &mdash; The PN gain. 5 seems to be good. Torpedoes seem to require much higher (like 500 or so). Too high and the missile will make loops at the slightest target movement (which is bad).

## Profile Parameters ##

 * ProfileActivationElevation &mdash; Target elevation at which to use profile. If the target's elevation is equal to or below this setting, the profile will be used. Otherwise the missile will switch to anti-air mode.
 * Phases &mdash; An array of parameters. You must have at least 2 entries. The first is always the terminal phase and at minimum requires *Distance*. The last is always the closing phase.

   All non-terminal phases require *Distance*, *AboveSeaLevel*, and *MinElevation*. All other phase parameters are optional (i.e. may be nil or omitted).

   Aside from the closing phase, all entries of *Phases* must be sorted by *Distance* from smallest to largest. For the closing phase, *Distance* means something else, so it may be smaller than its preceding phase.

### Phase Parameters ##

 * Distance &mdash; Ground distance at which this phase is active.

   For the closing phase, this represents the maximum distance to aim for
   when adjusting altitude. Smaller means the closing altitude is reached
   sooner, but a steeper angle must be made.
 * AboveSeaLevel &mdash; true or false which determines whether this phase occurs above or below the water line. Affects terrain hugging.
 * MinElevation &mdash; Added to terrain height to give the minimum altitude that the missile will go during this phase.
 * ApproachAngle &mdash; If non-nil, the missile will approach at a certain angle. "Forward" is based on the target's velocity. "0" will approach in front of the target, "180" from the rear, and "90" directly from the (closest) side. Because only the target's instantaneous velocity is used, this may yield unstable results.
 * Altitude &mdash; If non-nil, the altitude will be modified by adding this number with another. See *RelativeTo*

   For the terminal phase, this allows modification of the final aim point, e.g. to constrain it above (or below) the water line.
 * RelativeTo &mdash; Determines what *Altitude* is relative to. May be a number from 0 to 4:
   * 0 &mdash; *Altitude* is an absolute altitude
   * 1 &mdash; *Altitude* is added to the target's absolute altitude
   * 2 &mdash; *Altitude* is added to the target's sea depth, which will be negative and at most 0 (so not really a true depth).
   * 3 &mdash; *Altitude* is added to the target's ground, which will be at the very least 0 and take into account terrain directly underneath the target.
   * 4 &mdash; *Altitude* is added to the missile's current altitude. Using 0 for *Altitude* is probably best.
   * 5 &mdash; *Altitude* is a lower bound, i.e. max(target altitude, *Altitude*)
   * 6 &mdash; *Altitude* is an upper bound, i.e. min(target altitude, *Altitude*)
 * Thrust &mdash; Thrust to use when *ThrustAngle* condition met. If negative then thrust is computed dynamically based on estimated remaining fuel and predicted impact time (only makes sense for terminal phase otherwise you'll burn all your fuel early).
 * ThrustAngle &mdash; If non-nil, this is the maximum target vector angle before modifying thrust. If nil, then thrust is unconditionally modified upon switching to this phase. A non-nil value probably only makes sense for the terminal phase.
 * Evasion &mdash; nil or an array of two values. If non-nil, the first value is the maximum horizontal displacement in meters. The second value is the time scale, usually positive values <1 work well.

## Omitting Anti-Air or Profile Configs ##

If you omit the *AntiAir* section, then the profile defined by *Phases* will always be used.

If you omit the *Phases* section, then the missiles will always be in anti-air mode and always use the *AntiAir* parameters.

If neither are omitted, then you **must** define *ProfileActivationElevation* to differentiate between the two modes.

## More Examples ##

Note that none of these examples take advantage of *Thrust* and *ThrustAngle*. That's really up to you and the type of missile you build.

However, in almost all non-torpedo cases that use variable thrusters, you will probably benefit from dynamic terminal thrust: set *Thrust* to -1 and *ThrustAngle* to something small, like 3 to 7 degrees.

If you do set terminal thrust, it is also best to set *Thrust* of all non-terminal phases (or *DefaultThrust* for *AntiAir*). This ensures the missile resumes normal thrust should it happen to miss.

### Bottom-attack Torpedoes ###

Approaches 150 meters below target.

    Config = {
       MinAltitude = -500,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = 2,
       LookAheadResolution = 3,

       Phases = {
          {
             Distance = 175,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 50,
             AboveSeaLevel = false,
             MinElevation = 10,
             ApproachAngle = nil,
             Altitude = -150,
             RelativeTo = 2,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = nil,
          },
       },
    }

### Javelin-style Missiles ###

This assumes vertical launch with ejectors or horizontal launch from high-flying (>100 meters)
aircraft.

If not the case, change the last phase (closing phase) *Altitude* to 100 and *RelativeTo* to 3
to keep the approach altitude consistent.

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = nil,
       LookAheadResolution = 3,

       AntiAir = {
          DefaultThrust = nil,
          TerminalRange = nil,
          Thrust = nil,
          ThrustAngle = nil,
          OneTurnTime = 3,
          OneTurnAngle = 15,
          Gain = 5,
       },

       ProfileActivationElevation = 10,
       Phases = {
          {
             Distance = 150,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = 0,
             RelativeTo = 4,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = { 20, .25 },
          },
       },
    }

### Javelin-style Missiles (Alternate) ###

Alternate high-altitude version. If launched >500 meters (ground distance) from the target, it will climb to 300 meters. Works best when the terminal phase *Thrust* is set to -1 (along with a suitably small terminal phase *ThrustAngle*).

If your normal engagement range is closer than 500 meters, change the *Distance* of the middle phase. The idea behind the middle phase is to prevent the missile from climbing to 300 meters should it miss (or while pursuing an air target that crashed).

    Config = {
       MinAltitude = 0,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = nil,
       LookAheadResolution = 3,

       AntiAir = {
          DefaultThrust = nil,
          TerminalRange = nil,
          Thrust = nil,
          ThrustAngle = nil,
          OneTurnTime = 3,
          OneTurnAngle = 15,
          Gain = 5,
       },

       ProfileActivationElevation = 10,
       Phases = {
          {
             Distance = 150,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 500,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = 0,
             RelativeTo = 4,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = { 20, .25 },
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = 300,
             RelativeTo = 3,
             Thrust = nil,
             ThrustAngle = nil,
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

       AntiAir = {
          DefaultThrust = nil,
          TerminalRange = nil,
          Thrust = nil,
          ThrustAngle = nil,
          OneTurnTime = 3,
          OneTurnAngle = 15,
          Gain = 5,
       },

       ProfileActivationElevation = 10,
       Phases = {
          {
             Distance = 50,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 110,
             AboveSeaLevel = false,
             MinElevation = 10,
             ApproachAngle = nil,
             Altitude = -25,
             RelativeTo = 2,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = nil,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = nil,
             RelativeTo = 0,
             Thrust = nil,
             ThrustAngle = nil,
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

       AntiAir = {
          DefaultThrust = nil,
          TerminalRange = nil,
          Thrust = nil,
          ThrustAngle = nil,
          OneTurnTime = 3,
          OneTurnAngle = 15,
          Gain = 5,
       },

       ProfileActivationElevation = 10,
       Phases = {
          {
             Distance = 300,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 400,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = 50,
             RelativeTo = 3,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = nil,
          },
          {
             Distance = 50,
             AboveSeaLevel = true,
             MinElevation = 3,
             ApproachAngle = nil,
             Altitude = 0,
             RelativeTo = 4,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = { 20, .25 },
          },
       },
    }

### Plain Torpedoes ###

Alternative to sonar guidance (and far more undetectable at the cost of relying on the
detectors of the firing ship). Note that the PN gain has to be pretty high.

    Config = {
       MinAltitude = -500,
       DetonationRange = nil,
       DetonationAngle = 30,
       LookAheadTime = nil,
       LookAheadResolution = 3,

       AntiAir = {
          DefaultThrust = nil,
          TerminalRange = nil,
          Thrust = nil,
          ThrustAngle = nil,
          OneTurnTime = 3,
          OneTurnAngle = 15,
          Gain = 300,
       },
    }

### Plain Torpedoes (Alternate) ###

A problem with using AA mode for torpedoes is that the torpedoes
will indiscriminately target parts of the ship above the water line and
end up skimming the surface on approach.

An alternative is to use a profile with a closing depth set to 5 meters
(or whatever) below the target's depth.

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
             Distance = 100,
             Altitude = nil,
             RelativeTo = 1,
             Thrust = nil,
             ThrustAngle = nil,
          },
          {
             Distance = 50,
             AboveSeaLevel = false,
             MinElevation = 10,
             ApproachAngle = nil,
             Altitude = -5,
             RelativeTo = 2,
             Thrust = nil,
             ThrustAngle = nil,
             Evasion = nil,
          },
       },
    }
