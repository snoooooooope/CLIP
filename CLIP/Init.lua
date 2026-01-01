local addonName, addonTable = ...

-- Create Addon object with AceConsole and AceEvent
CLIP = LibStub("AceAddon-3.0"):NewAddon("CLIP", "AceConsole-3.0", "AceEvent-3.0")

CLIP.Log = LibStub("AceConsole-3.0")
CLIP.modules = {}

-- Module registration
function CLIP:RegisterModule(name, moduleObject)
    self.modules[name] = moduleObject
    self:Print("Registered module:", name)
end

