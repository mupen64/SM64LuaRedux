return UIDProvider.allocate_once("SemanticWorkflow", function(enum_next)
    return {
        VarWatch = enum_next(ugui.registry.listbox.uids()),
        SelectTab = enum_next(UIDProvider.unknown),
        ToggleHelp = enum_next(ugui.registry.button.uids()),
        HelpNext = enum_next(ugui.registry.button.uids()),
        HelpBack = enum_next(ugui.registry.button.uids()),
        HelpTitle = enum_next(ugui.registry.label.uids()),
        HelpPageHeading = enum_next(ugui.registry.label.uids()),
        HelpPageText = enum_next(ugui.registry.label.uids()),
        DrawTextBase = enum_next(UIDProvider.unknown),
    }
end)
