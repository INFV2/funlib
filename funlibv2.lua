-- Enhanced Modern UI Library for Roblox Executors
local Library = {
    theme = {
        main = Color3.fromRGB(30, 30, 30),
        secondary = Color3.fromRGB(40, 40, 40),
        accent = Color3.fromRGB(60, 120, 255),
        text = Color3.fromRGB(255, 255, 255),
        stroke = Color3.fromRGB(60, 60, 60),
        darkAccent = Color3.fromRGB(40, 80, 180),
        lightAccent = Color3.fromRGB(80, 140, 255),
        success = Color3.fromRGB(60, 200, 60),
        warning = Color3.fromRGB(255, 165, 0),
        error = Color3.fromRGB(255, 60, 60),
        background = Color3.fromRGB(25, 25, 25),
        highlight = Color3.fromRGB(70, 70, 70)
    },
    flags = {},
    options = {
        outlineObjects = true,
        smoothDragging = true,
        toggleAnimations = true,
        useSnackbars = true,
        stickyHeader = true,
        showKeybindIndicators = true,
        enableSounds = true,
        blurEffect = true,
        roundness = 6,
        easingStyle = Enum.EasingStyle.Quart,
        animationDuration = 0.2
    },
    binds = {},
    notifications = {},
    windows = {},
    connections = {},
    destroyed = false
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Constants
local WINDOW_DEFAULTS = {
    width = 600,
    height = 400,
    minWidth = 400,
    minHeight = 300,
    headerHeight = 30
}

-- Utility Functions
local function Create(class, properties, children)
    local instance = Instance.new(class)
    
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then -- Set parent last
            instance[property] = value
        end
    end
    
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

local function Tween(instance, duration, properties)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration,
            Library.options.easingStyle,
            Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function ApplyBlur(frame)
    if not Library.options.blurEffect then return end
    
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Parent = game:GetService("Lighting")
    
    frame.AncestryChanged:Connect(function()
        if not frame:IsDescendantOf(game) then
            blur:Destroy()
        end
    end)
    
    return blur
end

local function CreateRipple(parent, position)
    local ripple = Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0, position.X, 0, position.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = parent.ZIndex + 1
    })
    
    local corner = Create("UICorner", {
        Parent = ripple,
        CornerRadius = UDim.new(1, 0)
    })
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    Tween(ripple, 0.5, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }).Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function CreateStroke(parent, properties)
    if not Library.options.outlineObjects then return end
    
    return Create("UIStroke", {
        Parent = parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Library.theme.stroke,
        Thickness = 1,
        Transparency = 0
    })
end

local function CreateShadow(parent)
    local shadow = Create("ImageLabel", {
        Parent = parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    
    return shadow
end

-- Notification System
function Library:Notify(options)
    options = typeof(options) == "table" and options or {
        title = options,
        content = "No content provided",
        duration = 3,
        type = "info"
    }
    
    local colors = {
        info = Library.theme.accent,
        success = Library.theme.success,
        warning = Library.theme.warning,
        error = Library.theme.error
    }
    
    local notification = Create("Frame", {
        Parent = self.notificationHolder,
        BackgroundColor3 = Library.theme.secondary,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 20, 1, -90),
        BackgroundTransparency = 1
    })
    
    -- Add notification content here (title, message, icon, etc.)
    -- Animate notification in
    Tween(notification, 0.3, {
        Position = UDim2.new(1, -320, 1, -90),
        BackgroundTransparency = 0
    })
    
    -- Remove after duration
    task.delay(options.duration, function()
        Tween(notification, 0.3, {
            Position = UDim2.new(1, 20, 1, -90),
            BackgroundTransparency = 1
        }).Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Keybind System
function Library:BindToKey(key, callback)
    self.binds[key] = callback
    
    if not self.keyHandler then
        self.keyHandler = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode
                if self.binds[key] then
                    self.binds[key]()
                end
            end
        end)
    end
end

-- Configuration System
function Library:SaveConfig(name)
    local config = {
        theme = self.theme,
        options = self.options,
        flags = self.flags
    }
    
    writefile(name .. ".json", HttpService:JSONEncode(config))
end

function Library:LoadConfig(name)
    if isfile(name .. ".json") then
        local config = HttpService:JSONDecode(readfile(name .. ".json"))
        
        self:SetTheme(config.theme)
        for option, value in pairs(config.options) do
            self.options[option] = value
        end
        for flag, value in pairs(config.flags) do
            self.flags[flag] = value
        end
    end
end

-- Window Creation
function Library:CreateWindow(title)
    if self.destroyed then return end
    
    -- Create main window container
    local window = {
        tabs = {},
        currentTab = nil,
        dragging = false,
        resizing = false
    }
    
    -- Create GUI elements
    window.gui = Create("ScreenGui", {
        Name = "ModernUILibrary",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    window.main = Create("Frame", {
        Name = "MainFrame",
        Parent = window.gui,
        BackgroundColor3 = Library.theme.main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -WINDOW_DEFAULTS.width/2, 0.5, -WINDOW_DEFAULTS.height/2),
        Size = UDim2.new(0, WINDOW_DEFAULTS.width, 0, WINDOW_DEFAULTS.height),
        ClipsDescendants = true
    })
    
    -- Add window functionality (dragging, resizing, etc.)
    self:MakeWindowFunctional(window)
    
    -- Store window reference
    table.insert(self.windows, window)
    
    return window
end

-- Add more functions for tabs, elements, etc.

return Library
