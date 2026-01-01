local CLIP = LibStub("AceAddon-3.0"):GetAddon("CLIP")

function CLIP:OnInitialize()
    self:Print("CLIP Framework Initialized")
    
    self:SetupDatabase()
    
    -- Apply module states
    if self.RegisteredModules then
        for name, _ in pairs(self.RegisteredModules) do
            if not self:IsModuleEnabled(name) then
                local addon = LibStub("AceAddon-3.0"):GetAddon(name, true)
                if addon then
                    addon:Disable()
                end
            end
        end
    end
    
    if self.SetupOptions then
        self:SetupOptions()
    end
end

function CLIP:SetupDatabase()
    self.db = LibStub("AceDB-3.0"):New("CLIPDB", {
        profile = {
            minimap = {
                hide = false,
            },
            modules = {
                -- [ModuleName] = true/false (enabled/disabled)
                ["*"] = true, -- Default to enabled
            },
        },
    }, "Default")
    
    -- Handle profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

function CLIP:OnProfileChanged()
    -- Re-apply module states when profile changes
    if self.RegisteredModules then
        for name, _ in pairs(self.RegisteredModules) do
            local enabled = self:IsModuleEnabled(name)
            local addon = LibStub("AceAddon-3.0"):GetAddon(name, true)
            
            if addon then
                if enabled then
                    addon:Enable()
                else
                    addon:Disable()
                end
            end
        end
    end
    self:Print("Profile changed. Module states updated.")
end

function CLIP:IsModuleEnabled(name)
    return self.db.profile.modules[name] ~= false
end

function CLIP:SetModuleEnabled(name, enabled)
    self.db.profile.modules[name] = enabled
    
    -- Handle Ace3 modules immediately
    local addon = LibStub("AceAddon-3.0"):GetAddon(name, true)
    if addon then
        if enabled then
            addon:Enable()
        else
            addon:Disable()
        end
    else
        self:Print("Module '"..name.."' is not an Ace3 addon. Reload UI to apply changes (if supported).")
    end
end

-- Slash Commands
CLIP:RegisterChatCommand("clip", "SlashCommand")

function CLIP:SlashCommand(input)
    if not input or input:trim() == "" then
        self:Print("Usage: /clip list")
        return
    end

    local command = input:trim():lower()
    
    if command == "list" then
        self:Print("Loaded Modules:")
        local count = 0
        
        -- Check for registered modules
        if self.RegisteredModules then
            for name, info in pairs(self.RegisteredModules) do
                local meta = ""
                if type(info) == "table" then
                    -- Format: Name (v1.0 by Author)
                    meta = string.format(" |cffaaaaaa(v%s by %s)|r", info.version or "?", info.author or "?")
                end
                self:Print("- " .. name .. meta)
                count = count + 1
            end
        else
            -- Fallback scan
            for name, addon in LibStub("AceAddon-3.0"):IterateAddons() do
                if name ~= "CLIP" then
                    self:Print("- " .. name .. " (Ace3)")
                    count = count + 1
                end
            end
        end
        self:Print("Total: " .. count)
    else
        self:Print("Unknown command: " .. command)
    end
end

