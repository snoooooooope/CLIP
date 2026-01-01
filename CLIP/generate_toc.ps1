# generate_toc.ps1
# This script scans all subfolders in the CLIP directory and generates a CLIP.toc file
# that includes all their files, effectively merging them into one addon.

$addonName = "CLIP"
$tocFile = "$PSScriptRoot\$addonName.toc"
$interfaceVersion = "30300" 

Write-Host "Generating $tocFile for Interface $interfaceVersion..."

# Initialize lists
$savedVariables = @("CLIPDB")
$libsFiles = @()
$coreFiles = @()
$moduleFiles = @()
$detectedModuleObjects = @()

# Define CLIP Core files
$coreFiles += "Init.lua"
$coreFiles += "Modules.lua"
$coreFiles += "Core.lua"
$coreFiles += "Config.lua"

# Function to parse a TOC file
function Parse-Toc {
    param ($path, $relPath)
    $content = Get-Content $path
    $files = @()
    $svs = @()
    
    foreach ($line in $content) {
        $line = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        
        # Parse SavedVariables
        if ($line -match "^## SavedVariables:\s*(.*)") {
            $vars = $matches[1].Split(",") | ForEach-Object { $_.Trim() }
            $svs += $vars
        }
        # Skip comments and other metadata
        elseif ($line.StartsWith("#")) { continue }
        else {
            $fileLine = $line -replace "/", "\"
            $fullPath = Join-Path $relPath $fileLine
            $files += $fullPath
        }
    }
    
    return @{ Files = $files; SavedVariables = $svs }
}

# Scan subfolders
$subdirs = Get-ChildItem -Path $PSScriptRoot -Directory
foreach ($dir in $subdirs) {
    if ($dir.Name.StartsWith(".")) { continue }
    
    if ($dir.Name -eq "Libs") {
        # LibStub -> CallbackHandler -> Ace*
        $libOrder = @("LibStub", "CallbackHandler-1.0", "AceAddon-3.0", "AceEvent-3.0", "AceDB-3.0", "AceConsole-3.0", "AceGUI-3.0", "AceConfig-3.0", "AceLocale-3.0", "AceHook-3.0")
        
        function Get-LibEntry {
            param($libName)
            $libPath = Join-Path "$PSScriptRoot\Libs" $libName
            if (Test-Path $libPath) {
                # Look for XML first
                $xml = Get-ChildItem -Path $libPath -Filter "*.xml" | Select-Object -First 1
                if ($xml) { return "Libs\$libName\$($xml.Name)" }
                
                # Look for Lua
                $lua = Get-ChildItem -Path $libPath -Filter "*.lua" | Select-Object -First 1
                if ($lua) { return "Libs\$libName\$($lua.Name)" }
            }
            return $null
        }

        foreach ($lib in $libOrder) {
            $entry = Get-LibEntry -libName $lib
            if ($entry) { 
                $libsFiles += $entry 
            }
        }
        
        # Add any other libs in Libs/ not explicitly listed
        $allLibs = Get-ChildItem -Path "$PSScriptRoot\Libs" -Directory
        foreach ($dir in $allLibs) {
            if ($dir.Name -notin $libOrder) {
                 $entry = Get-LibEntry -libName $dir.Name
                 if ($entry) { $libsFiles += $entry }
            }
        }

        continue
    }

    # Look for a .toc file with the same name as the folder
    $tocPath = Join-Path $dir.FullName "$($dir.Name).toc"
    
    # If not found, look for ANY .toc file
    if (-not (Test-Path $tocPath)) {
        $anyToc = Get-ChildItem -Path $dir.FullName -Filter "*.toc" | Select-Object -First 1
        if ($anyToc) { $tocPath = $anyToc.FullName }
        else { continue }
    }

    Write-Host "Processing module: $($dir.Name)"
    
    # Patch texture paths
    $moduleFilesToScan = Get-ChildItem -Path $dir.FullName -Recurse -Filter "*.lua"
    foreach ($luaFile in $moduleFilesToScan) {
        $content = Get-Content $luaFile.FullName
        $changed = $false
        
        $oldPath = "Interface\\AddOns\\$($dir.Name)"
        $newPath = "Interface\\AddOns\\CLIP\\$($dir.Name)"
        
        $oldPathSingle = "Interface\AddOns\$($dir.Name)"
        $newPathSingle = "Interface\AddOns\CLIP\$($dir.Name)"

        for ($i = 0; $i -lt $content.Count; $i++) {
            # Patch texture paths
            if ($content[$i] -match [Regex]::Escape($oldPath)) {
                $content[$i] = $content[$i] -replace [Regex]::Escape($oldPath), $newPath
                $changed = $true
            }
            elseif ($content[$i] -match [Regex]::Escape($oldPathSingle)) {
                $content[$i] = $content[$i] -replace [Regex]::Escape($oldPathSingle), $newPathSingle
                $changed = $true
            }
            
            # Namespace fix for DB creation (local addonName, ns = ...)
            # This ensures modules use their own name instead of "CLIP" (hopefully)
            if ($content[$i] -match "^\s*local\s+([a-zA-Z0-9_]+)\s*,\s*([a-zA-Z0-9_]+)\s*=\s*\.\.\.") {
                $varName = $matches[1]
                $overrideCode = "; $varName = `"$($dir.Name)`""
                
                # Check if we already patched this line
                if (-not ($content[$i].EndsWith($overrideCode))) {
                    $content[$i] = $content[$i] + $overrideCode
                    $changed = $true
                    Write-Host "    -> Patching namespace in line $($i+1)"
                }
            }
        }
        
        if ($changed) {
            Write-Host "  -> Updated $($luaFile.Name)"
            Set-Content -Path $luaFile.FullName -Value $content
        }
    }

    $result = Parse-Toc -path $tocPath -relPath $dir.Name
    
    # Extract metadata
    $tocContent = Get-Content $tocPath
    $modTitle = $dir.Name
    $modVersion = "Unknown"
    $modAuthor = "Unknown"
    
    foreach ($line in $tocContent) {
        if ($line -match "^## Title:\s*(.*)") { $modTitle = $matches[1].Trim() }
        if ($line -match "^## Version:\s*(.*)") { $modVersion = $matches[1].Trim() }
        if ($line -match "^## Author:\s*(.*)") { $modAuthor = $matches[1].Trim() }
    }
    
    $modTitle = $modTitle -replace '"', '\"'
    $modVersion = $modVersion -replace '"', '\"'
    $modAuthor = $modAuthor -replace '"', '\"'
    
    # Add SavedVariables
    $savedVariables += $result.SavedVariables
    
    $detectedModuleObjects += @{
        Name = $dir.Name
        Title = $modTitle
        Version = $modVersion
        Author = $modAuthor
    }

    # Classify files
    foreach ($f in $result.Files) {
        # Check against centralized Libs
        $isStandardLib = $false
        if ($f -match "LibStub\.lua" -or $f -match "CallbackHandler-1\.0" -or $f -match "Ace.*-3\.0") {
             $libName = if ($f -match "(Ace\w+-3\.0)") { $matches[1] } 
                        elseif ($f -match "LibStub") { "LibStub" }
                        elseif ($f -match "CallbackHandler") { "CallbackHandler-1.0" }
             
             if ($libName -and (Test-Path "$PSScriptRoot\Libs\$libName")) {
                 $isStandardLib = $true
             }
        }

        if ($isStandardLib) {
             continue
        }

        # Check for other internal libraries
        if ($f -match "LibStub\.lua" -or $f -match "Ace.*\.xml" -or $f -match "CallbackHandler.*\.xml" -or $f -match "Lib.*\.lua") {
            $libsFiles += $f
        }
        else {
            $moduleFiles += $f
        }
    }
}

# Remove duplicates from Libs and SavedVariables
$libsFiles = $libsFiles | Select-Object -Unique
$savedVariables = $savedVariables | Select-Object -Unique

# Generate Modules.lua
$modulesLuaPath = "$PSScriptRoot\Modules.lua"
$modulesLuaContent = @"
-- This file is auto-generated by generate_toc.ps1
local CLIP = LibStub("AceAddon-3.0"):GetAddon("CLIP")
CLIP.RegisteredModules = {
"@

foreach ($mod in $detectedModuleObjects) {
    $modulesLuaContent += "`n    [`"$($mod.Name)`"] = { title = `"$($mod.Title)`", version = `"$($mod.Version)`", author = `"$($mod.Author)`" },"
}

$modulesLuaContent += "`n}"
Set-Content -Path $modulesLuaPath -Value $modulesLuaContent
Write-Host "Generated Modules.lua with $($detectedModuleObjects.Count) modules."

# Construct TOC Content
$tocContent = @"
## Interface: $interfaceVersion
## Title: $addonName
## Notes: Your favorite brand of glue.
## Author: discord@morucarti
## Version: 1.2.2
## SavedVariables: $($savedVariables -join ", ")

# Libraries (Auto-detected)
$($libsFiles -join "`n")

# Core Framework
$($coreFiles -join "`n")

# Modules
$($moduleFiles -join "`n")
"@

Set-Content -Path $tocFile -Value $tocContent
Write-Host "CLIP.toc updated with $($moduleFiles.Count) modules and $($libsFiles.Count) libraries."

