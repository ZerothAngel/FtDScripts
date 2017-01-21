Title: Public FtD Scripts
Date: 2016-11-28 00:00
Category: From the Depths
Tags: fromthedepths

# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts I've written since I started playing (about the middle of 2016).

## Scripts ##

I'll only list the interesting scripts (the ones not used for research or testing).

### AI Replacements ###

These scripts wholly replace the "combat" and "fleetmove" behavior of the stock AI. (Still, using the stock Naval AI Card with these scripts is recommended, even for aircraft, as it provides a sane "patrol" behavior.)

  * [drop](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/drop.lua) &mdash; Experimental dropship/boarding AI which follows the closest enemy and keeps the ship directly above (or below) it. This is the full 6DoF thruster version that requires thrusters on all 6 sides. Note that I don't actually use this version since Lua control of thrusters is so tempermental. So it may go away.
  * [dropquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dropquad.lua) &mdash; Experimental dropship/boarding AI which follows the closest enemy and keeps the ship directly above (or below) it. This is the quadcopter version that uses dediblades for altitude/pitch/roll control and jets for yaw/longitudinal/lateral movement.
  * [gunship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua) &mdash; Gunship AI (standoff behavior with pseudo-random dodging), dedicated heliblade spinner for lift, jets for 5-axis control (yaw, pitch, roll, longitudinal, lateral).
  * [gunshipquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunshipquad.lua) &mdash; Gunship AI (standoff behavior with pseudo-random dodging), dedicated heliblade spinners for lift and pitch/roll control, jets for 3-axis control (yaw, longitudinal, lateral).
  * [naval-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/naval-ai.lua) &mdash; Naval AI (2D only) with terrain/friendly avoidance and pseudo-random evasive maneuvers. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20953))
  * [repair-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repair-ai.lua) &mdash; Advanced repair AI (2D only) with terrain/friendly avoidance. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20998))
  * [utility-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utility-ai.lua) &mdash; Utility AI (2D only) with terrain/friendly avoidance. Meant for non-combatant ships in adventure mode. Has automatic wreck-collecting & resource gathering functions.

### Altitude/Depth Control (Only) ###

These scripts only provide altitude or depth control. They are meant to be used alongside a 2-dimensional AI, like the Naval AI card (or many of my AI scripts above). They also work fine with manual yaw & propulsion. All scripts will also allow manual (analog) control of the altitude/depth using a drive maintainer.

  * [aerostat](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/aerostat.lua) &mdash; Controls helium pumps for lift and pitch/roll stabilization. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [hover](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/hover.lua) &mdash; Dedicated heliblade spinner for lift, jets for 2-axis control (pitch, roll). ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [quadcopter](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/quadcopter.lua) &mdash; Dedicated heliblade spinners for lift and pitch/roll control. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [subcontrol](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subcontrol.lua) &mdash; Hydrofoil script with pitch, roll, depth control + manual depth option. ([Forum post #1](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21908) [Forum post #2](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [subpump](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subpump.lua) &mdash; Controls air pumps for lift and pitch/roll stabilization. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [thrustercraft](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/thrustercraft.lua) &mdash; Jets for lift and pitch/roll control.

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

  * [airship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airship.lua) &mdash; Combo script: naval-ai + quadcopter + dualprofile + shieldmanager
  * [airshiphover](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airshiphover.lua) &mdash; Combo script: naval-ai + hover + dualprofile + shieldmanager
  * [gunship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua) &mdash; Combo script: gunship-ai + hover + dualprofile + shieldmanager
  * [gunshipquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunshipquad.lua) &mdash; Combo script: gunship-ai + quadcopter + dualprofile + shieldmanager
  * [utility](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utility.lua) &mdash; Combo script: utility-ai + quadcopter
  * [utilitysub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utilitysub.lua) &mdash; Combo script: utility-ai + subcontrol
  * [repairheli](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairheli.lua) &mdash; Combo script: repair-ai + hover
  * [repairquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairquad.lua) &mdash; Combo script: repair-ai + quadcopter
  * [repairsub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairsub.lua) &mdash; Combo script: repair-ai + subcontrol
  * [scout](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/scout.lua) &mdash; Combo script: naval-ai + quadcopter + shieldmanager + cameratrack
  * [submarine](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/submarine.lua) &mdash; Combo script: naval-ai + subcontrol + dualprofile + shieldmanager
  * [warship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/warship.lua) &mdash; Combo script: naval-ai + dualprofile + shieldmanager

### Miscellaneous ###

  * [dediblademaintainer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dediblademaintainer.lua) &mdash; Allows linking a drive maintainer to forward/reverse-oriented dediblades for propulsion.
  * [interceptmanager](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/interceptmanager.lua) &mdash; Fires a weapon slot (presumably a missile interceptor launcher) associated with one of the 4 directional quadrants whenever hostile missiles are detected. Distinguishes between incoming missiles & torpedoes. Saves ammo.
  * [shieldmanager](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/shieldmanager.lua) &mdash; Only activates shields facing enemies. Saves power.
  * [stabilizer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/stabilizer.lua) &mdash; 2-axis control (pitch, roll).
