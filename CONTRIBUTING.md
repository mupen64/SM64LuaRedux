# Project Scope

SM64 Lua Redux is an SM64 utility Lua script built for the Mupen64 emulator.

It should:

- be intuitive for first-time users (use established UI and interaction patterns and if possible)
- allow more efficient interactions for advanced users (e.g. hotkeys)
- be fast (the script shouldn't lag mupen during regular operation)

# Type Annotations

Use type annotations wherever automatic type inference fails and developers would otherwise be required to scan big chunks of code to manually infer a type.

Particularly `dofile` results should be type-annotated wherever possible.

