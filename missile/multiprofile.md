# multiprofile Configuration #

My [multiprofile missile script](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/multiprofile.lua), which is also available as part of many of my "combo scripts," solves one particular problem: When you have multiple missile scripts with different behaviors, how do you assign them to each Lua transceiver?

The multiprofile script is basically a wrapper around my generalmissile module, and more details about configuring *that* can be found [in its own docs](https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md). The multiprofile script allows the use of one or more generalmissile instances on a single vehicle, where each instance can have a totally different behavior (e.g. anti-air missiles and torpedoes).

This script is a more generalized version of my "dualprofile" script and by default, it is set up to behave the same way (i.e. two profiles, one vertical, one horizontal).

## Why the Need? ##

The Lua interface in FtD kinda sucks (though I'm grateful it's even there :P). There would be no need for most parts of this module if just one of many changes were made:

 1. The Lua transceiver knew what weapon slot its associated missile controller was assigned to.
 2. There was a way to fetch the (indices) of the Lua transceivers that were associated with a missile controller.
 3. The Lua transceiver and missile controller could tell the difference between being on the hull vs. being on a subconstruct (e.g. a flag or ID in the BlockInfo table). Not as ideal, as trying to match things by distance still has its own problems, but at least there wouldn't be "leakage" between the main hull and subconstructs.

...And probably many others that I haven't thought up of yet.

## Usage ##

The multiprofile script lets you:

 1. Create multiple missile "profiles," each with its own generalmissile configuration.
 2. Assign one of three selection methods to each profile. Currently, you can:
    * Use launcher orientation (vertical or horizontal), as it was in the dualprofile script
    * Use launcher direction (left, right, up, down, forward, back)
    * Use the weapon slot of the nearest missile controller within a given distance
 3. Assign range & altitude limits to each profile (e.g. only surface/air targets for profile #1, only surface/submarine targets for profile #2)
 4. Optionally enable/change other features (fire control, target selection).

## Profiles ##

The profiles start under this section

    MissileProfiles = {

and continue to the final closing brace.

Note that it helps to have a Lua-aware editor that will automatically indent lines. Or at least, something that can match braces and parenthesis.

A typical profile will look something like this:

       {
          SelectBy = { Orientation = false, }, -- Horizontal
          FireWeaponSlot = nil,
          TargetSelector = 1,
          Limits = {
             MinRange = 0,
             MaxRange = 9999,
             MinAltitude = -500,
             MaxAltitude = 15,
          },
          -- Bottom-attack torpedoes
          Config = {
             MinAltitude = -500,
             DetonationRange = 15,
             DetonationAngle = 30,
             LookAheadTime = 2,
             LookAheadResolution = 3,

             Phases = {
                {
                   Distance = 175,
                   Altitude = 0,
                   RelativeTo = 6,
                },
                {
                   Distance = 50,
                   AboveSeaLevel = false,
                   MinElevation = 10,
                   ApproachAngle = nil,
                   Altitude = -50,
                   RelativeTo = 2,
                   Evasion = nil,
                },
             },
          },
       },

The `Config` section is covered by the [generalmissile doc](https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md). Everything else will be covered here.

I recommend deleting any profiles that you don't use.

## SelectBy ##

This section covers this part

          SelectBy = { Orientation = false, }, -- Horizontal

and is how the profile selects which Lua transceivers to associate with (which then determine the behavior for that Lua transceiver's/launch pad's missiles).

There are currently 3 ways to select Lua transceivers. A few more are possible, e.g. perhaps by relative position to the center-of-mass. But I plan to implement those as the need arises.

But first, a short word on matching priority. If a Lua transceiver potentially matches multiple profiles, then:

 * If there is a matching profile that uses weapon slot/distance selection, that will always be used
 * If not, then the first matching profile (going down the list) will be used

If there are no profile matches (maybe because of damage, maybe because of misconfiguration), then the 1st profile will be used.

Note that by default, the selection of Lua transceivers only happens every 5 seconds (as determined by the missile driver module's `TransceiverResetInterval` setting) or whenever a Lua transceiver is destroyed or rebuilt (in other words, when the # of Lua transceivers changes). So even if the wrong profile is selected due to damage, it should only be temporary, assuming the vehicle is actively being repaired.

### Launcher Orientation ###

Very simple. Distinguishes between vertical launchers and horizontal launchers.

**However** note that on subconstructs (anything on a turret or spinner), the concept of "horizontal" and "vertical" are relative to the turret/spinner block. You can most readily see this when first building on a subconstruct, as it will re-orient your view.

To select vertical launchers:

    SelectBy = { Orientation = true, },

To select horizontal launchers:

    SelectBy = { Orientation = false, },

Fairly straightforward.

### Launcher Direction ###

Similar to using launcher orientation, but allowing greater flexibility, you can have a profile select Lua transceivers by the specific direction the launcher is facing. You can even specify multiple directions.

For example, for a single direction (left, in this case):

    SelectBy = {
       Direction = { Vector3.left, },
    },

Or multiple directions (left and right):

    SelectBy = {
       Direction = { Vector3.left, Vector3.right, },
    },

Also quite simple. The list of possible directions is as follows:

 * Vector3.forward
 * Vector3.back
 * Vector3.right
 * Vector3.left
 * Vector3.up
 * Vector3.down

Also note, like launcher orientation, when dealing with launchers on subconstructs, these directions are relative to the turret/spinner block.

### Weapon Slot & Distance ###

This method allows selection of Lua transceivers by their proximity to a missile controller (which is hopefully the missile controller they are actually associated with &mdash; see the issues above about the limitations of the Lua interface).

Basically you specify two parameters, weapon slot and distance:

    SelectBy = { WeaponSlot = 1, Distance = 5, },

This means that any Lua transceiver within 5 meters (measured via straight-line distance) of any missile controllers assigned to weapon slot 1 are selected by the profile.

If a Lua transceiver happens to match multiple profiles via this method (maybe because the `Distance` parameter is too generous), then the closer missile controller wins.

One very important note: due to limitations of the Lua interface, there's no way to distinguish between between being on the hull vs. being on a subconstruct. So it is very much possible for a Lua transceiver to be associated with a hull-mounted missile controller one second and then a turret-mounted missile controller another (because the turret rotated, moving its missile controller closer).

Not too much of a problem if your turrets and hull-mounted launchers are spaced out quite a bit. But something to look out for on more compact vehicles.

Also note that this selection method is a little more intensive than the others (since it has to scan all weapon controllers and perform distance calculations to all missile controllers per Lua transceiver). If you can use the other selection methods instead, I recommend doing so!

## Limits ##

This next section

          Limits = {
             MinRange = 0,
             MaxRange = 9999,
             MinAltitude = -500,
             MaxAltitude = 15,
          },

allows you to specify targeting limits for the profile. And I recommend that you always do.

If you have a Local Weapon Controller, then it should match the settings in that. (Why the duplication? Basically, the LWC determines *when* to fire the missiles and the limits set here will determine the targets to lock onto when the missiles are first launched *and* when the missile attempts to lock onto a new target while mid-flight.)

If you don't have an LWC, then these limits will be used for everything: determining when to fire, the potential targets for the initial lock, the next targets when re-locking mid-flight. (If you have no LWC, the assumption is that you will enable `FireWeaponSlot` below...)

## Other Settings ##

There are two other settings:

          FireWeaponSlot = nil,
          TargetSelector = 1,

### FireWeaponSlot ###

By default, this is set to `nil`:

    FireWeaponSlot = nil,

This means that the script depends on the AI to fire ze missiles using a Local Weapon Controller.

If you set it to a number:

    FireWeaponSlot = 2,

It means that the script itself will fire missiles using that weapon slot. One reason to do this is to avoid using an LWC + receiver (saves on blocks, makes you a little more stealthy... so a little cheesy). This works great for anything hull-mounted, but just note that Lua does not have access to the LWC failsafe mechanism. So if you use it for turrets, make sure you set azimuth/elevation constraints on the turret so it doesn't shoot your own ship! (Also remember to set a constraint on the missile controller itself, so it only fires at targets in front of the launchers.)

For turrets, the missile controller(s) and turret block should be on the same weapon slot.

Lastly, when the script aims the turrets, it doesn't bother leading the target. The missiles are guided missiles, after all.

### TargetSelector ###

For this option, there are two possible settings. It only governs the *first* target that the missile locks onto.

When set to this

    TargetSelector = 1,

then newly-launched missiles will lock onto the highest-priority target within the limits set by the `Limits` configuration.

If you set it to this

    TargetSelector = 2,

then newly-launched missiles essentially randomly select targets that meet their profile's `Limits` configuration.

More target selection modes are possible (like probabilistic ones), but I haven't been inspired to implement them. I'm not really a fan of splitting my DPS. :P
