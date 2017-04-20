Title: Public FtD Scripts
Date: 2017-04-05 00:00
Category: From the Depths
Tags: fromthedepths

# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts I've written since I started playing (about the middle of 2016).

## Scripts ##

I'll only list the interesting scripts (the ones not used for research or testing).

Also see my [notes]({filename}ftd-notes.md) about assumptions and possible gotchas.

### AI Replacements ###

These scripts wholly replace the "combat" and "fleetmove" behavior of the stock AI. (Still, using the stock Naval AI Card with these scripts is recommended, even for aircraft, as it provides a sane "patrol" behavior.)

All the combat-oriented scripts (everything but repair-ai and utility-ai) have the ability to dodge missiles that have been detected.

When using with an altitude control script, try using a combo script that includes the desired AI module (see below). It will have better integration (e.g. missile dodging also modifies altitude) and it will be more efficient in terms of CPU usage.

  * [airplane](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airplane.lua) &mdash; This is actually just naval-ai below packaged in a combo script meant for anything that flies like an airplane, i.e. responds to yaw/pitch/roll/propulsion controls. Supports banked turns and like naval-ai, supports broadside and attack run behaviors. Similar to the stock Aerial AI, but potentially much smoother since it has a number of built-in PIDs. See [the brief guide](https://github.com/ZerothAngel/FtDScripts/blob/master/control/airplane.md).
  * drop-ai &mdash; Dropship/boarding AI which follows the closest enemy and keeps the ship directly above (or below) it. This comes as a combo script, [a 6DoF jet/spinner version](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/drop.lua). There's currently no standalone version.
  * gunship-ai &mdash; A standoff AI that attempts to keep at a set distance from the target while continuously facing it. Moves laterally and longitudinally (forward *and* backward) to do so. Comes as a combo script, [a 6DoF jet/spinner version](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua). No standalone version currently available.
  * [naval-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/naval-ai.lua) &mdash; Naval AI (2D only) with terrain/friendly avoidance and pseudo-random evasive maneuvers. Supports both broadside and attack run behaviors. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20953))
  * [repair-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repair-ai.lua) &mdash; Advanced repair AI (2D only) with terrain/friendly avoidance. Fixates on the closest friendly and follows it throughout battle. However, it will head out to repair other nearby friendlies as well. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20998))
  * [utility-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utility-ai.lua) &mdash; Utility AI (2D only) with terrain/friendly avoidance. Meant for non-combatant ships in adventure mode. Has automatic wreck-collecting & resource gathering functions.

### Altitude/Depth Control (Only) ###

These scripts only provide altitude or depth control. They are meant to be used alongside a 2-dimensional AI, like the Naval AI card (or many of my AI scripts above). They also work fine with manual yaw & propulsion. All scripts will also allow manual (analog) control of the altitude/depth using a drive maintainer.

Again, if you're going to use these with my AI scripts, using a combo script (below) provides better integration and is more efficient.

  * [aerostat](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/aerostat.lua) &mdash; Controls helium pumps for lift and pitch/roll stabilization. I don't use this myself, so YMMV. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [subcontrol](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subcontrol.lua) &mdash; Hydrofoil script with pitch, roll, depth control + manual depth option. ([Forum post #1](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21908) [Forum post #2](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [subpump](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subpump.lua) &mdash; Controls air pumps for lift and pitch/roll stabilization. I don't use this myself as I prefer hydrofoil-based subs, but it's here for completeness. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [hover](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/hover.lua) &mdash; Upward- or downward-facing jets and/or spinners for lift and pitch/roll control.

### Missile Scripts ###

Note that the "unifiedmissile" module and all scripts based on it have been
superceded by a newer, more general missile module (uncreatively named
"generalmissile"). It can do everything unifiedmissile can do and more.

The generalmissile module is quite a bit harder to configure properly &mdash; using a Lua-aware editor is recommended &mdash; so I haven't bothered making any public posts about it. But it's available here.

#### generalmissile-based ####

These use the new configuration scheme detailed [in this doc](https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md).

  * [dualprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dualprofile.lua) &mdash; Dual-profile missile script, using a separate generalmissile instance for vertically- and horizontally-launched missiles.
  * [generalmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/generalmissile.lua) &mdash; Highly configurable missile script that supports dual-mode operation (AA or profile), an arbitrary number of profile phases, directional approach, and variable thrust control.
  * [multiprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/multiprofile.lua) &mdash; Multiple profile missile script, up to one generalmissile instance for each weapon slot.

#### Miscellaneous ####

  * [smartmine](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/smartmine.lua) &mdash; aka mobilemine. Rocket-propelled magnetic mines that automatically match depth and minimizes magnetic range when friendlies are nearby.

#### Legacy ####

These all use generalmissile under the hood, but continue to be configured as they were before. I will most likely not add any new configuration options, but they should continue to work for the foreseeable future.

  * [pnmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/pnmissile.lua) &mdash; Experimental script for pure proportional-navigation guidance.
  * [udualprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/udualprofile.lua) &mdash; Dual-profile missile script, using a separate unifiedmissile instance for vertically- and horizontally-launched missiles. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))
  * [umultiprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/umultiprofile.lua) &mdash; Multiple profile missile script, up to one unifiedmissile instance for each weapon slot. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))
  * [unifiedmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/unifiedmissile.lua) &mdash; Highly configurable advanced missile script that supports a variety of attack profiles. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))

### Turret Scripts ###

I've only recently started dabbling in Lua-aimed cannon turrets. Frankly, I don't see any solid advantages yet (aside from making the LWC/receiver/failsafe combo unnecessary). And you lose quite a bit, like failsafes and the ability to have AI-assisted manual targeting.

But it was an interesting exercise, and it **does** seem to be quite a bit more accurate.

  * [cameratrack](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/cameratrack.lua) &mdash; Controls turrets on a single weapon group and points them at the highest-priority enemy. Meant for cameras (so you can have a non-cheaty pseudo-3rd person view in adventure mode), **does not compute firing solutions for weapons**. Also useful for directing sensor turrets without the need for a missile controller+LWC.
  * [cannoncontrol](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/cannoncontrol.lua) &mdash; Cannon fire control script. Uses the quartic (4th degree) ballistic trajectory formula, so it takes gravity (of course) and relative target velocity into account. Can control one or more weapon groups with a different set of targeting limitations for each.
  * [rocketcontrol](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/rocketcontrol.lua) &mdash; Turret controller for dumbfire rockets or torpedoes. The missiles must not have any fins or guidance.

### Combo Scripts ###

I tend to build small and because of that, I avoid having more than a few Lua boxes. So I assemble and use combo scripts that are made up of many of my own scripts. This saves on Lua boxes and is also more efficient &mdash; stuff like targeting and weapon control only needs to happen once per run.

Note that all combo scripts that included dualprofile have been switched to
the generalmissile version of dualprofile. See note above about the missile
scripts.

  * [airplane](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airplane.lua) &mdash; Combo script: naval-ai + airplane + dualprofile + shieldmanager
  * [airship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airship.lua) &mdash; Combo script: naval-ai + hover + dualprofile + shieldmanager
  * [drop](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/drop.lua) &mdash; Combo script: drop-ai + sixdof + shieldmanager
  * [gunship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua) &mdash; Combo script: gunship-ai + sixdof + dualprofile + shieldmanager
  * [utility](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utility.lua) &mdash; Combo script: utility-ai + hover + shieldmanager
  * [utilitysub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utilitysub.lua) &mdash; Combo script: utility-ai + subcontrol + shieldmanager
  * [repair](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repair.lua) &mdash; Combo script: repair-ai + hover + shieldmanager
  * [repairsub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairsub.lua) &mdash; Combo script: repair-ai + subcontrol + shieldmanager
  * [scout](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/scout.lua) &mdash; Combo script: naval-ai + hover + shieldmanager + cameratrack
  * [scout6dof](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/scout6dof.lua) &mdash; Combo script: gunship-ai + sixdof + shieldmanager + cameratrack
  * [minelayer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/minelayer.lua) &mdash; Combo script: gunship-ai + sixdof + mobilemine + shieldmanager
  * [submarine](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/submarine.lua) &mdash; Combo script: naval-ai + subcontrol + dualprofile + shieldmanager
  * [warship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/warship.lua) &mdash; Combo script: naval-ai + dualprofile + shieldmanager

### Miscellaneous ###

  * [dediblademaintainer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dediblademaintainer.lua) &mdash; Allows linking a drive maintainer to forward/reverse-oriented dediblades for propulsion. This gives you full manual *analog* control of dediblades, allowing a quick way to zero-out the throttle (as with the "water drive") and also go in reverse.
  * [interceptmanager](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/interceptmanager.lua) &mdash; Fires a weapon slot (presumably a missile interceptor launcher) associated with one of the 4 directional quadrants whenever hostile missiles are detected. Distinguishes between incoming missiles & torpedoes. Saves ammo.
  * [shieldmanager](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/shieldmanager.lua) &mdash; Only activates shields facing enemies. Saves power.