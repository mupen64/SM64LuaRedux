# Copyright Header

Every non-library file must contain the following header:

```lua
--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--
```

# Inherited Rules

This project is part of the Mupen64 project family and inherits rules from the [Mupen64 contribution guidelines](https://github.com/mkdasher/mupen64-rr-lua-/wiki/Contributing).

Any group of rules with an identical heading specified within this document is to be treated with higher priority than the upstream rules.

# Code Style

Code formatting must abide by the `.vscode/settings.json` file.

It's recommended to use the [sumneko Lua VSCode extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) for development, as it understands and applies the formatting config.

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
