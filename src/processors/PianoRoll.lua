return {
    process = function(input)
        local override = CurrentPianoRollOverride()
        if override then
            TASState = override.tasState
            return override.joy
        else
            TASState = DefaultTASState
            return input
        end
    end
}
