-- Theme Manager - GUI appearance settings
local Theme = {}

-- Available themes
Theme.Themes = {
    dark = {
        -- Main colors
        background = Color3.fromRGB(25, 25, 30),
        backgroundLight = Color3.fromRGB(35, 35, 40),
        backgroundDark = Color3.fromRGB(20, 20, 25),
        
        -- Primary/accent colors
        primary = Color3.fromRGB(45, 120, 255),
        primaryLight = Color3.fromRGB(65, 140, 255),
        secondary = Color3.fromRGB(255, 165, 0),
        secondaryLight = Color3.fromRGB(255, 185, 20),
        
        -- Text colors
        textPrimary = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 180),
        
        -- Tab colors
        tabActive = Color3.fromRGB(45, 120, 255),
        tabInactive = Color3.fromRGB(40, 40, 45),
        tabHover = Color3.fromRGB(50, 50, 55),
        textActive = Color3.fromRGB(255, 255, 255),
        textInactive = Color3.fromRGB(180, 180, 180),
        
        -- Button colors
        success = Color3.fromRGB(40, 180, 99),
        successLight = Color3.fromRGB(50, 200, 120),
        warning = Color3.fromRGB(255, 165, 0),
        warningLight = Color3.fromRGB(255, 185, 20),
        danger = Color3.fromRGB(220, 50, 50),
        dangerLight = Color3.fromRGB(240, 70, 70),
        
        -- Toggle colors
        toggleOn = Color3.fromRGB(40, 180, 99),
        toggleOff = Color3.fromRGB(80, 80, 85)
    },
    
    light = {
        -- Main colors
        background = Color3.fromRGB(240, 240, 240),
        backgroundLight = Color3.fromRGB(250, 250, 250),
        backgroundDark = Color3.fromRGB(230, 230, 230),
        
        -- Primary/accent colors
        primary = Color3.fromRGB(0, 120, 215),
        primaryLight = Color3.fromRGB(30, 140, 235),
        secondary = Color3.fromRGB(255, 150, 0),
        secondaryLight = Color3.fromRGB(255, 170, 20),
        
        -- Text colors
        textPrimary = Color3.fromRGB(30, 30, 30),
        textSecondary = Color3.fromRGB(100, 100, 100),
        
        -- Tab colors
        tabActive = Color3.fromRGB(0, 120, 215),
        tabInactive = Color3.fromRGB(225, 225, 225),
        tabHover = Color3.fromRGB(210, 210, 210),
        textActive = Color3.fromRGB(255, 255, 255),
        textInactive = Color3.fromRGB(50, 50, 50),
        
        -- Button colors
        success = Color3.fromRGB(40, 170, 90),
        successLight = Color3.fromRGB(50, 190, 110),
        warning = Color3.fromRGB(240, 140, 0),
        warningLight = Color3.fromRGB(255, 160, 10),
        danger = Color3.fromRGB(220, 50, 50),
        dangerLight = Color3.fromRGB(240, 70, 70),
        
        -- Toggle colors
        toggleOn = Color3.fromRGB(40, 170, 90),
        toggleOff = Color3.fromRGB(180, 180, 180)
    }
}

-- Set the current theme (dark by default)
Theme.Current = Theme.Themes.dark

-- Switch theme
function Theme:SwitchTheme(themeName)
    if self.Themes[themeName] then
        self.Current = self.Themes[themeName]
        return true
    end
    return false
end

return Theme