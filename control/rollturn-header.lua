-- ROLL TURN CONFIGURATION

RollTurn = {
   -- Set to a number to enable banked turns.
   -- If the difference between desired heading and current heading
   -- exceeds this number, the vehicle will attempt to roll.
   AngleBeforeRoll = nil,
   -- Maximum roll angle to perform during banked turn.
   MaxRollAngle = 30,
   -- To have the roll angle scale based on the magnitude of the relative
   -- bearing, set the scaling factor here.
   -- To always use MaxRollAngle, set RollAngleGain to nil.
   RollAngleGain = nil,
}
