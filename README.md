# CLIP - QOL Addon Framework

CLIP is a wrapper for World of Warcraft 3.3.5 that aggregates multiple addons into a single addon.

CLIP isnt meant to be used with large, complex addons, instead its meant to piece together your favorite QOL addons in one package.

## Features

*   **Modular Architecture**: Any addon folder placed inside `CLIP/` is treated as a module.

*   **Automatic TOC Generation**: The `generate_toc.ps1` script scans modules and builds `CLIP.toc` automatically.

*   **Namespace Isolation**: Ensures modules keep their own identity (SavedVariables) instead of merging into CLIP's global namespace.

*   **Profiles**: Saves the enabled/disabled state of modules.

## Installation & Usage

1.  **Install**: Place the `CLIP` folder in `Interface/AddOns/`

2.  **Add Modules**: Drop addon folder(s) you want to include into `CLIP/`
    *   Example: `Interface\AddOns\CLIP\Postal\`

3.  **Build**: Run `generate_toc.ps1` inside the `CLIP` folder.
    *   This script scans subfolders, merges SavedVariables, updates paths, and generates `CLIP.toc` and `Modules.lua`

## Commands

*   `/clip list`: Displays a list of all loaded modules with version/author info.
*   `/clip memory`: Displays the combined memory usage.

*   **Settings**: Configuration available in Interface Options -> AddOns -> CLIP.
    *   Non Ace3 addons MAY not correctly disable via checkbox and may have to be manually removed
