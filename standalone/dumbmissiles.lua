-- Really basic, annotated missile script.
-- Uses pure pursuit guidance (i.e. just aim at the target where it is *now*).
-- Would only be useful against stationary targets.

-- Note: I wrote this up for the benefit of the community. *My* missile
-- script weighs in at something like 1500 lines of code, supports multiple
-- phases, multiple profiles, can vary thrust, ballast, whatever, and
-- generally runs super-efficiently due to all the caching its does. :P

function Update(I)
    -- All mainframes see the same targets, but the target order may differ.
    -- Ideally, you'd scan all mainframes, looking for one with a particular
    -- name, and then use its index here.
    local MainframeIndex = 0 -- Just use the "first" mainframe

    -- Fetch the highest priority target according to this mainframe.
    -- Ideally, you'd call I:GetNumberOfTargets(), but since we're only
    -- interested in the highest priority...
    local Target = I:GetTargetInfo(MainframeIndex, 0)
    if Target.Valid then -- Since we didn't check I:GetNumberOfTargets()...
        -- ... make sure the target actually exists.

        for tindex = 0,I:GetLuaTransceiverCount()-1 do
            -- Ideally, you'd also fetch the BlockInfo for this transceiver
            -- and determine if its the "right" one for your missile.
            -- (This would allow you to handle many "profiles" of missiles
            -- in a single script, e.g. anti-air & torpedoes.)
            for mindex = 0,I:GetLuaControlledMissileCount(tindex) do
                -- Ideally, you'd call I:GetLuaControlledMissileInfo() so
                -- you have some basic info (position, velocity, etc.) about
                -- this missile.
                -- But since our guidance is really dumb, we don't need it in
                -- this example.

                local AimPoint = Target.AimPointPosition -- Whee! Pursuit guidance!
                I:SetLuaControlledMissileAimPoint(tindex, mindex, AimPoint.x, AimPoint.y, AimPoint.z)
            end
        end
    end
end