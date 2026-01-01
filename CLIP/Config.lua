local CLIP = LibStub("AceAddon-3.0"):GetAddon("CLIP")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function CLIP:SetupOptions()
    local options = {
        name = "CLIP",
        handler = CLIP,
        type = 'group',
        args = {
            general = {
                type = "group",
                name = "General Settings",
                inline = true,
                order = 1,
                args = {
                    header = {
                        type = "header",
                        name = "Module Management",
                        order = 1,
                    },
                    desc = {
                        type = "description",
                        name = "CLIP automatically detects modules in its folder. Use /clip list to see them.",
                        order = 2,
                    },
                    listModules = {
                        type = "execute",
                        name = "List Modules",
                        desc = "Print a list of all loaded modules to the chat.",
                        func = function() CLIP:SlashCommand("list") end,
                        order = 3,
                    },
                },
            },
        },
    }

    -- Register options
    AceConfig:RegisterOptionsTable("CLIP", options)
    
    -- Add to Interface Options
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("CLIP", "CLIP")
end
