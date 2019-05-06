# Control Modules #

Various modules for moving or rotating the ship along 1 or more degrees of freedom.

## Meta-Modules ##

  * altitudecontrol &mdash; Automatic/manual altitude control for anything above sea level.
  * depthcontrol &mdash; Automatic/manual altitude control for anything below sea level.
  * planelike &mdash; Meta-module (does not control any actual "hardware") for airplane-like flight. Altitude & heading parameters are converted to the necessary yaw/pitch/roll control outputs to achieve them. Suitable for airplanes or submarines.
  * rollturn &mdash; Meta-module for banked turns. More for "Rule of Cool" than anything else since it does not control pitch to pull into the turn.

## 2 Degrees of Freedom ##

  * tanksteer &mdash; Controls dual drive maintainers, one assigned to a tank's left track and the other to the right. For true analog differential steering. Provides yaw & longitudinal movement.

## 3 Degrees of Freedom ##

  * subcontrol &mdash; Depth and pitch/roll control using hydrofoils.

## 6 Degrees of Freedom ##

  * sixdof &mdash; Altitude/yaw/pitch/roll/longitudinal/lateral control using jets and/or spinners. Highly configurable, can be set to only provide control along arbitrary axes.

## Interface ##

The global table `V` houses the control functions, e.g. `V.SetThrottle`

Set* &mdash; Set to given absolute value

Adjust* &mdash; Adjust by given relative value

Reset* &mdash; Hint to release control along this/these degree(s) of freedom

  * SetHeading/AdjustHeading/ResetHeading &mdash; Yaw
  * SetAltitude/AdjustAltitude &mdash; Altitude (Global Y-axis)
  * SetPosition/AdjustPosition/ResetPosition &mdash; Planar position (Global X & Z-axis)
  * SetPitch/SetRoll &mdash; Pitch & roll
  * SetThrottle/AdjustThrottle/ResetThrottle &mdash; Forward/reverse throttle (Longitudinal axis)
  * Reset &mdash; Typically releases control along X & Z plane. Main module's responsibility to actually map this function.
