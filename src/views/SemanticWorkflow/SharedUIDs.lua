return UIDProvider.allocate_once("SemanticWorkflow", function(enum_next)
    return {
        VarWatch = enum_next(4),
        SelectTab = enum_next(3 + 1), -- TODO: consider the number of required tabs... carefully!
        ToggleHelp = enum_next(),
        HelpNext = enum_next(),
        HelpBack = enum_next(),
    }
end)