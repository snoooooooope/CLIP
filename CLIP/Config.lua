local CLIP = LibStub("AceAddon-3.0"):GetAddon("CLIP")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

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
                        name = "Enable or disable modules. Ace3 modules toggle instantly; others may require a UI Reload.",
                        order = 2,
                    },
                    listModules = {
                        type = "execute",
                        name = "List Modules",
                        desc = "Print a list of all loaded modules to the chat.",
                        func = function() CLIP:SlashCommand("list") end,
                        order = 3,
                    },
                    checkMemory = {
                        type = "execute",
                        name = "Check Memory",
                        desc = "Print the current memory usage of CLIP and its modules.",
                        func = function() CLIP:SlashCommand("memory") end,
                        order = 4,
                    },
                    modules = {
                        type = "group",
                        name = "Modules",
                        inline = true,
                        order = 10,
                        args = {},
                    },
                },
            },
            profiles = AceDBOptions:GetOptionsTable(CLIP.db),
        },
    }

    -- Add checkboxes for registered modules
    if self.RegisteredModules then
        for name, info in pairs(self.RegisteredModules) do
            local desc = ""
            if type(info) == "table" then
                desc = string.format("Version: %s\nAuthor: %s", info.version or "?", info.author or "?")
            end
            
            options.args.general.args.modules.args[name] = {
                type = "toggle",
                name = name,
                desc = desc,
                get = function() return CLIP:IsModuleEnabled(name) end,
                set = function(info, value) CLIP:SetModuleEnabled(name, value) end,
            }
        end
    end

    -- Register options
    AceConfig:RegisterOptionsTable("CLIP", options)
    
    -- Add to Interface Options
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("CLIP", "CLIP")
end
