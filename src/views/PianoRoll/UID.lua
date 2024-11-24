local enumerator = 1000
local function EnumNext(count)
    local current = enumerator
    enumerator = enumerator + (count or 1)
    return current
end

return {
    VarWatch = EnumNext(),
    ToggleHelp = EnumNext(),
    HelpNext = EnumNext(),
    HelpBack = EnumNext(),
    PianoRollName = EnumNext(),
    AddPianoRoll = EnumNext(),
    SelectionSpinner = EnumNext(),
    SavePianoRoll = EnumNext(),
    LoadPianoRoll = EnumNext(),
    CopyEntireState = EnumNext(),
    Joypad = EnumNext(),
    JoypadSpinnerX = EnumNext(3),
    JoypadSpinnerY = EnumNext(3),
    GoalAngle = EnumNext(),
    GoalMag = EnumNext(),
    StrainLeft = EnumNext(),
    StrainRight = EnumNext(),
    StrainAlways = EnumNext(),
    StrainSpeedTarget = EnumNext(),
    MovementModeManual = EnumNext(),
    MovementModeMatchYaw = EnumNext(),
    MovementModeMatchAngle = EnumNext(),
    MovementModeReverseAngle = EnumNext(),
    DYaw = EnumNext(),
    SpeedKick = EnumNext(),
    ResetMag = EnumNext(),
    AtanStrain = EnumNext(),
    AtanN = EnumNext(3),
    AtanD = EnumNext(3),
    AtanE = EnumNext(3),
    TrimEnd = EnumNext(),
    Delete = EnumNext(),
    ConfirmationYes = EnumNext(),
    ConfirmationNo = EnumNext(),
    FrameListScrollbar = EnumNext(),
    UIDCOUNT = EnumNext(),
}