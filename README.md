# CLIP - QOL Addon Framework

CLIP is a wrapper for World of Warcraft 3.3.5 that aggregates multiple addons into a single addon.

CLIP isnt meant to be used with large, complex addons, instead its meant to piece together your favorite QOL addons in one package.

## Features

*   **Modular Architecture**: Any addon folder placed inside `CLIP/` is treated as a module.

*   **Automatic TOC Generation**: The `generate_toc.ps1` script scans modules and builds `CLIP.toc` automatically.

## Installation & Usage:

*  1.  **Install**: Place the `CLIP` folder in `Interface/AddOns/`

*   2.  **Add Modules**: Drop addon folder(s) you want to include into `CLIP/`
        *   Example: `Interface\AddOns\CLIP\Postal\`

*    3.  **Build**: Run `generate_toc.ps1` inside the `CLIP` folder.
        *   This script scans subfolders, merges SavedVariables, updates paths, and generates `CLIP.toc` and `Modules.lua`

## Commands

*   `/clip list`: Displays a list of all detected and loaded modules.

*   **Settings**: Configuration available in Interface Options -> AddOns -> CLIP.

## Caveats & Known Issues

*   **SavedVariables Reset**: Since addons run as "CLIP", they will store their settings in `WTF/.../SavedVariables/CLIP.lua` instead of their original files. **Your existing settings will not be detected automatically.** You will need to reconfigure addons or manually migrate data.

*   **Addon Detection**: API calls like `IsAddonLoaded("AddonName")` will return `false` because WoW views the entire package as a single addon. Modules that rely on this check to interact with other addons may require modification.
