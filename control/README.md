# Control Modules #

Various modules for moving or rotating the ship along 1 or more degrees of freedom. Modules that
control complementary DoFs can be combined.

## Libraries ##

  * altitudecontrol &mdash; Automatic/manual altitude control for anything above sea level.
  * depthcontrol &mdash; Automatic/manual altitude control for anything below sea level.
  * spinnercontrol &mdash; Generic module for controlling spinners oriented along a given axis.
  
## 1 Degree of Freedom ##

  * hover &mdash; Controls upward/downward-oriented dediblades for lift.

## 2 Degrees of Freedom ##

  * stabilizer &mdash; Upward/downward-oriented jets for roll & pitch control.
  * yawthrottle &mdash; Uses standard ship controls (e.g. as from a vehicle controller) for yaw and throttle (forward/reverse). Can also use forward/reverse-oriented spinners for propulsion.

## 3 Degrees of Freedom ##

  * subcontrol &mdash; Depth and pitch/roll control using hydrofoils.
  * threedof &mdash; Planar movement using jets: yaw, forward/reverse, right/left.
  * threedofpump &mdash; Pump control for altitude/pitch/roll.
  * threedofspinner &mdash; Upward/downward-oriented spinners for altitude/pitch/roll.

## 5 Degrees of Freedom ##

  * fivedof &mdash; Controls jets in all orientations for yaw/pitch/roll + forward/reverse + right/left.

## Interface ##

Set* &mdash; Set to given absolute value

Adjust* &mdash; Adjust by given relative value

Reset* &mdash; Hint to release control along this/these degree(s) of freedom

  * SetHeading/AdjustHeading/ResetHeading &mdash; Yaw
  * SetAltitude/AdjustAltitude &mdash; Altitude (Y-axis)
  * SetPosition/AdjustPosition/ResetPosition &mdash; Planar position (Global X & Z-axis)
  * SetPitch/SetRoll &mdash; Pitch & roll
  * SetThrottle/AdjustThrottle/ResetThrottle &mdash; Forward/reverse throttle (Local Z-axis)
  * Control_Reset &mdash; Typically releases control along local/global X & Z-axis. Main module's responsibility to actually map this function.
