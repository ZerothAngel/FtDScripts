Title: FtD Script Notes
Date: 2017-04-05 00:00
Category: From the Depths
Tags: fromthedepths

# ZerothAngel's FtD Script Notes #

Ultimately, I write these scripts for myself. Half of my enjoyment in these types of games (From the Depths, Space Engineers) is programming the behaviors and systems.

Also, I don't normally do code requests, but I'm open to interesting ideas, especially ones that I'd eventually use myself. (The dumb-fire rocket controller and smart mines are recent examples.)

Having said that all that, here are some notes on how my scripts are used and their likely limitations.

## What Scripts I Use Regularly ##

Or: What can be considered relatively bug-free.

Unfortunately, I don't get much feedback from other people. What I write is generally well-tested on my own designs. I'm sure for other people, if something of mine doesn't work near perfectly out-of-the-box, they drop it without a complaint. So I don't hear of problems.

I pretty much regularly use all scripts that I have listed on my public page. But there's a handful of exceptions, and you should be wary about using them as well:

 * airplane &mdash; This is still too new, and I have no airplane design of my own. I have been testing with the SD Wyvern, SS Retribution, and a workshop plane. All but the Retribution are just "aerodynamic bricks" &mdash; they don't actually have any lift. So something to be aware of.
 * aerostat/subpump &mdash; I just created these out of curiosity. I don't have any helium airships nor do I use air pumps for depth control of my submarines.
 * multiprofile &mdash; Though I use this regularly (it's now my standard missile script), I don't use the weapon slot or direction selectors at all.
 * umultiprofile/unifiedmissile &mdash; These are obsolete, but they're written on top of generalmissile, so everything underneath the configuration is still well-tested.
 * rocketcontrol &mdash; Created this due to a request, but I don't use it myself.
 * interceptmanager &mdash; This was necessary on my adventure sub because I couldn't get the firing constraints to work for the side-firing anti-torpedo torpedoes. But I've since switched to LAMS.

## Mainframes ##

The Lua interface to mainframes is very barebones and minimal. And like the other block-oriented Lua bindings, there's no method to directly address specific blocks.

**So I build with only one mainframe**.

With multiple mainframes, when one gets destroyed and then rebuilt, it gets put at the end of the mainframe list. Since mainframes can only be addressed by their index into this list, this is a big problem. We have no access to the mainframe names, only to their *world* coordinates (which changes from frame to frame as the vehicle moves/rotates). It's probably possible to map this back to local coordinates, but it may still be iffy.

Additionally, `I.AIMode` (which returns the AI's state &mdash; "off", "on", "combat", etc.) only looks at mainframe 0. Depending on damage, mainframe 0 may not be the one with the required cards.

So when using my script (or any Lua script, really), it's best to use a single mainframe **or** equip each mainframe identically (same cards). Something I'm experimenting with is having a single set of cards shared by multiple mainframes (all transmitting on the same channel).

## Thrusters ##

The Lua binding for thruster control, `I:RequestThrustControl`, runs all thrust requests through some sort of propulsion balancing. So if one facing does not have perfectly balanced jets on both sides of the CoM, they will not fire (because it would induce a rotation).

This isn't ideal and causes problems especially if you don't build symmetrically or if thrusters get damaged.

This is why I tend to favor quadcopters and dediblade-based airships.

A workaround is to use a complex controller key to trigger jets. A downside is that this key would no longer be available for manual usage. However, there are quite a number of complex controller keys (around 14 or so), so it shouldn't be much of a problem.

Additionally, since axes are often related (e.g. altitude/pitch/roll use upward-/downward-facing jets), jets can be reduced to using a single key.

See the `APRThrustHackKey`, `YLLThrustHackKey` and `ThrustHackKey` options of appropriate scripts.

## Missiles ##

I'm typically pretty conservative with my missiles. I often hear talk about monstrous 8- or 10- block long missiles.

**I usually just stick with 6 blocks or less**. So my missiles are just a tad more maneuverable and that's what the phase distances in my scripts are tuned for.

## Yaw ##

The yaw PID of my scripts is typically undertuned. It seems to be common nowadays to stack multiple rudders and such.

You will typically benefit from increasing `Kp` for the yaw PID. (I usually use around 7.5 for single rudder designs and scale appropriate for designs with 2 or more.)

Just remember: assuming any sort of "evasion" is off, if your vehicle oscillates too much while attempting to go in a straight line, you will have to lower `Kp`.

You may also be interested in my [yawtest](https://zerothangel.com/FtDScripts/yawtest.lua) script to help in tuning, which, while moving forward at various speeds, rotates the vehicle every 90 degrees every minute or so. It also outputs informative stats like turning radius and turning time.
