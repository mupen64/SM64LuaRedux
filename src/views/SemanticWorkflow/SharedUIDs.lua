return UIDProvider.allocate_once("SemanticWorkflow", function(enum_next)
    return {
        VarWatch = enum_next(),
        SelectTab = enum_next(UIDProvider.unknown),
        SelectTabProjectLoaded = enum_next(UIDProvider.unknown),
        ToggleHelp = enum_next(),
        HelpNext = enum_next(),
        HelpBack = enum_next(),
        HelpTitle = enum_next(),
        HelpPageHeading = enum_next(),
        HelpPageText = enum_next(),
        DrawTextBase = enum_next(UIDProvider.unknown),
    }
end)
