local CLIP = LibStub("AceAddon-3.0"):GetAddon("CLIP")

function CLIP:OnInitialize()
    self:Print("CLIP Framework Initialized")
    
    self:SetupDatabase()
    
    if self.SetupOptions then
        self:SetupOptions()
    end
end

function CLIP:OnEnable()
end

function CLIP:OnDisable()
end

function CLIP:SetupDatabase()
    self.db = LibStub("AceDB-3.0"):New("CLIPDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    }, "Default")
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

