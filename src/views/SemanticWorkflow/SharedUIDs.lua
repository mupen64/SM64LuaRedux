return UIDProvider.allocate_once("SemanticWorkflow", function(enum_next)
    return {
        VarWatch = enum_next(ugui.registry.listbox.uids()),
        -- FIXME: ugui.tabcontrol has no registry entry yet
        SelectTab = enum_next(1 + 3 * ugui.registry.toggle_button.uids()),
        ToggleHelp = enum_next(ugui.registry.button.uids()),
        HelpNext = enum_next(ugui.registry.button.uids()),
        HelpBack = enum_next(ugui.registry.button.uids()),
        HelpTitle = enum_next(ugui.registry.label.uids()),
        HelpPageHeading = enum_next(ugui.registry.label.uids()),
        HelpPageText = enum_next(ugui.registry.label.uids()),
        DrawTextBase = enum_next(1024),
    }
end)
