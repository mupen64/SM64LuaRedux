--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- This semantic version (see https://semver.org/)
-- will be stored in .sws and .swp files saved with the current version of this script.

-- The "API" in the sense of semantic versioning is this script itself,
-- meaning that files with a lower Major version than this value
-- may not be interpreted as expected by this version of the script.

-- Minor and Patch version shall behave as normal,
-- meaning that full downwards compatibility within that Major version shall be guaranteed.
SEMANTIC_WORKFLOW_FILE_VERSION = '1.1.0'
