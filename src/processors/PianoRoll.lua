return {
    process = function(input)
        local override = CurrentPianoRollOverride()
        if override then
            TASState = override.tas_state
            return override.joy
        else
            TASState = DefaultTASState
            return input
        end
    end
}
