# Project Scope

SM64 Lua Redux is an SM64 utility Lua script built for the Mupen64 emulator.

It should:

- be intuitive for first-time users (use established UI and interaction patterns if possible)
- allow more efficient interactions for advanced users (e.g. hotkeys)
- be fast (the script shouldn't lag mupen during regular operation)

# Type Annotations

Use type annotations wherever automatic type inference fails (or produces unnecessarily complex results) and developers would otherwise be required to scan big chunks of code to manually infer a type.

Particularly `dofile` results should be type-annotated wherever possible.

# Naming

Locals and table keys: `snake_case`

Globals: `PascalCase`

Enum tables: `MACRO_CASE`

Constants: `MACRO_CASE`

# Commit Style

Adhere to [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/).
