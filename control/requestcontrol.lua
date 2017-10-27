--@ clamp
-- Friendly wrapper around I:RequestControl
function MakeRequestControl(Scale)
   Scale = Scale or 1
   return function (I, Fraction, PosControl, NegControl, CV)
      if Fraction > 0 then
         -- Scale and constrain
         CV = Clamp(Fraction * CV * Scale, -1, 1)
         if PosControl ~= NegControl then
            -- Generally yaw, pitch, roll
            if CV > 0 then
               I:RequestControl(Mode, PosControl, CV)
            elseif CV < 0 then
               I:RequestControl(Mode, NegControl, -CV)
            end
         else
            -- Generally propulsion
            I:RequestControl(Mode, PosControl, CV)
         end
      end
   end
end
