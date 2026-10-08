return UIDProvider.allocate_once("SemanticWorkflow", function(enum_next)
    return {
        VarWatch = enum_next(ugui.listbox_uids()),
        SelectTab = enum_next(UIDProvider.unknown),
        SelectTabProjectLoaded = enum_next(UIDProvider.unknown),
        ToggleHelp = enum_next(ugui.button_uids()),
        HelpNext = enum_next(ugui.button_uids()),
        HelpBack = enum_next(ugui.button_uids()),
        HelpTitle = enum_next(ugui.label_uids()),
        HelpPageHeading = enum_next(ugui.label_uids()),
        HelpPageText = enum_next(ugui.label_uids()),
        DrawTextBase = enum_next(UIDProvider.unknown),
    }
end)
